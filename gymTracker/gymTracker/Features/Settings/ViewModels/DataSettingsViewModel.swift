import Foundation
import Observation

@Observable
@MainActor
final class DataSettingsViewModel {
	var exportCSV: String?
	var isExporting = false
	var isDeleting = false
	var lastErrorMessage: String?

	private let exportUseCase: WorkoutHistoryExporting
	private let deleteHistoryUseCase: WorkoutHistoryDeleting

	init(exportUseCase: WorkoutHistoryExporting, deleteHistoryUseCase: WorkoutHistoryDeleting) {
		self.exportUseCase = exportUseCase
		self.deleteHistoryUseCase = deleteHistoryUseCase
	}

	func prepareExport() {
		isExporting = true
		defer { isExporting = false }

		do {
			exportCSV = try exportUseCase.exportCSV()
			lastErrorMessage = nil
		} catch {
			lastErrorMessage = error.localizedDescription
		}
	}

	func deleteAllData(completion: @escaping (Bool) -> Void) {
		isDeleting = true
		deleteHistoryUseCase.deleteAllHistory { [weak self] result in
			Task { @MainActor in
				self?.isDeleting = false
				switch result {
				case .success:
					completion(true)
				case .failure(let error):
					self?.lastErrorMessage = error.localizedDescription
					completion(false)
				}
			}
		}
	}
}
