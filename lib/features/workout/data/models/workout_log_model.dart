class WorkoutLogModel {
  final int? id;
  final int workoutSessionId;
  final int exerciseId;
  final double weight;
  final int reps;
  final int sets;
  final String? notes;

  const WorkoutLogModel({
    this.id,
    required this.workoutSessionId,
    required this.exerciseId,
    required this.weight,
    required this.reps,
    required this.sets,
    this.notes,
  });

  factory WorkoutLogModel.fromMap(Map<String, dynamic> map) {
    return WorkoutLogModel(
      id: map['id'] as int?,
      workoutSessionId: map['workout_session_id'] as int,
      exerciseId: map['exercise_id'] as int,
      weight: (map['weight'] as num).toDouble(),
      reps: map['reps'] as int,
      sets: map['sets'] as int,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_session_id': workoutSessionId,
      'exercise_id': exerciseId,
      'weight': weight,
      'reps': reps,
      'sets': sets,
      'notes': notes,
    };
  }
}
