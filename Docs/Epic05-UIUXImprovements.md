# Epic 5 – UI/UX Improvements & Navigation

Plan for the visual/interaction enhancements surfaced in the screenshots.



# Epic 5 – UI/UX Improvements & Navigation

Plan for the visual/interaction enhancements surfaced in the screenshots.

## Story 5.1 – Show Previous Session History
**Domain/Data**
- Extend workout persistence by storing prior session aggregates per exercise (last set history).
- Provide a query (e.g. `ExerciseHistoryProviding`) that fetches the most recent logged set for a given exercise.
**Presentation**
- Update exercise logging presenter/view models with a “previous” column. When history is absent, display `-`.
**Tests**
- Unit tests verifying history lookup + UI rendering.

## Story 5.2 – Workout Duration Tracking
**Domain**
- Add a timer orchestrator (`WorkoutDurationTracking`) that starts on workout start, stops on finish, and persists duration.
**Presentation**
- Always-visible timer view model for workout screens; start/stop tied to use cases.
**Tests**
- Timer tests (mock clock) + presenter tests for start/stop updates.

## Story 5.3 – Volume Counting
**Domain**
- Extend `WorkoutStats`/use cases to compute Σ(weight × reps).
- Ensure `SaveWorkoutAsRoutine`/finish flows use the updated stats.
**Presentation**
- Display volume on routine/summary views.
**Tests**
- Stats/ presenter tests verifying volume math.

## Story 5.4 – Ellipsis Menu for Exercise Actions
**Presentation**
- Surface 3-dot menu entries: Reorder, Replace, Remove from Superset, Remove Exercise. Leverage existing presenters/adapters to handle actions.
- Provide menu state view models.
**Tests**
- Menu action tests ensuring correct presenter/adapter invocations.

## Story 5.5 – Add Notes to Exercise
**Domain**
- Allow per-exercise notes during workout logging (persisted with workout, not routines unless converted).
**Data**
- Confirm `LocalExercise` notes already supported; ensure conversion flows respect requirement.
**Presentation**
- Input field under exercise name + binding to notes.
**Tests**
- Presenter tests ensuring notes are captured, persisted, and not carried into routines unless requested.

## Cross-Cutting
- Ensure history/timer/volume features integrate with existing logging flows & presenters.
