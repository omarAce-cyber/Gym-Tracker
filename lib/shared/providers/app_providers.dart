import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/features/nutrition/data/models/meal_log_model.dart';
import 'package:gym_tracker/features/nutrition/data/models/meal_model.dart';
import 'package:gym_tracker/features/nutrition/data/repositories/nutrition_repository.dart';
import 'package:gym_tracker/features/profile/data/models/user_model.dart';
import 'package:gym_tracker/features/profile/data/repositories/profile_repository.dart';
import 'package:gym_tracker/features/workout/data/models/exercise_model.dart';
import 'package:gym_tracker/features/workout/data/models/muscle_model.dart';
import 'package:gym_tracker/features/workout/data/models/workout_log_model.dart';
import 'package:gym_tracker/features/workout/data/models/workout_session_model.dart';
import 'package:gym_tracker/features/workout/data/repositories/exercise_repository.dart';
import 'package:gym_tracker/features/workout/data/repositories/workout_repository.dart';
import 'package:gym_tracker/core/utils/date_utils.dart';
import 'package:gym_tracker/shared/providers/database_provider.dart';
import 'package:intl/intl.dart';

double _exerciseScore(WorkoutLogModel log) => log.weight * log.reps;

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository(databaseHelper: ref.watch(databaseHelperProvider));
});

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository(databaseHelper: ref.watch(databaseHelperProvider));
});

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return NutritionRepository(databaseHelper: ref.watch(databaseHelperProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(databaseHelper: ref.watch(databaseHelperProvider));
});

final usersProvider = FutureProvider<List<UserModel>>((ref) async {
  final db = await ref.watch(databaseHelperProvider).database;
  final rows = await db.query('users', orderBy: 'id DESC');
  return rows.map(UserModel.fromMap).toList();
});

final workoutSessionsProvider = FutureProvider<List<WorkoutSessionModel>>((ref) {
  return ref.watch(workoutRepositoryProvider).getAllWorkoutSessions();
});

final workoutLogsProvider = FutureProvider<List<WorkoutLogModel>>((ref) {
  return ref.watch(workoutRepositoryProvider).getAllWorkoutLogs();
});

final exercisesProvider = FutureProvider<List<ExerciseModel>>((ref) {
  return ref.watch(exerciseRepositoryProvider).getAllExercises();
});

final musclesProvider = FutureProvider<List<MuscleModel>>((ref) {
  return ref.watch(exerciseRepositoryProvider).getAllMuscles();
});

final mealsProvider = FutureProvider<List<MealModel>>((ref) {
  return ref.watch(nutritionRepositoryProvider).getAllMeals();
});

final mealLogsProvider = FutureProvider<List<MealLogModel>>((ref) {
  return ref.watch(nutritionRepositoryProvider).getAllMealLogs();
});

class DayVolume {
  const DayVolume({required this.dayLabel, required this.volume});

  final String dayLabel;
  final double volume;
}

final weeklyVolumeProvider = FutureProvider<List<DayVolume>>((ref) async {
  final sessions = await ref.watch(workoutSessionsProvider.future);
  final logs = await ref.watch(workoutLogsProvider.future);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
  final sessionVolumeById = <int, double>{};

  for (final log in logs) {
    final volume = log.weight * log.reps * log.sets;
    sessionVolumeById[log.workoutSessionId] = (sessionVolumeById[log.workoutSessionId] ?? 0) + volume;
  }

  return List.generate(7, (index) {
    final date = start.add(Duration(days: index));
    final dateKey = AppDateUtils.formatDate(date);
    double dayTotal = 0;

    for (final session in sessions) {
      final sessionId = session.id;
      if (sessionId != null && session.date.startsWith(dateKey)) {
        dayTotal += sessionVolumeById[sessionId] ?? 0;
      }
    }

    return DayVolume(
      dayLabel: DateFormat('E', 'ar').format(date),
      volume: dayTotal,
    );
  });
});

class SessionExercisePerformance {
  const SessionExercisePerformance({
    required this.log,
    required this.exerciseName,
    required this.previousBestWeight,
    required this.previousBestReps,
    required this.isPersonalRecord,
  });

  final WorkoutLogModel log;
  final String exerciseName;
  final double? previousBestWeight;
  final int? previousBestReps;
  final bool isPersonalRecord;
}

class SessionDetailData {
  const SessionDetailData({
    required this.session,
    required this.items,
  });

  final WorkoutSessionModel session;
  final List<SessionExercisePerformance> items;
}

