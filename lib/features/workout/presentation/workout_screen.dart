import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/core/utils/date_utils.dart';
import 'package:gym_tracker/features/workout/data/models/muscle_model.dart';
import 'package:gym_tracker/features/workout/data/models/workout_session_model.dart';
import 'package:gym_tracker/features/workout/presentation/session_detail_screen.dart';
import 'package:gym_tracker/shared/providers/app_providers.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(workoutSessionsProvider);
    final exercises = ref.watch(exercisesProvider);
    final muscles = ref.watch(musclesProvider);
    final logs = ref.watch(workoutLogsProvider);
    final user = ref.watch(currentUserProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: user.whenOrNull(
            data: (u) => () async {
              final sessionId = await ref.read(workoutRepositoryProvider).createWorkoutSession(
                    WorkoutSessionModel(
                      userId: u.id!,
                      date: DateTime.now().toIso8601String(),
                    ),
                  );
              ref.invalidate(workoutSessionsProvider);
              ref.invalidate(recentSessionsProvider);
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SessionDetailScreen(sessionId: sessionId)),
                );
              }
            },
          ),
          icon: const Icon(Icons.play_arrow),
          label: const Text('بدء جلسة جديدة'),
        ),
        body: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'الجلسات'),
                Tab(text: 'التمارين'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  sessions.when(
                    data: (sessionList) {
                      final allLogs = logs.asData?.value ?? const [];
                      if (sessionList.isEmpty) return const Center(child: Text('لا توجد جلسات بعد'));
                      return ListView.builder(
                        itemCount: sessionList.length,
                        itemBuilder: (context, index) {
                          final session = sessionList[index];
                          final logCount = allLogs.where((log) => log.workoutSessionId == session.id).length;
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.calendar_today),
                              title: Text('جلسة بتاريخ ${AppDateUtils.shortDate(session.date)}'),
                              subtitle: Text('عدد التمارين: $logCount'),
                              trailing: const Icon(Icons.arrow_back_ios_new),
                              onTap: () {
                                if (session.id == null) return;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SessionDetailScreen(sessionId: session.id!),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(child: Text('تعذر تحميل الجلسات')),
                  ),
                  exercises.when(
                    data: (exerciseList) {
                      final List<MuscleModel> loadedMuscles = muscles.asData?.value ?? const [];
                      final musclesById = <int, String>{
                        for (final muscle in loadedMuscles)
                          if (muscle.id != null) muscle.id!: muscle.name,
                      };
                      return ListView.builder(
                        itemCount: exerciseList.length,
                        itemBuilder: (context, index) {
                          final exercise = exerciseList[index];
                          final muscleName = musclesById[exercise.targetMuscleId] ?? 'عضلة غير معروفة';
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.fitness_center),
                              title: Text(exercise.name),
                              subtitle: Text('العضلة المستهدفة: $muscleName'),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(child: Text('تعذر تحميل التمارين')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
