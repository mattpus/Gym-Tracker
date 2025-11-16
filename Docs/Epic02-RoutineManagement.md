# Epic 2 – Routine Management

Planning notes for building the routine features described in Epic 2. The current package only models workouts (`WorkoutsDomain`, `WorkoutsData`, `WorkoutsPresentation`) and persists them via `WorkoutRepository`. No routines exist yet, so all flows below introduce new domain models, repositories, adapters, and tests.

## Shared Dependencies & Open Questions

- Introduce a `Routine` aggregate (+ `RoutineExercise`, `RoutineSet` or reuse `Exercise`/`ExerciseSet` with template semantics) that is independent from `Workout`.
- Define a `RoutineRepository` protocol mirroring `WorkoutRepository` so the data/presentation layers keep depending on abstractions.
- Decide whether routines live in the existing Core Data stack or a new store. If they share a store, plan Core Data schema updates (migration, DTOs, mapping tests).
- Clarify the “exercise search library” dependency. If no library module exists, we need a new abstraction (e.g., `ExerciseLibrarySearching`) and fake data for tests.
- Determine validation rules for routine names (unique? min/max length?) and whether routines track notes, rest durations, or target weights/reps.
- Confirm how workouts and routines interact inside the “Workouts” tab (two sections vs. combined list) to shape presenter/view contracts.

## Story 2.1 – Create New Routine

**Domain**
- Add the `Routine` aggregate and supporting types inside `WorkoutsDomain` with equatable conformance and helper APIs for ordering exercises/sets.
- Create the `RoutineRepository` and `RoutineBuilding` protocols plus the corresponding `CreateRoutineUseCase` that composes repository + clock/UUID providers.
- Create `ExerciseLibrarySearching` and related DTOs to pull exercises from the search library when building routines.
- Add a `RoutineReorderingUseCase` (or commands on the builder) to handle drag-and-drop and persist new order indexes.

**Data**
- Extend `WorkoutsData` with local DTOs (`LocalRoutine`, `LocalRoutineExercise`, etc.) and mapping helpers between domain and persistence models.
- Update the Core Data stack (or future store) with routine entities and write store specs mirroring `WorkoutStoreSpecs`.
- Implement `LocalRoutineRepository` plus spies for tests.

**Presentation**
- Add view protocols + models for the routine builder (list of exercises, selected exercise metadata, validation errors).
- Create a `RoutineBuilderPresenter` that bridges builder state changes to the UI, hides loading/errors, and exposes localized copy: “New Routine”, form error strings, etc.
- Create presentation adapters that connect UI actions (add exercise, reorder, save) to the new domain use cases.
- Add wiring from the workouts tab to launch the routine builder when “New Routine” is tapped.

**Tests**
- Unit-test `CreateRoutineUseCase`, reordering behavior, and validation paths with spies against `RoutineRepository`.
- Add presenter/adapters tests following the patterns from `WorkoutsPresenterTests` and `WorkoutCommandPresenterTests`.

**Open Questions**
- Should the builder auto-save drafts or only persist on explicit save?
- Do routines support optional metadata (notes, tags, rest timers) at launch time?

## Story 2.2 – Start Routine

**Domain**
- Add a `RoutinesLoading` use case to fetch routines for the workouts tab (ordering + filtering rules decided above).
- Implement a `StartRoutineUseCase` that:
  - Loads the routine from `RoutineRepository`.
  - Maps it to a `Workout` (new helper to copy exercises/sets with default values).
  - Calls `WorkoutScheduling` to persist the started workout with the current timestamp and default sets.
- Capture errors for missing routines and bubble them via a domain-specific `StartRoutineError`.

**Data**
- Ensure the routine repository can return routines quickly (sorted by updatedAt/name) and expose seeds for sample data/tests.
- Provide integration tests that cover routine-to-workout mapping persistence (routine stored, workout scheduled).

**Presentation**
- Extend the workouts tab presentation so routines appear in their own section/list with a “Start Routine” action on each cell.
- Add a `RoutinesPresenter` (potentially composed inside `WorkoutsPresenter`) that outputs view models for the routines list and loading states.
- Create a `StartRoutinePresentationAdapter` that uses `StartRoutineUseCase` + `WorkoutCommandPresenter` to show success/error/loading.

**Tests**
- Presenter tests covering empty routines, multiple sections, and button visibility.
- Use case tests verifying workouts start with routine exercises and default sets.

**Open Questions**
- Should starting a routine immediately navigate to the workout logging flow or just queue it? (Affects completion handler contracts.) → **Decision:** immediately navigate into workout logging after the use case succeeds.
- Do we allow editing routine details before starting (weight targets, etc.)? → **Decision:** yes, the UI should surface an editable step before the workout begins so users can tweak routine details.

## Story 2.3 – Start Empty Workout

**Domain**
- Add a `StartEmptyWorkoutUseCase` (or a convenience on `WorkoutScheduling`) that creates a `Workout` with no exercises and current timestamp.
- Share helpers for generating IDs/dates so this use case mirrors the routine-start path.

**Presentation**
- Add a command/button presenter for “Start Empty Workout” wired through an adapter to the new use case and `WorkoutCommandPresenter` for feedback.

**Tests**
- Cover the new use case (ensuring repository receives an empty workout, duplicates are not created when scheduling twice).
- Presenter/adapter tests to ensure button taps trigger loading and success/error rendering.

**Open Questions**
- Should the UI prompt for a workout name before scheduling or auto-generate one (“Untitled Workout”)?

## Story 2.4 – Save Workout as New Routine

**Domain**
- Implement a `SaveWorkoutAsRoutineUseCase` that:
  - Takes a finished or in-progress `Workout`.
  - Converts it into a `Routine` while stripping weights/reps history (keep exercise order + number of sets, but reset measurement fields).
  - Saves via `RoutineRepository`.
- Decide if this use case deduplicates routines with the same name or always creates a new entry.

**Presentation**
- Extend the finish-workout presenter/adapter stack (`FinishWorkoutPresenter`, `FinishWorkoutPresentationAdapter`) to surface a “Save as Routine” action.
- Add localized copy + loading/error handling for this action, likely reusing `WorkoutCommandPresenter` or a new `RoutineCommandPresenter`.
- Wire the `SaveWorkoutAsRoutinePresentationAdapter` into the finish flow so the new domain use case is reachable when the user selects “Save as Routine.”

**Tests**
- Unit tests to verify value stripping logic and repository interactions.
- Presentation tests ensuring the action surfaces only after a workout completes and errors are displayed.

**Open Questions**
- Do we persist routines even if the workout contained incomplete exercises?
- Should the user be allowed to rename the routine during this flow or reuse the workout name automatically?

## Cross-Cutting Tasks

- Update `Package.swift` / target structures if routines evolve into shared modules (e.g., a new `RoutinesDomain` product).
- Document the routine data model inside `agent.md` once finalized.
- Provide sample fixtures (JSON/Core Data seeds) so previews/tests can load both workouts and routines.
- Add integration/UI tests once UI targets are wired up (outside this package but keep adapters testable).
