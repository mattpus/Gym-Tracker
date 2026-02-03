import Foundation
import AnalyticsDomain

public protocol VolumeProgressionPresenterOutput: AnyObject {
    func display(_ viewModel: VolumeProgressionViewModel)
}

public final class VolumeProgressionPresenter {
    public weak var output: VolumeProgressionPresenterOutput?
    private let dateFormatter: DateFormatter
    private let numberFormatter: NumberFormatter
    
    public init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "MMM d"
        
        self.numberFormatter = NumberFormatter()
        self.numberFormatter.numberStyle = .decimal
        self.numberFormatter.maximumFractionDigits = 0
    }
    
    public func present(_ trend: VolumeProgressionTrend) {
        let dataPoints = trend.dataPoints.map { point -> VolumeChartPoint in
            VolumeChartPoint(
                dateLabel: dateFormatter.string(from: point.date),
                volume: point.volume,
                volumeText: formatVolume(point.volume)
            )
        }
        
        let trendText: String
        let trendDirection: TrendDirection
        
        switch trend.trend {
        case .increasing:
            let change = trend.percentageChange.map { String(format: "+%.1f%%", $0) } ?? ""
            trendText = "Increasing \(change)"
            trendDirection = .up
        case .decreasing:
            let change = trend.percentageChange.map { String(format: "%.1f%%", $0) } ?? ""
            trendText = "Decreasing \(change)"
            trendDirection = .down
        case .stable:
            trendText = "Stable"
            trendDirection = .stable
        case .insufficient:
            trendText = "Need more data"
            trendDirection = .unknown
        }
        
        let viewModel = VolumeProgressionViewModel(
            dataPoints: dataPoints,
            totalVolumeText: formatVolume(trend.totalVolume),
            averageVolumeText: formatVolume(trend.averageVolumePerWorkout),
            trendText: trendText,
            trendDirection: trendDirection
        )
        
        output?.display(viewModel)
    }
    
    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000 {
            return String(format: "%.1fk kg", volume / 1000)
        }
        return "\(Int(volume)) kg"
    }
}
