import Foundation
import ExerciseLibraryDomain

public protocol ExerciseLibrarySeedLoading {
    func loadSeedExercises() throws -> [LibraryExercise]
}

public enum SeedLoadingError: Error {
    case fileNotFound
    case decodingFailed(Error)
}

public final class BundleExerciseLibrarySeedLoader: ExerciseLibrarySeedLoading {
    private let bundle: Bundle
    private let fileName: String
    
    public init(bundle: Bundle? = nil, fileName: String = "DefaultExerciseLibrary") {
        self.bundle = bundle ?? Bundle.module
        self.fileName = fileName
    }
    
    public func loadSeedExercises() throws -> [LibraryExercise] {
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw SeedLoadingError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let localExercises = try decoder.decode([LocalLibraryExercise].self, from: data)
            return localExercises.compactMap { $0.toLibraryExercise() }
        } catch {
            throw SeedLoadingError.decodingFailed(error)
        }
    }
}
