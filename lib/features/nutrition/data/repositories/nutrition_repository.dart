import 'package:gym_tracker/core/database/database_helper.dart';
import 'package:gym_tracker/core/utils/date_utils.dart';
import 'package:gym_tracker/core/utils/nutrition_calculator.dart';
import 'package:gym_tracker/features/nutrition/data/models/meal_log_model.dart';
import 'package:gym_tracker/features/nutrition/data/models/meal_model.dart';

class NutritionRepository {
  NutritionRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<int> createMeal(MealModel meal) async {
    final db = await _databaseHelper.database;
    return db.insert('meals', meal.toMap());
  }

  Future<int> insertMeal(MealModel meal) {
    return createMeal(meal);
  }

  Future<List<MealModel>> getAllMeals() async {
    final db = await _databaseHelper.database;
    final rows = await db.query('meals', orderBy: 'id DESC');
    return rows.map(MealModel.fromMap).toList();
  }

  Future<List<MealModel>> getMealsByUser(int userId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'meals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return rows.map(MealModel.fromMap).toList();
  }

  Future<List<MealModel>> getMealsByUserId(int userId) {
    return getMealsByUser(userId);
  }

  Future<MealModel?> getMealById(int id) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'meals',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return MealModel.fromMap(rows.first);
  }

  Future<int> updateMeal(MealModel meal) async {
    if (meal.id == null) {
      throw ArgumentError('MealModel.id is required for update');
    }

    final db = await _databaseHelper.database;
    return db.update(
      'meals',
      meal.toMap(),
      where: 'id = ?',
      whereArgs: [meal.id],
    );
  }

  Future<int> deleteMeal(int id) async {
    final db = await _databaseHelper.database;
    return db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteMealWithLogs(int mealId) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      await txn.delete('meal_logs', where: 'meal_id = ?', whereArgs: [mealId]);
      await txn.delete('meals', where: 'id = ?', whereArgs: [mealId]);
    });
  }

  Future<int> createMealLog(MealLogModel mealLog) async {
    final db = await _databaseHelper.database;
    return db.insert('meal_logs', mealLog.toMap());
  }

  Future<int> insertMealLog(MealLogModel mealLog) {
    return createMealLog(mealLog);
  }

  Future<List<MealLogModel>> getAllMealLogs() async {
    final db = await _databaseHelper.database;
    final rows = await db.query('meal_logs', orderBy: 'date DESC, id DESC');
    return rows.map(MealLogModel.fromMap).toList();
  }

  Future<List<MealLogModel>> getMealLogsByUser(int userId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'meal_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(MealLogModel.fromMap).toList();
  }

  Future<List<MealLogModel>> getMealLogsByUserId(int userId) {
    return getMealLogsByUser(userId);
  }

  Future<List<MealLogModel>> getMealLogsByDate(int userId, String date) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'meal_logs',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
      orderBy: 'id DESC',
    );
    return rows.map(MealLogModel.fromMap).toList();
  }

  Future<List<MealLogModel>> getMealLogsByDateRange({
    required int userId,
    required String startDate,
    required String endDate,
  }) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'meal_logs',
      where: 'user_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [userId, startDate, endDate],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(MealLogModel.fromMap).toList();
  }

  Future<MealLogModel?> getMealLogById(int id) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'meal_logs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return MealLogModel.fromMap(rows.first);
  }

  Future<int> updateMealLog(MealLogModel mealLog) async {
    if (mealLog.id == null) {
      throw ArgumentError('MealLogModel.id is required for update');
    }

    final db = await _databaseHelper.database;
    return db.update(
      'meal_logs',
      mealLog.toMap(),
      where: 'id = ?',
      whereArgs: [mealLog.id],
    );
  }

  Future<int> deleteMealLog(int id) async {
    final db = await _databaseHelper.database;
    return db.delete('meal_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getMealLogsWithMealsByDate({
    required int userId,
    required DateTime date,
  }) async {
    final db = await _databaseHelper.database;
    final dateKey = AppDateUtils.formatDate(date);
    return db.rawQuery(
      '''
      SELECT
        ml.id AS id,
        ml.user_id AS user_id,
        ml.meal_id AS meal_id,
        ml.date AS date,
        ml.quantity_in_gram AS quantity_in_gram,
        m.name AS meal_name,
        m.protein AS protein,
        m.carbs AS carbs,
        m.fat AS fat,
        m.calories AS calories,
        m.weight_in_gram AS base_weight_in_gram
      FROM meal_logs ml
      INNER JOIN meals m ON m.id = ml.meal_id
      WHERE ml.user_id = ? AND ml.date = ?
      ORDER BY ml.id DESC
      ''',
      [userId, dateKey],
    );
  }

  Future<NutritionSummary> getDailyNutritionSummary({
    required int userId,
    required DateTime date,
  }) async {
    final rows = await getMealLogsWithMealsByDate(userId: userId, date: date);
    double protein = 0;
    double carbs = 0;
    double fat = 0;
    double calories = 0;

    for (final row in rows) {
      final summary = NutritionCalculator.scaleByWeight(
        baseWeightGram: (row['base_weight_in_gram'] as num).toDouble(),
        targetWeightGram: (row['quantity_in_gram'] as num).toDouble(),
        protein: (row['protein'] as num).toDouble(),
        carbs: (row['carbs'] as num).toDouble(),
        fat: (row['fat'] as num).toDouble(),
        calories: (row['calories'] as num).toDouble(),
      );
      protein += summary.protein;
      carbs += summary.carbs;
      fat += summary.fat;
      calories += summary.calories;
    }

    return NutritionSummary(protein: protein, carbs: carbs, fat: fat, calories: calories);
  }
}
