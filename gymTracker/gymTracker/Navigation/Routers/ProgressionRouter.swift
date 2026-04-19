import Foundation
import Observation

@Observable
@MainActor
final class ProgressionRouter {
    let navigation: NavigationRouter
    private let container: DependencyContainer
    private(set) var dashboardViewModel: ProgressionDashboardViewModel

    init(container: DependencyContainer, navigation: NavigationRouter) {
        self.container = container
        self.navigation = navigation
        self.dashboardViewModel = ProgressionDashboardViewModel(
            progressionRecommendationUseCase: container.progressionUseCaseFactory.makeProgressionRecommendationUseCase(),
            loadExerciseNames: { [container] in
                try container.progressionUseCaseFactory.loadTrackedExerciseNames()
            }
        )
    }

    func showExerciseProgression(exerciseName: String) {
        navigation.push(.exerciseProgression(exerciseName: exerciseName))
    }

    func makeExerciseProgressionViewModel(exerciseName: String) -> ExerciseProgressionViewModel {
        ExerciseProgressionViewModel(
            exerciseName: exerciseName,
            progressionRecommendationUseCase: container.progressionUseCaseFactory.makeProgressionRecommendationUseCase()
        )
    }
}
