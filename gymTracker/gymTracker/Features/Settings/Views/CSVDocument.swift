import SwiftUI
import UniformTypeIdentifiers

extension UTType {
	static let gymTrackerCSV = UTType(filenameExtension: "csv") ?? .plainText
}

struct CSVDocument: FileDocument {
	static var readableContentTypes: [UTType] { [.gymTrackerCSV] }

	let text: String

	init(text: String) {
		self.text = text
	}

	init(configuration: ReadConfiguration) throws {
		if let data = configuration.file.regularFileContents,
		   let text = String(data: data, encoding: .utf8) {
			self.text = text
		} else {
			self.text = ""
		}
	}

	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		FileWrapper(regularFileWithContents: Data(text.utf8))
	}
}
