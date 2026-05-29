import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/core/utils/date_utils.dart';
import 'package:gym_tracker/features/workout/data/models/workout_log_model.dart';
import 'package:gym_tracker/shared/providers/app_providers.dart';
import 'package:gym_tracker/shared/widgets/confirm_dialog.dart';

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({super.key, required this.sessionId});

  final int sessionId;

  Future<void> _showAddLogSheet(BuildContext context, WidgetRef ref) async {
    final exercises = await ref.read(exercisesProvider.future);
    final muscles = await ref.read(musclesProvider.future);
    if (!context.mounted) return;

    final options = <Map<String, dynamic>>[];
    final muscleById = {
      for (final muscle in muscles)
        if (muscle.id != null) muscle.id!: muscle.name,
    };
    for (final exercise in exercises) {
      final key = muscleById[exercise.targetMuscleId] ?? 'أخرى';
      options.add({'id': exercise.id!, 'name': '${exercise.name} ($key)'});
    }

    final formKey = GlobalKey<FormState>();
    int? selectedExerciseId = exercises.isNotEmpty ? exercises.first.id : null;
    final weightController = TextEditingController();
    final repsController = TextEditingController();
    final setsController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('إضافة تمرين', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: selectedExerciseId,
                        decoration: const InputDecoration(
                          labelText: 'التمرين',
                          border: OutlineInputBorder(),
                        ),
                        items: options
                            .map((item) => DropdownMenuItem<int>(value: item['id'] as int, child: Text(item['name'] as String)))
                            .toList(),
                        onChanged: (value) => setModalState(() => selectedExerciseId = value),
                        validator: (value) => value == null ? 'اختر التمرين' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: weightController,
                        decoration: const InputDecoration(labelText: 'الوزن (كجم)', border: OutlineInputBorder()),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) => (double.tryParse(v ?? '') ?? 0) > 0 ? null : 'أدخل وزنًا صحيحًا',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: repsController,
                        decoration: const InputDecoration(labelText: 'التكرارات', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (v) => (int.tryParse(v ?? '') ?? 0) > 0 ? null : 'أدخل تكرارات صحيحة',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: setsController,
                        decoration: const InputDecoration(labelText: 'المجموعات', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (v) => (int.tryParse(v ?? '') ?? 0) > 0 ? null : 'أدخل مجموعات صحيحة',
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final user = await ref.read(currentUserProvider.future);
                          final previousPr = await ref.read(workoutRepositoryProvider).getPreviousBestWeight(
                                exerciseId: selectedExerciseId!,
                                userId: user.id!,
                                beforeSessionId: sessionId,
                              );
                          await ref.read(workoutRepositoryProvider).createWorkoutLog(
                                WorkoutLogModel(
                                  workoutSessionId: sessionId,
                                  exerciseId: selectedExerciseId!,
                                  weight: double.parse(weightController.text),
                                  reps: int.parse(repsController.text),
                                  sets: int.parse(setsController.text),
                                ),
                              );
                          ref.invalidate(workoutLogsProvider);
                          ref.invalidate(sessionDetailProvider(sessionId));
                          ref.invalidate(weeklySetsByMuscleProvider);
                          ref.invalidate(exercisesWithLogsProvider);
                          ref.invalidate(exercisePrMapProvider);
                          if (ctx.mounted) Navigator.of(ctx).pop();
                          final newWeight = double.parse(weightController.text);
                          if (context.mounted && (previousPr == null || newWeight > previousPr)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('🏆 رقم قياسي جديد!')),
                            );
                          }
                        },
                        child: const Text('حفظ'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _deleteLog(BuildContext context, WidgetRef ref, int logId) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'حذف التمرين',
      content: 'هل أنت متأكد من حذف سجل التمرين؟',
      confirmLabel: 'حذف',
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref.read(workoutRepositoryProvider).deleteWorkoutLog(logId);
    ref.invalidate(workoutLogsProvider);
    ref.invalidate(sessionDetailProvider(sessionId));
    ref.invalidate(weeklySetsByMuscleProvider);
    ref.invalidate(exercisesWithLogsProvider);
    ref.invalidate(exercisePrMapProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionData = ref.watch(sessionDetailProvider(sessionId));

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الجلسة')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLogSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('إضافة تمرين'),
      ),
      body: sessionData.when(
        data: (data) {
          if (data == null) return const Center(child: Text('الجلسة غير موجودة'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'تاريخ الجلسة: ${AppDateUtils.shortDate(data.session.date)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if ((data.session.notes ?? '').isNotEmpty) Text('ملاحظات: ${data.session.notes}'),
              const SizedBox(height: 12),
              if (data.items.isEmpty) const Text('لا توجد تمارين مسجلة في هذه الجلسة'),
              ...data.items.map((item) {
                final logId = item.log.id;
                final card = Card(
                  child: ListTile(
                    title: Text(item.exerciseName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الوزن: ${item.log.weight} كجم - تكرارات: ${item.log.reps} - مجموعات: ${item.log.sets}'),
                        if (item.previousHint != null) Text(item.previousHint!),
                      ],
                    ),
                    trailing: item.isPersonalRecord ? const Icon(Icons.emoji_events, color: Colors.amber) : null,
                    onLongPress: logId == null ? null : () => _deleteLog(context, ref, logId),
                  ),
                );
                if (logId == null) return card;
                return Dismissible(
                  key: ValueKey(logId),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    await _deleteLog(context, ref, logId);
                    return false;
                  },
                  background: Container(
                    alignment: Alignment.centerLeft,
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: card,
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('تعذر تحميل تفاصيل الجلسة')),
      ),
    );
  }
}
