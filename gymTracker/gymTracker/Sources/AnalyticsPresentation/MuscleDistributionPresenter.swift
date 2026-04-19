import Foundation

public protocol MuscleDistributionPresenterOutput: AnyObject {
    func display(_ viewModel: AnalyticsMuscleDistributionViewModel)
}

public final class MuscleDistributionPresenter {
    public weak var output: MuscleDistributionPresenterOutput?
    
    public init() {}
    
    public func present(_ distribution: MuscleGroupDistribution) {
        let maxPercentage = distribution.distribution.map(\.percentage).max() ?? 100
        
        let items = distribution.distribution.map { item -> MuscleDistributionItem in
            MuscleDistributionItem(
                muscleGroup: item.muscleGroup.capitalized,
                percentage: String(format: "%.1f%%", item.percentage),
                setCount: "\(item.setCount) sets",
                barWidth: maxPercentage > 0 ? item.percentage / maxPercentage : 0
            )
        }
        
        let viewModel = AnalyticsMuscleDistributionViewModel(
            items: items,
            mostTrained: distribution.mostTrainedMuscle?.capitalized,
            leastTrained: distribution.leastTrainedMuscle?.capitalized
        )
        
        output?.display(viewModel)
    }
}
