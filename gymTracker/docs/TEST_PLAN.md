# GymTracker Test Plan

## Goal

Build confidence in the domain logic and the core local workout flows before expanding analytics or remote capabilities.

## Testing Priorities

Priority order:

1. core domain use cases
2. repository-backed local behavior
3. feature view model action behavior
4. critical UI flows

## Unit Test Scope

## 1. Workouts Domain

This is the highest priority test area.

Target files include use cases and logic around:

- creating routines
- starting empty workouts
- starting workouts from routines
- saving workouts as routines
- editing workouts
- deleting workouts
- finishing workouts
- logging sets
- updating exercise notes
- reordering exercises
- removing exercises
- replacing exercises
- linking and unlinking superset-related actions if still in active use
- workout statistics calculations
- routine reordering

Test categories:

- happy path
- invalid input handling
- failure propagation from repositories
- mutation correctness
- ordering correctness
- editing previously saved data

## 2. Exercise Library Domain

Test:

- loading exercise library
- searching exercise library
- adding custom exercises
- editing custom exercises
- repository interaction rules

Important behavior:

- custom exercises should behave consistently with bundled exercises in selection flows

## 3. Progression Domain

Test:

- recommendation mapping
- progression service interaction
- fallback logic where applicable

This is lower priority than workout tracking but still belongs in unit coverage.

## 4. Analytics Domain

Test:

- workout frequency calculations
- volume progression calculations
- weight progression calculations
- recovery calculations
- weekly insights generation
- muscle group distribution calculations

Analytics tests are important, but implementation effort should follow the core workout flows.

## Test Doubles

Create reusable local test doubles for:

- workout repositories
- routine repositories
- exercise history repositories
- workout data repositories
- exercise library repositories
- progression services

Use these to test domain behavior in isolation from Core Data.

## Feature-Level Tests

After core domain tests exist, add focused tests for feature view models and coordinators that back the visible app actions.

High-value targets:

- `gymTracker/Features/Workouts/ViewModels/WorkoutsListViewModel.swift`
- `gymTracker/Features/Workouts/ViewModels/ActiveWorkoutViewModel.swift`
- `gymTracker/Features/Workouts/ViewModels/RoutineBuilderViewModel.swift`
- `gymTracker/Features/Workouts/ViewModels/ExerciseSelectionViewModel.swift`
- `gymTracker/Features/ExerciseLibrary/ViewModels/ExerciseLibraryViewModels.swift`
- settings-related action handlers once export/delete are implemented

## UI Test Scope

Keep UI tests small and focused on critical paths.

Recommended UI flows:

- create a routine
- start a workout from a routine
- start an empty workout
- add exercises and log sets
- finish a workout
- edit a finished workout
- export workout history
- delete workout history only

UI tests should prove the main app path works, not duplicate every unit test.

## Out of Scope for Early Testing

- exhaustive analytics UI testing
- remote sync behavior
- large snapshot test suites

## Completion Definition

The test plan is successful when:

- all core domain use cases have unit coverage
- the main local workout flows are covered by a small number of UI tests
- destructive settings actions are verified
- regressions in logging, editing, and persistence are easy to catch

