import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/shared/providers/app_providers.dart';

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionData = ref.watch(sessionDetailProvider(sessionId));

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الجلسة')),
      body: sessionData.when(
        data: (data) {
          if (data == null) {
            return const Center(child: Text('الجلسة غير موجودة'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'تاريخ الجلسة: ${data.session.date.substring(0, data.session.date.length >= 10 ? 10 : data.session.date.length)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if ((data.session.notes ?? '').isNotEmpty) Text('ملاحظات: ${data.session.notes}'),
              const SizedBox(height: 12),
              if (data.items.isEmpty) const Text('لا توجد تمارين مسجلة في هذه الجلسة'),
              ...data.items.map((item) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.exerciseName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (item.isPersonalRecord)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Text('إنجاز شخصي'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('الوزن: ${item.log.weight} كجم'),
                        Text('التكرارات: ${item.log.reps}'),
                        Text('المجموعات: ${item.log.sets}'),
                        const Divider(),
                        Text(
                          item.previousBestWeight == null
                              ? 'لا يوجد أداء سابق لهذا التمرين'
                              : 'أفضل أداء سابق: ${item.previousBestWeight} كجم - ${item.previousBestReps ?? 0} تكرارات',
                        ),
                      ],
                    ),
                  ),
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
