class NutritionSummary {
  final double protein;
  final double carbs;
  final double fat;
  final double calories;

  const NutritionSummary({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
  });
}

abstract final class NutritionCalculator {
  static NutritionSummary scaleByWeight({
    required double baseWeightGram,
    required double targetWeightGram,
    required double protein,
    required double carbs,
    required double fat,
    required double calories,
  }) {
    final ratio = targetWeightGram / baseWeightGram;
    return NutritionSummary(
      protein: protein * ratio,
      carbs: carbs * ratio,
      fat: fat * ratio,
      calories: calories * ratio,
    );
  }
}
