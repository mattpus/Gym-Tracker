import SwiftUI

/// Analytics Dashboard view
struct AnalyticsDashboardView: View {
    @Bindable var viewModel: AnalyticsDashboardViewModel
    let coordinator: AnalyticsCoordinator
    
    var body: some View {
        AppScrollScreen {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            } else {
                // Weekly Insights
                if let insights = viewModel.weeklyInsights {
                    weeklyInsightsSection(insights)
                }
                
                // Workout Frequency
                if let frequency = viewModel.workoutFrequency {
                    frequencySection(frequency)
                }
                
                // Muscle Distribution
                if !viewModel.muscleDistribution.isEmpty {
                    muscleDistributionSection
                }
            }
        }
        .navigationTitle("Analytics")
        .onAppear {
            viewModel.loadData()
        }
        .refreshable {
            viewModel.loadData()
        }
    }
    
    private func weeklyInsightsSection(_ insights: WeeklyInsightsData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)
            
            HStack(spacing: 16) {
                InsightCard(
                    title: "Volume",
                    value: "\(Int(insights.totalVolume)) kg",
                    change: insights.volumeChange
                )
                
                InsightCard(
                    title: "Workouts",
                    value: "\(insights.workoutCount)",
                    change: nil
                )
            }
        }
    }
    
    private func frequencySection(_ frequency: WorkoutFrequencyData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Workout Frequency")
                    .font(.headline)
                Spacer()
                Button("Details") {
                    coordinator.showWorkoutFrequency()
                }
                .font(.subheadline)
            }
            
            HStack(spacing: 16) {
                FrequencyCard(
                    title: "Current Streak",
                    value: "\(frequency.currentStreak)",
                    unit: "days",
                    systemImage: "flame.fill",
                    color: .orange
                )
                
                FrequencyCard(
                    title: "This Month",
                    value: "\(frequency.workoutsThisMonth)",
                    unit: "workouts",
                    systemImage: "calendar",
                    color: .blue
                )
            }
        }
    }
    
    private var muscleDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Muscle Distribution")
                    .font(.headline)
                Spacer()
                Button("Details") {
                    coordinator.showMuscleDistribution()
                }
                .font(.subheadline)
            }
            
            VStack(spacing: 8) {
                ForEach(viewModel.muscleDistribution.prefix(5)) { group in
                    MuscleGroupRow(group: group)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let change: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            if let change {
                HStack(spacing: 2) {
                    Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text("\(abs(change), specifier: "%.1f")%")
                }
                .font(.caption)
                .foregroundStyle(change >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct FrequencyCard: View {
    let title: String
    let value: String
    let unit: String
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
                Text(unit)
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

struct MuscleGroupRow: View {
    let group: MuscleGroupData
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(group.name)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(group.percentage))%")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.secondary.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.blue)
                        .frame(width: geometry.size.width * (group.percentage / 100))
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Detail Views

struct WorkoutFrequencyView: View {
    @Bindable var viewModel: WorkoutFrequencyViewModel
    
    var body: some View {
        List {
            if let data = viewModel.data {
                Section("Streaks") {
                    LabeledContent("Current Streak", value: "\(data.currentStreak) days")
                    LabeledContent("Longest Streak", value: "\(data.longestStreak) days")
                }
                
                Section("Activity") {
                    LabeledContent("This Week", value: "\(data.workoutsThisWeek) workouts")
                    LabeledContent("This Month", value: "\(data.workoutsThisMonth) workouts")
                    LabeledContent("Total", value: "\(data.totalWorkouts) workouts")
                }
            }
        }
        .navigationTitle("Workout Frequency")
        .onAppear { viewModel.loadData() }
    }
}

struct MuscleDistributionView: View {
    @Bindable var viewModel: MuscleDistributionViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.groups) { group in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(group.name)
                            .font(.headline)
                        Spacer()
                        Text("\(group.setCount) sets")
                            .foregroundStyle(.secondary)
                    }
                    
                    ProgressView(value: group.percentage / 100)
                        .tint(.blue)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Muscle Distribution")
        .onAppear { viewModel.loadData() }
    }
}

struct WeightProgressionView: View {
    @Bindable var viewModel: WeightProgressionViewModel
    
    var body: some View {
        List {
            if !viewModel.dataPoints.isEmpty {
                Section("Trend") {
                    Text(viewModel.trend)
                        .foregroundStyle(.secondary)
                }
                
                Section("History") {
                    ForEach(viewModel.dataPoints) { point in
                        HStack {
                            Text(point.date, style: .date)
                            Spacer()
                            Text("\(point.weight, specifier: "%.1f") kg")
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
        .navigationTitle("Weight Progression")
        .onAppear { viewModel.loadData() }
    }
}

struct VolumeProgressionView: View {
    @Bindable var viewModel: VolumeProgressionViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.dataPoints) { point in
                HStack {
                    Text(point.date, style: .date)
                    Spacer()
                    Text("\(Int(point.volume)) kg")
                        .fontWeight(.medium)
                }
            }
        }
        .navigationTitle("Volume Progression")
        .onAppear { viewModel.loadData() }
    }
}

struct RecoveryView: View {
    @Bindable var viewModel: RecoveryViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.muscleGroupRecovery) { muscle in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(muscle.name)
                            .font(.headline)
                        Spacer()
                        Text("\(Int(muscle.recoveryPercentage))%")
                            .foregroundStyle(recoveryColor(muscle.recoveryPercentage))
                    }
                    
                    ProgressView(value: muscle.recoveryPercentage / 100)
                        .tint(recoveryColor(muscle.recoveryPercentage))
                    
                    if let lastTrained = muscle.lastTrained {
                        Text("Last trained: \(lastTrained, style: .relative) ago")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Recovery Status")
        .onAppear { viewModel.loadData() }
    }
    
    private func recoveryColor(_ percentage: Double) -> Color {
        switch percentage {
        case 0..<50: return .red
        case 50..<80: return .orange
        default: return .green
        }
    }
}
