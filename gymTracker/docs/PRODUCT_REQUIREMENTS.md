# GymTracker Product Requirements

## Product Direction

- The app is offline-first.
- The app is single-user and local-only for now.
- Local persistence is the source of truth.
- Core Data is the current persistence strategy.
- Remote/API support is a future concern and should be added behind repository or data-provider boundaries.

## Current Product Focus

The immediate goal is core workout tracking functionality:

- create routines
- create custom exercises
- start workouts from a routine
- start empty workouts
- log and edit workout data locally
- review saved workout history
- export workout history

Analytics and progression are intentionally lower priority for now.

## Persistence Rules

- Workouts are stored locally.
- Active workouts are stored locally.
- Routines are stored locally.
- Custom exercises are stored locally.
- Seeded/default exercise library data remains available locally.
- Settings remain local.

## Delete All Data

`Delete All Data` currently means deleting workout data only.

It should delete:

- completed workout history
- active and in-progress workouts

It should keep:

- routines
- custom exercises
- seeded/default exercise library
- settings/preferences

## Exercise Library

- Custom exercises are in scope.
- Custom exercises should use the same fields as bundled exercises.
- Custom exercises can be edited.
- Custom exercises can be deleted.
- Deleting a custom exercise must not alter historical workout records that already used it.

## Routines

- Routines are in scope.
- Routines should include default sets.
- New routine exercises should default to 3 sets.
- Routines remain separate from workout history.
- Deleting workout history must not delete routines.

## Workouts

- Users can start an empty workout.
- Users can start a workout from a routine.
- Finished workouts can be edited.
- Active workouts should be auto-saved.
- Active workouts should auto-finish after 2 hours of inactivity.

## Inactivity Rule

- Timeout: 2 hours.
- Intended behavior: an abandoned active workout should not remain active forever.
- Final implementation should favor preserving user-entered data over discarding it.

## Sets

Each set should support at least:

- set type
- reps
- weight
- completed or not completed state
- ordering within the exercise

### Set Types for v1

- warmup
- main
- superset
- backoff

## Supersets

For v1, a superset is treated as a set type only.

- We do not need to track which exercises are linked together in a superset.
- We only need to know that a set was logged as a `superset` type.

This is an intentional simplification for the first version.

## Export

- Export format should be CSV.
- Export should be one flat file.
- Export should use one row per set.
- Export should prioritize workout date and logged set data.

### Export Priorities

Most important export fields:

- workout date
- exercise name
- weight
- reps
- set amount via row-per-set export

Less important for now:

- workout duration
- auto-finish status

## Analytics and Progression

- Analytics is not the first implementation focus.
- Progression should later be derived from analytics-oriented data access.
- Analytics should not know whether the underlying data came from local or remote sources.
- A future data-provider or adapter layer should isolate that choice.

## Non-Goals for This Phase

- remote sync
- API-backed storage
- scheduling/calendar workflows
- advanced analytics depth beyond basic placeholders/navigation

