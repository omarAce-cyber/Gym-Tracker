import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/core/utils/nutrition_calculator.dart';
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
import 'package:gym_tracker/shared/providers/database_provider.dart';

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

final currentUserProvider = FutureProvider<UserModel>((ref) async {
  return ref.watch(profileRepositoryProvider).getOrCreateDefaultUser();
});

final usersProvider = FutureProvider<List<UserModel>>((ref) async {
  return ref.watch(profileRepositoryProvider).getAllUsers();
});

class WorkoutSessionsNotifier extends AsyncNotifier<List<WorkoutSessionModel>> {
  @override
  Future<List<WorkoutSessionModel>> build() async {
    final user = await ref.watch(currentUserProvider.future);
    return ref.watch(workoutRepositoryProvider).getWorkoutSessionsByUserId(user.id!);
  }
}

final workoutSessionsProvider = AsyncNotifierProvider<WorkoutSessionsNotifier, List<WorkoutSessionModel>>(
  WorkoutSessionsNotifier.new,
);

final workoutLogsProvider = FutureProvider<List<WorkoutLogModel>>((ref) {
  return ref.watch(workoutRepositoryProvider).getAllWorkoutLogs();
});

class ExercisesNotifier extends AsyncNotifier<List<ExerciseModel>> {
  @override
  Future<List<ExerciseModel>> build() async {
    return ref.watch(exerciseRepositoryProvider).getAllExercises();
  }
}

final exercisesProvider = AsyncNotifierProvider<ExercisesNotifier, List<ExerciseModel>>(
  ExercisesNotifier.new,
);

final musclesProvider = FutureProvider<List<MuscleModel>>((ref) {
  return ref.watch(exerciseRepositoryProvider).getAllMuscles();
});

class MealsNotifier extends AsyncNotifier<List<MealModel>> {
  @override
  Future<List<MealModel>> build() async {
    final user = await ref.watch(currentUserProvider.future);
    return ref.watch(nutritionRepositoryProvider).getMealsByUserId(user.id!);
  }
}

final mealsProvider = AsyncNotifierProvider<MealsNotifier, List<MealModel>>(MealsNotifier.new);

final mealLogsProvider = FutureProvider<List<MealLogModel>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  return ref.watch(nutritionRepositoryProvider).getMealLogsByUserId(user.id!);
});

class DailyNutritionNotifier extends AsyncNotifier<NutritionSummary> {
  @override
  Future<NutritionSummary> build() async {
    final user = await ref.watch(currentUserProvider.future);
    return ref.watch(nutritionRepositoryProvider).getDailyNutritionSummary(
      userId: user.id!,
      date: DateTime.now(),
    );
  }
}

final dailyNutritionProvider = AsyncNotifierProvider<DailyNutritionNotifier, NutritionSummary>(
  DailyNutritionNotifier.new,
);

class SessionExercisePerformance {
  const SessionExercisePerformance({
    required this.log,
    required this.exerciseName,
    required this.previousHint,
    required this.isPersonalRecord,
  });

  final WorkoutLogModel log;
  final String exerciseName;
  final String? previousHint;
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

  final exerciseNames = <int, String>{for (final e in exercises) if (e.id != null) e.id!: e.name};
  final sessionById = <int, WorkoutSessionModel>{
    for (final s in sessions)
      if (s.id != null) s.id!: s,
  };

