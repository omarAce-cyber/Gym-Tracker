class WorkoutSessionModel {
  final int? id;
  final int userId;
  final String date;
  final String? notes;

  const WorkoutSessionModel({
    this.id,
    required this.userId,
    required this.date,
    this.notes,
  });

  factory WorkoutSessionModel.fromMap(Map<String, dynamic> map) {
    return WorkoutSessionModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      date: map['date'] as String,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date,
      'notes': notes,
    };
  }
}