final sessionDetailProvider = FutureProvider.family<SessionDetailData?, int>((ref, sessionId) async {
  final sessions = await ref.watch(workoutSessionsProvider.future);
  final logs = await ref.watch(workoutLogsProvider.future);
  final exercises = await ref.watch(exercisesProvider.future);
  WorkoutSessionModel? session;
  for (final item in sessions) {
    if (item.id == sessionId) {
      session = item;
      break;
    }
  }
  if (session == null) return null;

  final exerciseNames = <int, String>{
    for (final exercise in exercises)
      if (exercise.id != null) exercise.id!: exercise.name,
  };

  final sessionsById = <int, WorkoutSessionModel>{
    for (final item in sessions)
      if (item.id != null) item.id!: item,
  };
  final currentLogs = logs.where((item) => item.workoutSessionId == sessionId).toList();
  final items = <SessionExercisePerformance>[];

  for (final currentLog in currentLogs) {
    final previousLogs = logs.where((candidate) {
      if (candidate.exerciseId != currentLog.exerciseId) return false;
      final candidateSession = sessionsById[candidate.workoutSessionId];
      if (candidateSession == null) return false;
      return candidateSession.date.compareTo(session.date) < 0;
    }).toList();

    double? previousBestWeight;
    int? previousBestReps;
    double? previousBestScore;

    for (final previous in previousLogs) {
      final previousScore = _exerciseScore(previous);
      if (previousBestScore == null || previousScore > previousBestScore) {
        previousBestScore = previousScore;
        previousBestWeight = previous.weight;
        previousBestReps = previous.reps;
      }
    }

    final currentScore = _exerciseScore(currentLog);

    items.add(
      SessionExercisePerformance(
        log: currentLog,
        exerciseName: exerciseNames[currentLog.exerciseId] ?? 'تمرين غير معروف',
        previousBestWeight: previousBestWeight,
        previousBestReps: previousBestReps,
        isPersonalRecord: previousBestScore == null || currentScore > previousBestScore,
      ),
    );
  }

  return SessionDetailData(session: session, items: items);
});

class ExercisePr {
  const ExercisePr({
    required this.exerciseName,
    required this.bestWeight,
    required this.bestReps,
    required this.sessionDate,
  });

  final String exerciseName;
  final double bestWeight;
  final int bestReps;
  final String sessionDate;
}

class ProgressChartPoint {
  const ProgressChartPoint({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;
}

class ProgressData {
  const ProgressData({
    required this.prs,
    required this.chart,
  });

  final List<ExercisePr> prs;
  final List<ProgressChartPoint> chart;
}

final progressDataProvider = FutureProvider<ProgressData>((ref) async {
  final sessions = await ref.watch(workoutSessionsProvider.future);
  final logs = await ref.watch(workoutLogsProvider.future);
  final exercises = await ref.watch(exercisesProvider.future);
  final exerciseNames = <int, String>{
    for (final item in exercises)
      if (item.id != null) item.id!: item.name,
  };
  final sessionsById = <int, WorkoutSessionModel>{
    for (final item in sessions)
      if (item.id != null) item.id!: item,
  };
  final bestByExercise = <int, WorkoutLogModel>{};

  for (final log in logs) {
    final current = bestByExercise[log.exerciseId];
    final score = _exerciseScore(log);
    final currentScore = current == null ? null : _exerciseScore(current);
    if (currentScore == null || score > currentScore) {
      bestByExercise[log.exerciseId] = log;
    }
  }

  final prs = bestByExercise.entries.map((entry) {
    final sessionDate = sessionsById[entry.value.workoutSessionId]?.date ?? '';
    return ExercisePr(
      exerciseName: exerciseNames[entry.key] ?? 'تمرين غير معروف',
      bestWeight: entry.value.weight,
      bestReps: entry.value.reps,
      sessionDate: sessionDate,
    );
  }).toList()
    ..sort((a, b) => b.bestWeight.compareTo(a.bestWeight));

  final sessionVolume = <int, double>{};
  for (final log in logs) {
    sessionVolume[log.workoutSessionId] = (sessionVolume[log.workoutSessionId] ?? 0) + (log.weight * log.reps * log.sets);
  }

  final sortedSessions = [...sessions]..sort((a, b) => a.date.compareTo(b.date));
  final recentSessions = sortedSessions.length > 8
      ? sortedSessions.sublist(sortedSessions.length - 8)
      : sortedSessions;
  final chart = recentSessions.map((session) {
    final sessionId = session.id;
    return ProgressChartPoint(
      label: session.date.length >= 10 ? session.date.substring(5, 10) : session.date,
      value: sessionId == null ? 0 : (sessionVolume[sessionId] ?? 0),
    );
  }).toList();

  return ProgressData(prs: prs, chart: chart);
});
