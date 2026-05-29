import 'package:gym_tracker/core/database/database_helper.dart';
import 'package:gym_tracker/features/workout/data/models/workout_log_model.dart';
import 'package:gym_tracker/features/workout/data/models/workout_session_model.dart';

class WorkoutRepository {
  WorkoutRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<int> createWorkoutSession(WorkoutSessionModel session) async {
    final db = await _databaseHelper.database;
    return db.insert('workout_sessions', session.toMap());
  }

  Future<int> insertWorkoutSession(WorkoutSessionModel session) {
    return createWorkoutSession(session);
  }

  Future<List<WorkoutSessionModel>> getAllWorkoutSessions() async {
    final db = await _databaseHelper.database;
    final rows = await db.query('workout_sessions', orderBy: 'date DESC, id DESC');
    return rows.map(WorkoutSessionModel.fromMap).toList();
  }

  Future<List<WorkoutSessionModel>> getWorkoutSessionsByUser(int userId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'workout_sessions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(WorkoutSessionModel.fromMap).toList();
  }

  Future<List<WorkoutSessionModel>> getWorkoutSessionsByUserId(int userId) {
    return getWorkoutSessionsByUser(userId);
  }

  Future<WorkoutSessionModel?> getWorkoutSessionById(int id) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'workout_sessions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return WorkoutSessionModel.fromMap(rows.first);
  }

  Future<List<WorkoutSessionModel>> getWorkoutSessionsByDateRange({
    required int userId,
    required String startDate,
    required String endDate,
  }) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'workout_sessions',
      where: 'user_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [userId, startDate, endDate],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(WorkoutSessionModel.fromMap).toList();
  }

  Future<int> updateWorkoutSession(WorkoutSessionModel session) async {
    if (session.id == null) {
      throw ArgumentError('WorkoutSessionModel.id is required for update');
    }

    final db = await _databaseHelper.database;
    return db.update(
      'workout_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteWorkoutSession(int id) async {
    final db = await _databaseHelper.database;
    return db.delete('workout_sessions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteWorkoutSessionWithLogs(int workoutSessionId) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        'workout_logs',
        where: 'workout_session_id = ?',
        whereArgs: [workoutSessionId],
      );
      await txn.delete(
        'workout_sessions',
        where: 'id = ?',
        whereArgs: [workoutSessionId],
      );
    });
  }

  Future<int> createWorkoutLog(WorkoutLogModel log) async {
    final db = await _databaseHelper.database;
    return db.insert('workout_logs', log.toMap());
  }

  Future<int> insertWorkoutLog(WorkoutLogModel log) {
    return createWorkoutLog(log);
  }

  Future<List<WorkoutLogModel>> getAllWorkoutLogs() async {
    final db = await _databaseHelper.database;
    final rows = await db.query('workout_logs', orderBy: 'id DESC');
    return rows.map(WorkoutLogModel.fromMap).toList();
  }

  Future<List<WorkoutLogModel>> getWorkoutLogsBySession(int workoutSessionId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'workout_logs',
      where: 'workout_session_id = ?',
      whereArgs: [workoutSessionId],
      orderBy: 'id ASC',
    );
    return rows.map(WorkoutLogModel.fromMap).toList();
  }

  Future<List<WorkoutLogModel>> getWorkoutLogsBySessionId(int workoutSessionId) {
    return getWorkoutLogsBySession(workoutSessionId);
  }

  Future<WorkoutLogModel?> getWorkoutLogById(int id) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'workout_logs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return WorkoutLogModel.fromMap(rows.first);
  }

  Future<int> updateWorkoutLog(WorkoutLogModel log) async {
    if (log.id == null) {
      throw ArgumentError('WorkoutLogModel.id is required for update');
    }

    final db = await _databaseHelper.database;
    return db.update(
      'workout_logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  Future<int> deleteWorkoutLog(int id) async {
    final db = await _databaseHelper.database;
    return db.delete('workout_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearWorkoutLogsBySession(int workoutSessionId) async {
    final db = await _databaseHelper.database;
    return db.delete(
      'workout_logs',
      where: 'workout_session_id = ?',
      whereArgs: [workoutSessionId],
    );
  }

  Future<Map<String, int>> getWeeklySetsByMuscle(int userId) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    final startDate =
        '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final rows = await db.rawQuery(
      '''
      SELECT m.name AS muscle_name, COALESCE(SUM(wl.sets), 0) AS total_sets
      FROM workout_logs wl
      INNER JOIN workout_sessions ws ON ws.id = wl.workout_session_id
      INNER JOIN exercises e ON e.id = wl.exercise_id
      INNER JOIN muscles m ON m.id = e.target_muscle_id
      WHERE ws.user_id = ? AND ws.date >= ?
      GROUP BY m.id, m.name
      ORDER BY m.id ASC
      ''',
      [userId, startDate],
    );
    return {
      for (final row in rows) row['muscle_name'] as String: (row['total_sets'] as num?)?.toInt() ?? 0,
    };
  }

  Future<List<Map<String, dynamic>>> getExerciseHistory(int exerciseId, int userId) async {
    final db = await _databaseHelper.database;
    return db.rawQuery(
      '''
      SELECT ws.date AS session_date, wl.weight AS weight, wl.reps AS reps, wl.sets AS sets
      FROM workout_logs wl
      INNER JOIN workout_sessions ws ON ws.id = wl.workout_session_id
      WHERE wl.exercise_id = ? AND ws.user_id = ?
      ORDER BY ws.date ASC, wl.id ASC
      ''',
      [exerciseId, userId],
    );
  }

  Future<double?> getPreviousBestWeight({
    required int exerciseId,
    required int userId,
    required int beforeSessionId,
  }) async {
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery(
      '''
      SELECT MAX(wl.weight) AS best_weight
      FROM workout_logs wl
      INNER JOIN workout_sessions ws ON ws.id = wl.workout_session_id
      WHERE wl.exercise_id = ? AND ws.user_id = ? AND ws.id <> ?
      ''',
      [exerciseId, userId, beforeSessionId],
    );
    if (rows.isEmpty || rows.first['best_weight'] == null) return null;
    return (rows.first['best_weight'] as num).toDouble();
  }
}
