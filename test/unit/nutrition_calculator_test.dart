import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/core/utils/nutrition_calculator.dart';

void main() {
  test('Nutrition scaling works correctly', () {
    final result = NutritionCalculator.scaleByWeight(
      baseWeightGram: 100,
      targetWeightGram: 250,
      protein: 10,
      carbs: 20,
      fat: 5,
      calories: 165,
    );

    expect(result.protein, 25);
    expect(result.carbs, 50);
    expect(result.fat, 12.5);
    expect(result.calories, 412.5);
  });
}
