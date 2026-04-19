import Foundation

public enum ExerciseSetType: String, CaseIterable, Codable, Equatable, Hashable, Sendable {
	case warmup
	case main
	case superset
	case backoff

	public var displayName: String {
		switch self {
		case .warmup: return "Warm-up"
		case .main: return "Main"
		case .superset: return "Superset"
		case .backoff: return "Back-off"
		}
	}
}
