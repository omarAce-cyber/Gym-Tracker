class MuscleModel {
  final int? id;
  final String name;
  final int isCustom;

  const MuscleModel({
    this.id,
    required this.name,
    this.isCustom = 0,
  });

  factory MuscleModel.fromMap(Map<String, dynamic> map) {
    return MuscleModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      isCustom: map['is_custom'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'is_custom': isCustom,
    };
  }
}
