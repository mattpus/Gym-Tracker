# GymTracker Implementation Plan

## Goal

Ship a stable local-first workout tracker where the user can create routines, manage custom exercises, log workouts, edit history, export history, and clear workout data without losing routines or exercise definitions.

## Architecture Direction

### Keep

- domain models and use cases in `gymTracker/Sources/*Domain`
- repository and provider protocols as the stable boundary
- Core Data as the local implementation
- dependency injection via `gymTracker/CompositionRoot/DependencyContainer.swift`

### Avoid for Now

- switching to SwiftData
- embedding remote concerns into views or feature view models
- designing full sync behavior before core local flows are finished

## Core Data Strategy

Use Core Data as the production local store for:

- workout history
- active workout drafts
- routines
- custom exercises

Keep bundled exercise seed data as app resources and merge it with custom exercises at repository level as needed.

## Future-Ready Boundary

Prepare for remote later by keeping these layers separate:

- domain use cases
- local repositories
- future remote repositories
- future query/data-provider adapters

When analytics or API work starts later, the change should happen in the data layer, not in feature views.

## Delivery Phases

## Phase 1: Persistence Model Cleanup

Define and stabilize the local storage model for:

- workout
- workout exercise
- workout set
- active workout state
- routine
- routine exercise
- routine set template
- custom exercise

Key decisions:

- set type is stored explicitly
- reps and weight are stored as primary tracked values
- completed state is stored explicitly
- previous values are derived rather than treated as primary source-of-truth fields

## Phase 2: Routine Management

Implement and verify:

- create routine
- edit routine
- delete routine
- default 3 sets for new routine exercises
- routine persistence

Expected result:

- users can define reusable plans before starting workouts

## Phase 3: Custom Exercise Management

Implement and verify:

- create custom exercise
- edit custom exercise
- delete custom exercise
- custom exercise visibility inside the selection/search flows
- historical preservation when a custom exercise is deleted later

Expected result:

- users are not blocked by a limited bundled exercise library

## Phase 4: Active Workout Flow

Implement and verify:

- start empty workout
- start workout from routine
- add/remove/reorder exercises
- add/remove/reorder sets
- edit set values
- set type selection
- rest timer
- local autosave of the active workout

Expected result:

- the user can fully log a session on-device

## Phase 5: Workout Completion and Recovery

Implement and verify:

- finish workout
- discard workout
- automatic completion after 2 hours of inactivity
- persistence recovery rules for previously active workouts

Expected result:

- unfinished workouts never disappear silently
- abandoned workouts do not remain active indefinitely

## Phase 6: Workout History and Editing

Implement and verify:

- workout history list
- workout detail view
- edit finished workout
- persistence updates after editing finished workouts

Expected result:

- the user can correct logged data after the fact

## Phase 7: Settings Actions

Implement and verify:

- CSV export of workout history
- delete workout history only
- confirmation flows for destructive actions

Expected result:

- users can extract their data for Excel and AI workflows
- users can clear workout history without losing routines or exercise definitions

## Phase 8: Analytics Placeholder Wiring

Only after the core flows are stable:

- make analytics detail buttons navigate to detailed views
- keep analytics implementation minimal if underlying logic is not yet prioritized
- avoid overbuilding analytics before workout tracking is solid

## Button Scope Plan

Every existing button in the current app should be classified and completed as one of:

- fully implemented local action
- fully implemented navigation action
- explicit deferred placeholder with clear UX copy

The goal is that no visible button feels dead or misleading.

## Technical Notes

### Previous Weight and Reps

Recommended approach:

- derive previous values from prior workout history
- do not treat previous values as authoritative stored workout-set fields

### Superset v1 Limitation

For now, `superset` is only a set type.

This means:

- easy local logging now
- limited future understanding of exact exercise-to-exercise superset relationships

This is acceptable for the first core version.

### Export Shape

The CSV should be flat and row-per-set.

Recommended minimum columns:

- workout_date
- workout_name
- exercise_name
- is_custom_exercise
- set_order
- set_type
- reps
- weight
- completed

Optional columns if cheap to include:

- routine_name
- exercise_order
- notes

