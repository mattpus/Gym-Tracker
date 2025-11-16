# GymTracker Agent Guide

This document orients new LLM engineers to the GymTracker package so everyone follows the same engineering standards. It captures the clean-architecture practices taken from the Essential Feed case study plus project-specific conventions.

---

## 1. Project Overview

- **Language/Tools**: Swift Package Manager, Swift 6, XCTest.
- **Modules**:
  - `WorkoutsDomain`: Pure domain models, use cases, protocols.
  - `WorkoutsData`: Data layer abstractions (e.g., `WorkoutStore`, Core Data store), DTO mappers, repositories.
  - `WorkoutsPresentation`: Presentation layer with presenters, view models, adapters.
- **Testing philosophy**: Every struct/class gets unit tests. Use spies to assert interactions and track memory leaks using the `trackForMemoryLeaks` helper (mirrors Essential Feed).

---

## 2. Architecture Principles

1. **Clean Architecture**  
   - Domain layer has no framework dependencies. Only pure Swift types, protocols, and use cases.
   - Data and presentation layers depend on domain abstractions, never the other way around.
   - Use dependency inversion: repositories, controllers, and presenters all interact via protocols.

2. **Modularity & Isolation**  
   - Each module has its own tests.
   - Presentation adapters bridge domain use cases/controllers with UI-facing protocols.

3. **Deterministic Tests**  
   - Avoid `DispatchQueue.main.asyncAfter` / timers directly in tests. Instead use spies/injection (e.g., `RestTimerScheduler` abstraction) to control time.
   - Follow the Essential Feed practice of verifying side effects via message arrays on test doubles.

4. **Memory Leak Tracking**  
   - Use `trackForMemoryLeaks` in every test case’s `makeSUT`. Annotate helpers or entire test classes with `@MainActor` when leak tracking is called from synchronous helpers.

---

## 3. Key Components & Patterns

### Domain Layer
- **Models**: `Workout`, `Exercise`, `ExerciseSet`.
- **Repositories**: `WorkoutRepository` is the boundary for persistence.
- **Use Cases**:
  - Loading/scheduling/editing/deleting workouts.
  - Exercise set logging (`ExerciseSetLoggingUseCase`) with previous-session lookups.
  - Rest timers (`DefaultRestTimerController`) with pluggable schedulers.
- **Protocols**: Every use case conforms to a protocol (e.g., `WorkoutsLoading`, `WorkoutEditing`, `RestTimerController`) to keep UI/data layers decoupled.

### Data Layer
- **Stores**: `WorkoutStore` abstracts persistence (currently Core Data).
- **DTOs & Mapping**: Local models convert to/from domain models.
- **Repositories**: `LocalWorkoutRepository` composes store + domain use cases.

### Presentation Layer
- **View Models**: Simple structs describing view state (`WorkoutsViewModel`, `RestTimerViewModel`, etc.).
- **Views Protocols**: UI should conform to these to receive updates (`WorkoutsView`, `RestTimerView`, `RestTimerAlertView`).
- **Presenters**: Orchestrate view model creation (`WorkoutsPresenter`, `ExerciseSetLoggingPresenter`, `RestTimerPresenter`, etc.).
- **Adapters**: Glue between domain use cases / controllers and presenters (`LoadWorkoutsPresentationAdapter`, `ExerciseSetLoggingPresentationAdapter`, `RestTimerPresentationAdapter`).
- **Command Flows**: Use `WorkoutCommandPresenter` for success/error messages and loading indicators across different operations (edit/delete, set logging).

---

## 4. Coding Standards

