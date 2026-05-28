import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/features/nutrition/data/models/meal_model.dart';
import 'package:gym_tracker/features/profile/data/models/user_model.dart';
import 'package:gym_tracker/features/workout/data/models/exercise_model.dart';

void main() {
  group('Model mapping', () {
    test('UserModel fromMap/toMap works', () {
      final map = {
        'id': 1,
        'name': 'أحمد',
        'weight': 80.0,
        'height': 175.0,
        'goal': 'BuildMuscle',
        'created_at': '2026-01-01',
      };

      final model = UserModel.fromMap(map);
      expect(model.name, 'أحمد');
      expect(model.toMap()['goal'], 'BuildMuscle');
    });

    test('ExerciseModel fromMap/toMap works', () {
      final map = {
        'id': 2,
        'name': 'سكوات',
        'target_muscle_id': 7,
        'is_custom': 0,
      };

      final model = ExerciseModel.fromMap(map);
      expect(model.targetMuscleId, 7);
      expect(model.toMap()['name'], 'سكوات');
    });

    test('MealModel fromMap/toMap works', () {
      final map = {
        'id': 3,
        'user_id': 1,
        'name': 'أرز ودجاج',
        'image_path': null,
        'weight_in_gram': 300.0,
        'protein': 35.0,
        'carbs': 55.0,
        'fat': 12.0,
        'calories': 450.0,
        'notes': null,
      };

      final model = MealModel.fromMap(map);
      expect(model.protein, 35.0);
      expect(model.toMap()['weight_in_gram'], 300.0);
    });
  });
}
