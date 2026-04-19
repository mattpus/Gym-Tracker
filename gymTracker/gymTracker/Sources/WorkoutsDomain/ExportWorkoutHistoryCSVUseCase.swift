import Foundation

public protocol WorkoutHistoryExporting {
	func exportCSV() throws -> String
}

public final class ExportWorkoutHistoryCSVUseCase: WorkoutHistoryExporting {
	private let repository: WorkoutRepository
	private let dateFormatter: ISO8601DateFormatter

	public init(repository: WorkoutRepository) {
		self.repository = repository
		self.dateFormatter = ISO8601DateFormatter()
	}

	public func exportCSV() throws -> String {
		let workouts = try repository.loadWorkouts()
			.filter(\.isFinished)
			.sorted { $0.date < $1.date }

		var rows = [
			[
				"workout_date",
				"workout_name",
				"exercise_name",
				"set_order",
				"set_type",
				"reps",
				"weight",
				"completed"
			].joined(separator: ",")
		]

		for workout in workouts {
			for exercise in workout.exercises {
				for set in exercise.sets.sorted(by: { $0.order < $1.order }) {
					rows.append([
						escape(dateFormatter.string(from: workout.date)),
						escape(workout.name),
						escape(exercise.name),
						String(set.order + 1),
						escape(set.type.rawValue),
						set.repetitions.map(String.init) ?? "",
						set.weight.map { String($0) } ?? "",
						set.isCompleted ? "true" : "false"
					].joined(separator: ","))
				}
			}
		}

		return rows.joined(separator: "\n")
	}

	private func escape(_ value: String) -> String {
		let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
		return "\"\(escaped)\""
	}
}