1. **Naming**: Use verbose, intention-revealing names. Follow Swift API guidelines (e.g., `loadWorkouts()`, `handleSetCompletion(for:)`).
2. **Thread Safety**: Prefer dependency injection of queues/schedulers. For controllers that use timers, abstract the scheduler (`RestTimerScheduler`) to keep tests deterministic.
3. **Error Handling**: Model domain errors as scoped enums (e.g., `ExerciseSetLoggingUseCase.Error`). Return `Result` types; never use callbacks without explicit `Result`.
4. **Tests**:
   - Structure: `func test_<behavior>_<expectation>()`.
   - Use `expect` helper functions or inline expectations.
   - Spies should store messages (e.g., `WorkoutRepositorySpy.Message`) to assert interactions.
5. **Concurrency Annotations**:  
   - Annotate test classes or helpers with `@MainActor` when using `trackForMemoryLeaks`.
   - Avoid capturing mutable state inside `@Sendable` closures unless the type is explicitly `Sendable`.

---

## 5. Workflow Tips

1. **Adding Features**:
   - Start in `WorkoutsDomain`. Define protocols/use cases first.
   - Update `WorkoutsData`/`WorkoutsPresentation` with adapters/presenters.
   - Add tests in the corresponding `Tests` target before wiring into UI.

2. **Integrating Timers/Async Behavior**:
   - Abstract time via protocols (e.g., `RestTimerScheduler`), inject test doubles.
   - Keep controllers synchronous where possible; if queue synchronization is required, wrap blocks in `queue.sync(execute:)`.

3. **Building Upon Essential Feed Learnings**:
   - Mirror its clean boundaries, duplication of patterns (e.g., `XCTestCase+MemoryLeakTracking`, spies).
   - Integration tests (like Essential Feed’s cache integration) should be placed in a dedicated tests target when we add more infra.
   - Presenters should remain dumb, string resources should stay localized/in presenters for now.

4. **Documentation & Communication**:
   - Update this `agent.md` when conventions change.
   - Describe new protocols/use cases in module-level README-style comments or inline doc comments for clarity.

---

## 6. Getting Started Checklist

1. Run `swift test` (requires access to user-level caches; use the harness escalation if necessary).
2. Familiarize yourself with `Sources/` and `Tests/` structure per module.
3. When adding a feature:
   - Define domain contracts + tests.
   - Implement data/presentation pieces.
   - Ensure adapters expose only protocol-based dependencies.
4. Keep tests deterministic: use spies, avoid sleeping, inject schedulers/timers.
5. Track memory leaks for every SUT.

By adhering to these guidelines, we keep the GymTracker package consistent with the engineering rigor shown in the Essential Feed case study—testable, modular, and ready for future UI/platform layers.

---

## 6. Essential Feed Learnings Applied

1. **Use Case Composition** – like Essential Feed’s feed/cache loaders, every GymTracker feature is a use case that depends only on protocols. This makes swap-in data sources easy and encourages SOLID boundaries.
2. **Test Doubles & Specs** – Each repository/controller has a spy mirroring the FeedStore specs approach. Reuse message enums and helper assertions to keep tests declarative.
3. **Memory Leak Checks** – Adopt EF’s `trackForMemoryLeaks` helper in every test to guard retain cycles.
4. **Composable Presentation** – Presenters stay logic-only and talk to view protocols, just as the Essential Feed presenters output view models for multiple platforms.
5. **Integration Testing Mindset** – Important flows (e.g., Core Data + repository) should get integration suites similar to `EssentialFeedCacheIntegrationTests` whenever we add new infra or IO.

---

## 7. Rest Timer Subsystem Notes

- `DefaultRestTimerController` uses injected `RestTimerScheduler` instances. Production code uses the provided `DispatchRestTimerScheduler`; tests should pass spies to deterministically fire ticks.
- `RestTimerPresentationAdapter` implements `RestTimerHandling` so other adapters (e.g., exercise-set logging) can trigger auto-start after a set completes. Always inject a configuration provider that returns the user’s desired rest duration per exercise.
- UI layer should conform to both `RestTimerView` (to show remaining time) and `RestTimerAlertView` (to play sound/haptics). Current alert view model simply signals when to play/stop alerts—hook actual sound/vibration inside the app target.
