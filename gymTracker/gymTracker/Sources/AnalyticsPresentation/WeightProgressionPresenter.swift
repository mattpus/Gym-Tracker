import Foundation

public protocol WeightProgressionPresenterOutput: AnyObject {
    func display(_ viewModel: AnalyticsWeightProgressionViewModel)
}

public final class WeightProgressionPresenter {
    public weak var output: WeightProgressionPresenterOutput?
    private let dateFormatter: DateFormatter
    
    public init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "MMM d"
    }
    
    public func present(_ trend: WeightProgressionTrend) {
        let dataPoints = trend.dataPoints.map { point -> WeightChartPoint in
            WeightChartPoint(
                dateLabel: dateFormatter.string(from: point.date),
                weight: point.weight,
                weightText: formatWeight(point.weight),
                repsText: point.reps.map { "\($0) reps" }
            )
        }
        
        let trendText: String
        let trendDirection: TrendDirection
        
        switch trend.trend {
        case .increasing:
            let change = trend.percentageChange.map { String(format: "+%.1f%%", $0) } ?? ""
            trendText = "Progressing \(change)"
            trendDirection = .up
        case .decreasing:
            let change = trend.percentageChange.map { String(format: "%.1f%%", $0) } ?? ""
            trendText = "Declining \(change)"
            trendDirection = .down
        case .stable:
            trendText = "Maintaining"
            trendDirection = .stable
        case .insufficient:
            trendText = "Need more data"
            trendDirection = .unknown
        }
        
        let viewModel = AnalyticsWeightProgressionViewModel(
            exerciseName: trend.exerciseName,
            dataPoints: dataPoints,
            startingWeightText: trend.startingWeight.map { formatWeight($0) },
            currentWeightText: trend.currentWeight.map { formatWeight($0) },
            maxWeightText: trend.maxWeight.map { formatWeight($0) },
            trendText: trendText,
            trendDirection: trendDirection
        )
        
        output?.display(viewModel)
    }
    
    private func formatWeight(_ weight: Double) -> String {
        if weight == floor(weight) {
            return "\(Int(weight)) kg"
        }
        return String(format: "%.1f kg", weight)
    }
}
