# Gym Tracker Repository Guide

## Overview
The Gym Tracker is a Swift Package Manager (SPM) based iOS/macOS application for tracking workouts and managing exercise routines. The project follows Clean Architecture principles with clear separation of concerns across three main modules.

## Project Structure

### Package Configuration (`Package.swift`)
- **Platform Support**: iOS 15+, macOS 13+
- **Architecture**: Modular SPM package with 3 main libraries
- **Dependencies**: No external dependencies (self-contained)

### Core Modules

#### 1. WorkoutsDomain (`Sources/WorkoutsDomain/`)
**Purpose**: Contains business logic, entities, and use cases (Clean Architecture's Domain Layer)

**Key Components**:
- **Entities**: `Workout`, `Exercise`, `ExerciseSet`, `Routine`, `RoutineExercise`
- **Use Cases**: 
  - Workout management: `StartEmptyWorkoutUseCase`, `FinishWorkoutUseCase`, `EditWorkoutUseCase`
  - Routine management: `CreateRoutineUseCase`, `LoadRoutinesUseCase`, `StartRoutineUseCase`
  - Exercise management: `ExerciseSetLoggingUseCase`, `UpdateExerciseNotesUseCase`
  - Superset management: `LinkExercisesToSupersetUseCase`, `RemoveExerciseFromSupersetUseCase`
- **Protocols**: Repository interfaces, service protocols (e.g., `WorkoutRepository`, `RoutineRepository`)
- **Domain Services**: `RestTimer`, `WorkoutDurationTracker`

**Key Features**:
- Workout session management with duration tracking
- Exercise set logging and progression tracking
- Routine creation and template management
- Superset functionality for linked exercises
- Exercise library search and history

#### 2. WorkoutsData (`Sources/WorkoutsData/`)
**Purpose**: Data persistence and external data sources (Clean Architecture's Data Layer)

**Key Components**:
- **Repositories**: `LocalWorkoutRepository`, `LocalRoutineRepository`
- **Data Models**: `LocalWorkout`, `LocalRoutine` (persistence models)
- **Core Data**: Database implementation for local storage
- **Services**: `ExerciseLibrarySearcher`, `LocalExerciseHistoryProvider`
- **Stores**: `WorkoutStore`, `RoutineStore` (data access layer)

#### 3. WorkoutsPresentation (`Sources/WorkoutsPresentation/`)
**Purpose**: UI presentation logic and ViewModels (Clean Architecture's Presentation Layer)

**Key Components**:
- **Presenters**: Business logic to UI adapters
- **View Models**: UI state management (`WorkoutsViewModels`, `RestTimerViewModels`, `FinishWorkoutViewModels`)
- **Adapters**: Bridge between use cases and presenters
- **Views**: UI component definitions (`WorkoutsViews`)

### Test Structure (`Tests/`)
- **WorkoutsDomainTests**: Unit tests for business logic
- **WorkoutsDataTests**: Integration tests for data layer
- **WorkoutsPresentationTests**: Tests for presentation logic
- **Test Plan**: `GymTracker-Package.xctestplan` for coordinated testing

### Documentation (`Docs/`)
Contains epic-based feature documentation:
- Epic02: Routine Management
- Epic03: Exercise Management  
- Epic04: Superset Management
- Epic05: UI/UX Improvements
- Epic06: Data Persistence

## Architecture Patterns

### Clean Architecture
- **Domain Layer** (WorkoutsDomain): Business rules, entities, use cases
- **Data Layer** (WorkoutsData): Data access, persistence, external services  
- **Presentation Layer** (WorkoutsPresentation): UI logic, view models, adapters

### Dependency Flow
```
Presentation → Domain ← Data
```
- Presentation depends on Domain
- Data depends on Domain  
- Domain has no dependencies (inverted dependency principle)

### Key Design Patterns
- **Use Case Pattern**: Each business operation is a separate use case class
- **Repository Pattern**: Abstract data access behind interfaces
- **Adapter Pattern**: Presentation adapters bridge use cases to UI
- **Observer Pattern**: Completion handlers for async operations

## Core Functionality

### Workout Management
- Create empty workouts or start from routines
- Track workout duration with real-time timer
- Log exercise sets with weight, reps, and notes
- Edit workout details and exercise order
- Save completed workouts

### Routine Management  
- Create reusable workout templates
- Load and start routines as workouts
- Reorder exercises within routines
- Save workouts as new routines

### Exercise Management
- Exercise library search functionality
- Exercise history tracking and progression
- Exercise notes and customization
- Replace exercises in workouts
- Remove exercises from workouts

### Superset Support
- Link multiple exercises into supersets
- Manage superset groupings
- Remove exercises from supersets
- Visual superset indicators

### Data Persistence
- Core Data integration for local storage
- Workout and routine persistence
- Exercise history tracking
- Offline-first approach

## Development Guidelines

### Module Dependencies
- Keep Domain layer dependency-free
- Data and Presentation layers depend only on Domain
- Use protocol interfaces for dependency inversion

### Testing Strategy
- Unit tests for Domain layer business logic
- Integration tests for Data layer persistence
- Presentation tests for UI logic and state management

### File Organization
- Group related functionality together
- Use clear, descriptive naming conventions
- Separate protocols from implementations
- Keep use cases focused and single-purpose

This repository represents a well-structured iOS/macOS fitness tracking application built with modern Swift development practices and Clean Architecture principles.