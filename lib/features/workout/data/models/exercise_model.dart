class ExerciseModel {
  final int? id;
  final String name;
  final int targetMuscleId;
  final int isCustom;

  const ExerciseModel({
    this.id,
    required this.name,
    required this.targetMuscleId,
    this.isCustom = 0,
  });

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      targetMuscleId: map['target_muscle_id'] as int,
      isCustom: map['is_custom'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_muscle_id': targetMuscleId,
      'is_custom': isCustom,
    };
  }
}
