import Foundation
import AnalyticsDomain

public protocol RecoveryPresenterOutput: AnyObject {
    func display(_ viewModel: RecoveryViewModel)
}

public final class RecoveryPresenter {
    public weak var output: RecoveryPresenterOutput?
    private let dateFormatter: DateFormatter
    
    public init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateStyle = .short
    }
    
    public func present(_ insight: RecoveryInsight) {
        let muscleStatuses = insight.muscleGroupRecovery.map { status -> MuscleRecoveryViewModel in
            let statusText: String
            let color: RecoveryColor
            
            switch status.recoveryStatus {
            case .fullyRecovered:
                statusText = "Ready to train"
                color = .green
            case .mostlyRecovered:
                statusText = "Almost recovered"
                color = .yellow
            case .recovering:
                statusText = "Still recovering"
                color = .orange
            case .recentlyTrained:
                statusText = "Just trained"
                color = .red
            case .neverTrained:
                statusText = "Never trained"
                color = .gray
            }
            
            let lastTrainedText: String?
            if let date = status.lastTrainedDate {
                if let days = status.daysSinceTraining, days == 0 {
                    lastTrainedText = "Today"
                } else if let days = status.daysSinceTraining, days == 1 {
                    lastTrainedText = "Yesterday"
                } else {
                    lastTrainedText = dateFormatter.string(from: date)
                }
            } else {
                lastTrainedText = nil
            }
            
            return MuscleRecoveryViewModel(
                muscleGroup: status.muscleGroup.capitalized,
                statusText: statusText,
                statusColor: color,
                lastTrainedText: lastTrainedText
            )
        }
        
        let readyCount = insight.fullyRecoveredMuscles.count
        let recoveringCount = insight.recoveringMuscles.count
        
        let viewModel = RecoveryViewModel(
            muscleStatuses: muscleStatuses,
            readyToTrainText: "\(readyCount) muscle groups ready",
            needsRestText: "\(recoveringCount) still recovering"
        )
        
        output?.display(viewModel)
    }
}
