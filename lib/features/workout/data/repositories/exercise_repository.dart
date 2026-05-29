import 'package:gym_tracker/core/database/database_helper.dart';
import 'package:gym_tracker/features/workout/data/models/exercise_model.dart';
import 'package:gym_tracker/features/workout/data/models/muscle_model.dart';

class ExerciseRepository {
  ExerciseRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<List<MuscleModel>> getAllMuscles() async {
    final db = await _databaseHelper.database;
    final rows = await db.query('muscles', orderBy: 'name ASC');
    return rows.map(MuscleModel.fromMap).toList();
  }

  Future<MuscleModel?> getMuscleById(int id) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'muscles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return MuscleModel.fromMap(rows.first);
  }

  Future<int> createMuscle(MuscleModel muscle) async {
    final db = await _databaseHelper.database;
    return db.insert('muscles', muscle.toMap());
  }

  Future<int> insertMuscle(MuscleModel muscle) {
    return createMuscle(muscle);
  }

  Future<int> updateMuscle(MuscleModel muscle) async {
    if (muscle.id == null) {
      throw ArgumentError('MuscleModel.id is required for update');
    }

    final db = await _databaseHelper.database;
    return db.update(
      'muscles',
      muscle.toMap(),
      where: 'id = ?',
      whereArgs: [muscle.id],
    );
  }

  Future<int> deleteMuscle(int id) async {
    final db = await _databaseHelper.database;
    return db.delete('muscles', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ExerciseModel>> getAllExercises() async {
    final db = await _databaseHelper.database;
    final rows = await db.query('exercises', orderBy: 'name ASC');
    return rows.map(ExerciseModel.fromMap).toList();
  }

  Future<ExerciseModel?> getExerciseById(int id) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return ExerciseModel.fromMap(rows.first);
  }

  Future<List<ExerciseModel>> getExercisesByMuscle(int muscleId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'exercises',
      where: 'target_muscle_id = ?',
      whereArgs: [muscleId],
      orderBy: 'name ASC',
    );
    return rows.map(ExerciseModel.fromMap).toList();
  }

  Future<List<ExerciseModel>> getExercisesByMuscleId(int muscleId) {
    return getExercisesByMuscle(muscleId);
  }

  Future<List<ExerciseModel>> getExercisesByMuscleGroup(int muscleId) {
    return getExercisesByMuscle(muscleId);
  }

  Future<int> createExercise(ExerciseModel exercise) async {
    final db = await _databaseHelper.database;
    return db.insert('exercises', exercise.toMap());
  }

  Future<int> insertExercise(ExerciseModel exercise) {
    return createExercise(exercise);
  }

  Future<int> updateExercise(ExerciseModel exercise) async {
    if (exercise.id == null) {
      throw ArgumentError('ExerciseModel.id is required for update');
    }

    final db = await _databaseHelper.database;
    return db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<int> deleteExercise(int id) async {
    final db = await _databaseHelper.database;
    return db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }
}
