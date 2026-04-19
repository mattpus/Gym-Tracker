import SwiftUI
import Observation

@Observable
@MainActor
final class MainRouter {
    var selectedTab: AppTab = .home

    private let container: DependencyContainer
    let homeRouter: HomeRouter
    let workoutsRouter: WorkoutsRouter
    let analyticsRouter: AnalyticsRouter
    let progressionRouter: ProgressionRouter
    let settingsRouter: SettingsRouter

    init(container: DependencyContainer) {
        self.container = container

        let homeNavigation = NavigationRouter(level: 1, tab: .home)
        let workoutsNavigation = NavigationRouter(level: 1, tab: .workouts)
        let analyticsNavigation = NavigationRouter(level: 1, tab: .analytics)
        let progressionNavigation = NavigationRouter(level: 1, tab: .progression)
        let settingsNavigation = NavigationRouter(level: 1, tab: .settings)

        self.homeRouter = HomeRouter(container: container, navigation: homeNavigation)
        self.workoutsRouter = WorkoutsRouter(container: container, navigation: workoutsNavigation)
        self.analyticsRouter = AnalyticsRouter(container: container, navigation: analyticsNavigation)
        self.progressionRouter = ProgressionRouter(container: container, navigation: progressionNavigation)
        self.settingsRouter = SettingsRouter(container: container, navigation: settingsNavigation)

        for navigation in [homeNavigation, workoutsNavigation, analyticsNavigation, progressionNavigation, settingsNavigation] {
            navigation.mainRouter = self
        }
        homeRouter.mainRouter = self
    }

    @ViewBuilder
    func rootView() -> some View {
        MainRouterView(router: self)
    }

    @ViewBuilder
    func tabRootView(for tab: AppTab) -> some View {
        switch tab {
        case .home:
            HomeView(viewModel: homeRouter.homeViewModel, router: homeRouter)
        case .workouts:
            WorkoutsListView(viewModel: workoutsRouter.workoutsListViewModel, router: workoutsRouter)
                .onAppear { self.workoutsRouter.contentDidAppear() }
                .onDisappear { self.workoutsRouter.contentDidDisappear() }
        case .analytics:
            AnalyticsDashboardView(viewModel: analyticsRouter.dashboardViewModel, router: analyticsRouter)
        case .progression:
            ProgressionDashboardView(viewModel: progressionRouter.dashboardViewModel, router: progressionRouter)
        case .settings:
            SettingsView(viewModel: settingsRouter.settingsViewModel, router: settingsRouter)
        }
    }

    func navigationRouter(for tab: AppTab) -> NavigationRouter {
        switch tab {
        case .home: return homeRouter.navigation
        case .workouts: return workoutsRouter.navigation
        case .analytics: return analyticsRouter.navigation
        case .progression: return progressionRouter.navigation
        case .settings: return settingsRouter.navigation
        }
    }

    @ViewBuilder
    func view(for destination: PushDestination) -> some View {
        switch destination {
        case .exerciseLibrary:
            ExerciseLibraryView(viewModel: homeRouter.exerciseLibraryViewModel, router: homeRouter)
        case .exerciseDetail(let id):
            ExerciseDetailView(viewModel: homeRouter.makeExerciseDetailViewModel(exerciseId: id), router: homeRouter)
        case .workoutDetail(let id):
            WorkoutDetailView(viewModel: workoutsRouter.makeWorkoutDetailViewModel(workoutId: id), router: workoutsRouter)
        case .workoutFrequency:
            WorkoutFrequencyView(viewModel: analyticsRouter.makeWorkoutFrequencyViewModel())
        case .muscleDistribution:
            MuscleDistributionView(viewModel: analyticsRouter.makeMuscleDistributionViewModel())
        case .weightProgression(let exerciseName):
            WeightProgressionView(viewModel: analyticsRouter.makeWeightProgressionViewModel(exerciseName: exerciseName))
        case .volumeProgression:
            VolumeProgressionView(viewModel: analyticsRouter.makeVolumeProgressionViewModel())
        case .recovery:
            RecoveryView(viewModel: analyticsRouter.makeRecoveryViewModel())
        case .exerciseProgression(let exerciseName):
            ExerciseProgressionView(viewModel: progressionRouter.makeExerciseProgressionViewModel(exerciseName: exerciseName), router: progressionRouter)
        case .appearanceSettings:
            AppearanceSettingsView()
        case .notificationSettings:
            NotificationSettingsView()
        case .dataSettings:
            DataSettingsView(viewModel: settingsRouter.makeDataSettingsViewModel())
        case .about:
            AboutView()
        }
    }

    @ViewBuilder
    func view(for destination: SheetDestination) -> some View {
        switch destination {
        case .routineSelection:
            RoutineSelectionView(viewModel: workoutsRouter.makeRoutineSelectionViewModel(), router: workoutsRouter)
        case .exerciseSelection(let context):
            exerciseSelectionView(for: context)
        case .routineBuilder:
            if let viewModel = workoutsRouter.routineBuilderViewModel {
                RoutineBuilderView(viewModel: viewModel, router: workoutsRouter)
            } else {
                MissingPresentationView(title: "No Routine Builder")
            }
        case .routineBuilderExerciseSelection:
            exerciseSelectionView(for: .routineBuilder)
        case .addCustomExercise:
            AddCustomExerciseView(viewModel: homeRouter.makeAddCustomExerciseViewModel(), router: homeRouter)
        case .editCustomExercise:
            if let exercise = homeRouter.editingExercise {
                EditCustomExerciseView(viewModel: homeRouter.makeEditCustomExerciseViewModel(exercise: exercise), router: homeRouter)
            } else {
                MissingPresentationView(title: "No Exercise Selected")
            }
        }
    }

    @ViewBuilder
    func view(for destination: FullScreenDestination) -> some View {
        switch destination {
        case .activeWorkout:
            if let viewModel = workoutsRouter.activeWorkoutViewModel {
                ActiveWorkoutView(viewModel: viewModel, router: workoutsRouter)
            } else {
                MissingPresentationView(title: "No Active Workout")
            }
        }
    }

    @ViewBuilder
    private func exerciseSelectionView(for context: ExerciseSelectionContext) -> some View {
        if let viewModel = workoutsRouter.exerciseSelectionViewModel {
            ExerciseSelectionView(viewModel: viewModel) { exercise in
                switch context {
                case .activeWorkout:
                    self.workoutsRouter.addExerciseToActiveWorkout(exercise)
                case .routineBuilder:
                    self.workoutsRouter.addExerciseToRoutineBuilder(exercise)
                }
            }
        } else {
            MissingPresentationView(title: "No Exercise Selection")
        }
    }
}

struct MainRouterView: View {
    @Bindable var router: MainRouter

    var body: some View {
        TabView(selection: $router.selectedTab) {
            ForEach(AppTab.allCases) { tab in
                NavigationContainer(mainRouter: router, router: router.navigationRouter(for: tab)) {
                    router.tabRootView(for: tab)
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.systemImage)
                }
                .tag(tab)
            }
        }
        .modifier(AdaptiveTabShellStyle())
    }
}

private struct AdaptiveTabShellStyle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content.tabViewStyle(.sidebarAdaptable)
        } else {
            content
        }
    }
}

private struct MissingPresentationView: View {
    let title: String

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: "exclamationmark.triangle")
        } description: {
            Text("Unable to load this screen.")
        }
    }
}
