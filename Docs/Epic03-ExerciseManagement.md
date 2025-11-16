# Epic 3 – Exercise Management

Planning notes for enabling exercise modifications during workout building/logging flows. This epic builds upon the existing workout/routine infrastructure plus the exercise search support from Epic 2.

## Story 3.1 – Reorder Exercises in Workout

**Domain**
- Provide a `WorkoutExerciseReordering` use case that moves exercises within a workout and persists via `WorkoutRepository`.
- Emit the updated workout so presentation layers can reflect the new order immediately.

**Data**
- Reuse `LocalWorkoutRepository` for persistence; extend integration tests ensuring reordered workouts are saved in Core Data.

**Presentation**
- Add view models/adapters for drag-and-drop reorder flows (command feedback via `WorkoutCommandPresenter`).
- Expose the action from the workout logging overflow menu.

**Tests**
- Domain tests for reordering success/failure.
- Presentation tests ensuring drag/drop events trigger the use case and errors surface.

## Story 3.2 – Replace Exercise

**Domain**
- Implement `WorkoutExerciseReplacing` that swaps an exercise with an `ExerciseLibraryItem`, clears existing sets, and preserves metadata like rest timers.

**Presentation**
- Presenter handles search results (via `ExerciseLibrarySearching`), confirmation prompts, and communicates through `WorkoutCommandPresenter` with an `onUpdatedWorkout` callback.

**Tests**
- Domain and presenter tests verifying search, confirmation, replacement, and error handling.

## Story 3.3 – Remove Exercise

**Domain**
- Add a `WorkoutExerciseRemoving` use case to delete exercises with safeguards (cannot remove the last exercise unless finishing/discarding).

**Presentation**
- Overflow menu action triggering confirmation and showing errors when last-exercise rule hits. Engage the `RemoveExercisePresenter` + `WorkoutCommandPresenter` for UX feedback.

**Tests**
- Cover removal success/failure and presenter confirmation flows.

## Cross-Cutting

- Ensure exercise modifications reset dependent UI state (rest timers, logging presenters).
- Update docs (`agent.md`) when new use cases/presenters are finalized.
