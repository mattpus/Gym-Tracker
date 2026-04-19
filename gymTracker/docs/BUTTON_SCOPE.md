# GymTracker Button Scope

## Goal

Every button currently visible in the app should either:

- perform a working local action
- navigate to a working local screen
- clearly indicate an intentional deferment

No visible button should feel dead.

## Current Core Priority

Focus first on the buttons that support workout data collection.

## High Priority Button Areas

## Workouts

Files:

- `gymTracker/Features/Workouts/Views/WorkoutsListView.swift`
- `gymTracker/Features/Workouts/Views/RoutineSelectionView.swift`
- `gymTracker/Features/Workouts/Views/RoutineBuilderView.swift`
- `gymTracker/Features/Workouts/Views/ExerciseSelectionView.swift`
- `gymTracker/Features/Workouts/Views/ActiveWorkoutView.swift`
- `gymTracker/Features/Workouts/Views/WorkoutDetailView.swift`

These buttons should support:

- create routine
- cancel routine creation
- save routine
- start workout
- cancel workout selection flows
- finish workout
- discard workout
- continue workout entry
- skip timer actions where applicable
- exercise selection and add flows

## Exercise Library

Files:

- `gymTracker/Features/ExerciseLibrary/Views/ExerciseLibraryViews.swift`

These buttons should support:

- open add/edit custom exercise flows
- cancel and save custom exercise forms

## Settings

Files:

- `gymTracker/Features/Settings/Views/SettingsViews.swift`

These buttons should support:

- export CSV
- delete workout history only
- confirmation handling for destructive action

## Lower Priority for Now

## Analytics

Files:

- `gymTracker/Features/Analytics/Views/AnalyticsViews.swift`

Current requirement:

- detail buttons should at least navigate to detailed local views
- full analytics depth is not first priority

## Home

Files:

- `gymTracker/Features/Home/Views/HomeView.swift`

Current requirement:

- buttons should route to working screens that support the core workout flows

## Acceptance Rule

For this phase, a button is considered complete if:

- it works against local data correctly
- or it clearly routes into the working local flow

For this phase, a button is not complete if:

- it does nothing
- it silently fails
- it opens a screen that cannot complete the intended action

