import Foundation

protocol WorkoutStoreSpecs {
	func test_retrieve_deliversEmptyOnEmptyCache() async throws
	func test_retrieve_hasNoSideEffectsOnEmptyCache() async throws
	func test_retrieve_deliversFoundValuesOnNonEmptyCache() async throws
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() async throws
	
	func test_insert_deliversNoErrorOnEmptyCache() async throws
	func test_insert_deliversNoErrorOnNonEmptyCache() async throws
	func test_insert_overridesPreviouslyInsertedCacheValues() async throws
	
	func test_delete_deliversNoErrorOnEmptyCache() async throws
	func test_delete_hasNoSideEffectsOnEmptyCache() async throws
	func test_delete_deliversNoErrorOnNonEmptyCache() async throws
	func test_delete_emptiesPreviouslyInsertedCache() async throws
}
