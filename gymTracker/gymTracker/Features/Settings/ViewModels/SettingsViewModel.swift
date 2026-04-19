import Foundation
import Observation

/// ViewModel for Settings
@Observable
@MainActor
final class SettingsViewModel {
    var appVersion: String = "1.0.0"
    var buildNumber: String = "1"
    
    init() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = version
        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildNumber = build
        }
    }
}
