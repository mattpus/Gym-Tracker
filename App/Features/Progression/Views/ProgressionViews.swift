import SwiftUI

/// Progression Dashboard view
struct ProgressionDashboardView: View {
    @Bindable var viewModel: ProgressionDashboardViewModel
    let coordinator: ProgressionCoordinator
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if let error = viewModel.error {
                    ContentUnavailableView {
                        Label("Unable to Load Progress", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error.localizedDescription)
                    }
                } else if viewModel.recommendations.isEmpty {
                    emptyStateView
                } else {
                    recommendationsSection
                }
            }
            .padding()
        }
        .navigationTitle("Progress")
        .onAppear {
            viewModel.loadData()
        }
        .refreshable {
            viewModel.loadData()
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Recommendations Yet", systemImage: "chart.line.uptrend.xyaxis")
        } description: {
            Text("Complete more workouts to get personalized progression recommendations.")
        }
    }
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommendations")
                .font(.headline)
            
            ForEach(viewModel.recommendations) { recommendation in
                ProgressionCard(recommendation: recommendation) {
                    coordinator.showExerciseProgression(exerciseName: recommendation.exerciseName)
                }
            }
        }
    }
}

struct ProgressionCard: View {
    let recommendation: ProgressionRecommendationItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(recommendation.exerciseName)
                        .font(.headline)
                    Spacer()
                    confidenceBadge
                }
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(currentSummary)
                            .font(.subheadline)
                    }
                    
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recommended")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(recommendedSummary)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(recommendation.hasWeightIncrease ? .green : .primary)
                    }
                }
                
                Text(recommendation.reasoning)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    private var currentSummary: String {
        if recommendation.currentWeight > 0 {
            return "\(recommendation.currentWeight, specifier: "%.1f") kg × \(recommendation.currentReps)"
        }
        return "Baseline needed"
    }
    
    private var recommendedSummary: String {
        if recommendation.recommendedWeight > 0 {
            return "\(recommendation.recommendedWeight, specifier: "%.1f") kg × \(recommendation.recommendedReps)"
        }
        return "\(recommendation.recommendedReps) reps"
    }
    
    private var confidenceBadge: some View {
        Text(recommendation.confidence.rawValue.capitalized)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.secondary.opacity(0.12))
            .clipShape(Capsule())
    }
}

/// Exercise-specific progression view
struct ExerciseProgressionView: View {
    @Bindable var viewModel: ExerciseProgressionViewModel
    let coordinator: ProgressionCoordinator
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let recommendation = viewModel.recommendation {
                List {
                    Section("Recommendation") {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Current")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(currentSummary(for: recommendation))
                                        .font(.title3)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "arrow.right")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("Next")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(recommendedSummary(for: recommendation))
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(recommendation.hasWeightIncrease ? .green : .primary)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Section("Why This Recommendation") {
                        Text(recommendation.reasoning)
                            .foregroundStyle(.secondary)
                    }
                    
                    Section("Confidence") {
                        Text(recommendation.confidence.rawValue.capitalized)
                    }
                    
                    if recommendation.hasWeightIncrease {
                        Section {
                            Label(
                                "+\(recommendation.weightChange, specifier: "%.1f") kg increase",
                                systemImage: "arrow.up.circle.fill"
                            )
                            .foregroundStyle(.green)
                        }
                    }
                }
            } else {
                ContentUnavailableView {
                    Label("No Data", systemImage: "chart.line.uptrend.xyaxis")
                } description: {
                    Text("Not enough history for this exercise")
                }
            }
        }
        .navigationTitle("Exercise Progression")
        .onAppear {
            viewModel.loadData()
        }
    }
    
    private func currentSummary(for recommendation: ProgressionRecommendationItem) -> String {
        if recommendation.currentWeight > 0 {
            return "\(recommendation.currentWeight, specifier: "%.1f") kg × \(recommendation.currentReps) reps"
        }
        return "Baseline needed"
    }
    
    private func recommendedSummary(for recommendation: ProgressionRecommendationItem) -> String {
        if recommendation.recommendedWeight > 0 {
            return "\(recommendation.recommendedWeight, specifier: "%.1f") kg × \(recommendation.recommendedReps) reps"
        }
        return "\(recommendation.recommendedReps) reps"
    }
}
