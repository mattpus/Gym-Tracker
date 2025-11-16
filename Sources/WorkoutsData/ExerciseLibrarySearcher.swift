import Foundation
import WorkoutsDomain

public final class LocalExerciseLibrarySearcher: ExerciseLibrarySearching {
	private let items: [ExerciseLibraryItem]
	
	public enum Error: Swift.Error {
		case resourceNotFound
		case failedToLoad(Swift.Error)
	}
	
	public init(resourceName: String = "ExerciseLibrary", bundle: Bundle? = nil) throws {
		let resolvedBundle = bundle ?? .module
		guard let url = resolvedBundle.url(forResource: resourceName, withExtension: "json") else {
			throw Error.resourceNotFound
		}
		
		do {
			let data = try Data(contentsOf: url)
			let decoded = try JSONDecoder().decode([LocalExerciseLibraryItem].self, from: data)
			self.items = decoded.map { $0.toModel() }
		} catch {
			throw Error.failedToLoad(error)
		}
	}
	
	public func search(query: String, completion: @escaping (ExerciseLibrarySearching.Result) -> Void) {
		let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else {
			completion(.success([]))
			return
		}
		
		let matches = items.filter {
			$0.name.localizedCaseInsensitiveContains(trimmed)
				|| ($0.primaryMuscle?.localizedCaseInsensitiveContains(trimmed) ?? false)
		}
		completion(.success(matches))
	}
}

private struct LocalExerciseLibraryItem: Decodable {
	let id: UUID
	let name: String
	let primaryMuscle: String?
	
	func toModel() -> ExerciseLibraryItem {
		ExerciseLibraryItem(id: id, name: name, primaryMuscle: primaryMuscle)
	}
}
