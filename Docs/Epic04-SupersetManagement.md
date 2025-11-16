# Epic 4 – Superset Management

Plan for introducing superset creation/editing across the workout builder/logging flows. Work builds on the exercise management logic from Epic 3 (reorder/replace/remove) and the exercise search infrastructure.

## Story 4.1 – Create Superset

**Domain**
- Introduce a superset model or augment `Workout`/`Exercise` with superset relationships (e.g., `supersetID`, `supersetOrder`).
- Add a `SupersetLinking` use case that links two or more exercises inside a workout (validates they share the same workout, ensures unique grouping IDs, handles rest timer decisions later).

**Data**
- Update persistence layer (`LocalWorkoutRepository` + Core Data schema) to store superset metadata (group identifiers/order) and migration tests.

**Presentation**
- Add “Add to Superset” action in exercise menus that launches the selection flow (choose existing superset or create new). Presenter handles highlighting (badge, grouping) using new view models (e.g., `ExerciseSupersetViewModel`).
- Provide a command presenter for linking/unlinking feedback.

**Tests**
- Domain tests verifying linkage, validation (minimum exercises), and storing group info.
- Presentation tests for the linking flow and visual state updates.

## Story 4.2 – Remove From Superset

**Domain**
- Implement a `SupersetUnlinking` use case that removes a single exercise from a superset and auto-dissolves if only one member remains.

**Presentation**
- Exercise menu surfaces “Remove from Superset” -> confirmation -> call the new use case. Presenter updates the UI to remove badges/grouping.

**Tests**
- Domain tests for unlinking logic and superset cleanup.
- Presenter tests for confirmation + UI updates.

## Story 4.3 – Reorder Exercises Within Superset

**Domain**
- Extend reordering logic to respect superset grouping:
  - Reordering across groups keeps supersets intact.
  - Reordering within a superset adjusts the intra-group order only.
- Possibly add group-aware reorder use case or extend existing `ReorderWorkoutExercisesUseCase` with superset metadata.

**Presentation**
- During reorder mode, show grouped cards. Drag-and-drop should limit movement to within a superset (unless moving the entire group). Add view models to describe group boundaries.

**Tests**
- Domain tests ensuring group order persists.
- Presentation tests verifying the reorder UI respects group constraints.

## Cross-Cutting
- Decide how superset state interacts with rest timers (shared vs. per exercise) and log this in `agent.md` once finalized.
- Update any exporters/logging flows that need to understand superset structure.
