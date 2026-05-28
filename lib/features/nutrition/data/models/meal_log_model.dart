class MealLogModel {
  final int? id;
  final int userId;
  final int mealId;
  final String date;
  final double quantityInGram;

  const MealLogModel({
    this.id,
    required this.userId,
    required this.mealId,
    required this.date,
    required this.quantityInGram,
  });

  factory MealLogModel.fromMap(Map<String, dynamic> map) {
    return MealLogModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      mealId: map['meal_id'] as int,
      date: map['date'] as String,
      quantityInGram: (map['quantity_in_gram'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'meal_id': mealId,
      'date': date,
      'quantity_in_gram': quantityInGram,
    };
  }
}
