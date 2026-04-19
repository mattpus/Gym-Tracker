import CoreData

extension NSPersistentContainer {
	static func load(name: String, model: NSManagedObjectModel, url: URL) throws -> NSPersistentContainer {
		let description = NSPersistentStoreDescription(url: url)
		description.shouldMigrateStoreAutomatically = true
		description.shouldInferMappingModelAutomatically = true
		let container = NSPersistentContainer(name: name, managedObjectModel: model)
		container.persistentStoreDescriptions = [description]
		
		var loadError: Swift.Error?
		container.loadPersistentStores { _, error in
			loadError = error
		}
		
		if let loadError {
			throw loadError
		}
		
		return container
	}
}

extension NSManagedObjectModel {
	static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
		let momdUrl = bundle.url(forResource: name, withExtension: "momd")
		let momUrl = bundle.url(forResource: name, withExtension: "mom")
		let legacyModelUrl = bundle.url(forResource: name, withExtension: "xcdatamodeld")
		let modelURL = momdUrl ?? momUrl ?? legacyModelUrl
		return modelURL.flatMap { NSManagedObjectModel(contentsOf: $0) }
	}
}
