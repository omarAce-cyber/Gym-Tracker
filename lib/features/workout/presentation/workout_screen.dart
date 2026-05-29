import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/features/workout/data/models/muscle_model.dart';
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

    return DefaultTabController(
      length: 2,
      child: Column(
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
                    return ListView.builder(
                      itemCount: sessionList.length,
                      itemBuilder: (context, index) {
                        final session = sessionList[index];
                        final logCount = allLogs.where((log) => log.workoutSessionId == session.id).length;
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: Text('جلسة بتاريخ ${session.date.substring(0, session.date.length >= 10 ? 10 : session.date.length)}'),
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
    );
  }
}
