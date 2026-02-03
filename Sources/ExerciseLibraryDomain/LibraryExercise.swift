import Foundation

public struct LibraryExercise: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let primaryMuscleGroup: MuscleGroup
    public let secondaryMuscleGroups: [MuscleGroup]
    public let equipmentType: EquipmentType
    public let isCustom: Bool
    
    public init(
        id: UUID,
        name: String,
        primaryMuscleGroup: MuscleGroup,
        secondaryMuscleGroups: [MuscleGroup] = [],
        equipmentType: EquipmentType,
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
