class UserModel {
  final int? id;
  final String name;
  final double? weight;
  final double? height;
  final String goal;
  final String createdAt;

  const UserModel({
    this.id,
    required this.name,
    this.weight,
    this.height,
    this.goal = 'BuildMuscle',
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      weight: (map['weight'] as num?)?.toDouble(),
      height: (map['height'] as num?)?.toDouble(),
      goal: map['goal'] as String? ?? 'BuildMuscle',
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'height': height,
      'goal': goal,
      'created_at': createdAt,
    };
  }
}
