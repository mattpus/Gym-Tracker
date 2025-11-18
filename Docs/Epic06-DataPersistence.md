# Epic 6 – Data & Persistence

Focus on ensuring workouts/supersets/notes are correctly saved and previous-session data is available for UI features.

## Story 6.1 – Save Completed Workouts
**Domain/Data**
- Ensure `WorkoutRepository` and `SaveWorkoutAsRoutineUseCase` persist all relevant fields (sets/reps/weight/duration, notes, supersets).
- Consider versioning/migrations if existing persisted data lacks superset metadata.
**Presentation**
- Extend finish workflows to signal save completions, exposing any errors to the user.
**Tests**
- Integration tests verifying full workout serialization including supersets & notes.

## Story 6.2 – Load Previous Workout Data
**Domain**
- Provide a history loader (`ExerciseHistoryProviding`) that fetches last logged workouts per exercise.
- Hook into exercise logging use case to fetch `previousSet` values.
**Data**
- Repository queries to fetch latest workout(s) per exercise ID with sorting by date.
**Presentation**
- Show “Previous: 33kg × 12” in exercise logging UI and summary.
**Tests**
- Domain tests covering history queries, presentation tests ensuring UI surfaces the data.

## Cross-Cutting
- Synchronize with Epic 5 (previous-session column, volume stats) and Epic 4 (supersets) to keep data model consistent.