  final currentLogs = logs.where((log) => log.workoutSessionId == sessionId).toList();
  final items = <SessionExercisePerformance>[];
  for (final log in currentLogs) {
    final related = logs.where((x) => x.exerciseId == log.exerciseId).toList()
      ..sort((a, b) {
        final dateA = sessionById[a.workoutSessionId]?.date ?? '';
        final dateB = sessionById[b.workoutSessionId]?.date ?? '';
        final comp = dateA.compareTo(dateB);
        if (comp != 0) return comp;
        return (a.id ?? 0).compareTo(b.id ?? 0);
      });
    final index = related.indexWhere((x) => x.id == log.id);
    WorkoutLogModel? previous;
    if (index > 0) previous = related[index - 1];
    final maxWeightBefore = related
        .where((x) => x.id != log.id)
        .map((x) => x.weight)
        .fold<double?>(null, (acc, item) => acc == null || item > acc ? item : acc);
    items.add(
      SessionExercisePerformance(
        log: log,
        exerciseName: exerciseNames[log.exerciseId] ?? 'تمرين غير معروف',
        previousHint: previous == null
            ? null
            : 'آخر مرة: ${previous.weight} كجم × ${previous.reps} تكرار × ${previous.sets} مجموعات',
        isPersonalRecord: maxWeightBefore == null || log.weight > maxWeightBefore,
      ),
    );
  }

  return SessionDetailData(session: session, items: items);
});

final weeklySetsByMuscleProvider = FutureProvider<Map<String, int>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  return ref.watch(workoutRepositoryProvider).getWeeklySetsByMuscle(user.id!);
});

final recentSessionsProvider = FutureProvider<List<WorkoutSessionModel>>((ref) async {
  final sessions = await ref.watch(workoutSessionsProvider.future);
  return sessions.take(3).toList();
});

class DailyMealLogItem {
  const DailyMealLogItem({
    required this.id,
    required this.mealName,
    required this.quantityInGram,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final int id;
  final String mealName;
  final double quantityInGram;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
}

final todayMealLogsProvider = FutureProvider<List<DailyMealLogItem>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  final rows = await ref.watch(nutritionRepositoryProvider).getMealLogsWithMealsByDate(
    userId: user.id!,
    date: DateTime.now(),
  );
  return rows.map((row) {
    final scaled = NutritionCalculator.scaleByWeight(
      baseWeightGram: (row['base_weight_in_gram'] as num).toDouble(),
      targetWeightGram: (row['quantity_in_gram'] as num).toDouble(),
      protein: (row['protein'] as num).toDouble(),
      carbs: (row['carbs'] as num).toDouble(),
      fat: (row['fat'] as num).toDouble(),
      calories: (row['calories'] as num).toDouble(),
    );
    return DailyMealLogItem(
      id: row['id'] as int,
      mealName: row['meal_name'] as String? ?? 'وجبة',
      quantityInGram: (row['quantity_in_gram'] as num).toDouble(),
      calories: scaled.calories,
      protein: scaled.protein,
      carbs: scaled.carbs,
      fat: scaled.fat,
    );
  }).toList();
});

class ExerciseHistoryPoint {
  const ExerciseHistoryPoint({
    required this.date,
    required this.weight,
  });

  final String date;
  final double weight;
}

final exercisesWithLogsProvider = FutureProvider<List<ExerciseModel>>((ref) async {
  final exercises = await ref.watch(exercisesProvider.future);
  final logs = await ref.watch(workoutLogsProvider.future);
  final usedIds = logs.map((e) => e.exerciseId).toSet();
  return exercises.where((e) => e.id != null && usedIds.contains(e.id)).toList();
});

final exercisePrMapProvider = FutureProvider<Map<int, double>>((ref) async {
  final logs = await ref.watch(workoutLogsProvider.future);
  final result = <int, double>{};
  for (final log in logs) {
    final current = result[log.exerciseId];
    if (current == null || log.weight > current) {
      result[log.exerciseId] = log.weight;
    }
  }
  return result;
});

final exerciseHistoryProvider = FutureProvider.family<List<ExerciseHistoryPoint>, int>((ref, exerciseId) async {
  final user = await ref.watch(currentUserProvider.future);
  final rows = await ref.watch(workoutRepositoryProvider).getExerciseHistory(exerciseId, user.id!);
  return rows
      .map(
        (row) => ExerciseHistoryPoint(
          date: row['session_date'] as String,
          weight: (row['weight'] as num).toDouble(),
        ),
      )
      .toList();
});
