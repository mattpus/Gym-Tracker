import SwiftUI

/// Home view with quick actions and overview
struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    let coordinator: HomeCoordinator
    
    var body: some View {
        AppScrollScreen {
            // Welcome Section
            welcomeSection
            
            // Quick Stats
            statsSection
            
            // Quick Actions
            quickActionsSection
            
            // Recent Workouts
            recentWorkoutsSection
        }
        .navigationTitle("Gym Tracker")
        .onAppear {
            viewModel.loadData()
        }
        .refreshable {
            viewModel.loadData()
        }
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greeting)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Ready to crush your workout?")
                .foregroundStyle(.secondary)
        }
       
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
    
    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Current Streak",
                value: "\(viewModel.currentStreak)",
                subtitle: "days",
                systemImage: "flame.fill",
                color: .orange
            )
            
            StatCard(
                title: "This Week",
                value: "\(viewModel.workoutsThisWeek)",
                subtitle: "workouts",
                systemImage: "calendar",
                color: .blue
            )
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Start")
                .font(.headline)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Start Workout",
                    systemImage: "plus.circle.fill",
                    color: .blue
                ) {
                    // Navigate to workouts tab and start workout
                }
                
                QuickActionButton(
                    title: "Browse Exercises",
                    systemImage: "dumbbell.fill",
                    color: .green
                ) {
                    // Navigate to exercise library
                }
            }
        }
    }
    
    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Workouts")
                    .font(.headline)
                Spacer()
                Button("See All") {
                    // Navigate to workouts tab
                }
                .font(.subheadline)
            }
            
            if viewModel.recentWorkouts.isEmpty {
                Text("No workouts yet")
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.recentWorkouts) { workout in
                        RecentWorkoutCard(workout: workout)
                    }
                }
            }
        }
    }
}

/// Card displaying a stat
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Quick action button
struct QuickActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

/// Card for recent workout
struct RecentWorkoutCard: View {
    let workout: WorkoutItemViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.headline)
                Text(workout.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(workout.formattedDuration)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("\(workout.exerciseCount) exercises")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
