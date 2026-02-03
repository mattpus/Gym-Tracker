import Foundation
import ExerciseLibraryDomain

public struct LocalLibraryExercise: Equatable, Codable {
    public let id: UUID
    public let name: String
    public let primaryMuscleGroup: String
    public let secondaryMuscleGroups: [String]
    public let equipmentType: String
    public let isCustom: Bool
    
    public init(
        id: UUID,
        name: String,
        primaryMuscleGroup: String,
        secondaryMuscleGroups: [String] = [],
        equipmentType: String,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.primaryMuscleGroup = primaryMuscleGroup
        self.secondaryMuscleGroups = secondaryMuscleGroups
        self.equipmentType = equipmentType
        self.isCustom = isCustom
    }
}

extension LocalLibraryExercise {
    func toLibraryExercise() -> LibraryExercise? {
        guard let primary = MuscleGroup(rawValue: primaryMuscleGroup),
              let equipment = EquipmentType(rawValue: equipmentType) else {
            return nil
        }
        
        let secondary = secondaryMuscleGroups.compactMap { MuscleGroup(rawValue: $0) }
        
        return LibraryExercise(
            id: id,
            name: name,
            primaryMuscleGroup: primary,
            secondaryMuscleGroups: secondary,
            equipmentType: equipment,
            isCustom: isCustom
        )
    }
    
    static func from(_ exercise: LibraryExercise) -> LocalLibraryExercise {
        LocalLibraryExercise(
            id: exercise.id,
            name: exercise.name,
            primaryMuscleGroup: exercise.primaryMuscleGroup.rawValue,
            secondaryMuscleGroups: exercise.secondaryMuscleGroups.map(\.rawValue),
            equipmentType: exercise.equipmentType.rawValue,
            isCustom: exercise.isCustom
        )
    }
}
