class MealModel {
  final int? id;
  final int userId;
  final String name;
  final String? imagePath;
  final double weightInGram;
  final double protein;
  final double carbs;
  final double fat;
  final double calories;
  final String? notes;

  const MealModel({
    this.id,
    required this.userId,
    required this.name,
    this.imagePath,
    required this.weightInGram,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
    this.notes,
  });

  factory MealModel.fromMap(Map<String, dynamic> map) {
    return MealModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      imagePath: map['image_path'] as String?,
      weightInGram: (map['weight_in_gram'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      calories: (map['calories'] as num).toDouble(),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'image_path': imagePath,
      'weight_in_gram': weightInGram,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'calories': calories,
      'notes': notes,
    };
  }
}
