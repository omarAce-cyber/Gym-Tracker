import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/core/utils/date_utils.dart';
import 'package:gym_tracker/shared/providers/app_providers.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  int? _selectedExerciseId;

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exercisesWithLogsProvider);
    final prs = ref.watch(exercisePrMapProvider);
    final history = _selectedExerciseId == null ? null : ref.watch(exerciseHistoryProvider(_selectedExerciseId!));

    return exercises.when(
      data: (items) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('التقدم حسب التمرين', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (items.isEmpty) const Text('لا توجد بيانات تمارين حتى الآن'),
            ...items.map((exercise) {
              final pr = prs.asData?.value[exercise.id] ?? 0;
              return Card(
                child: ListTile(
                  title: Text(exercise.name),
                  subtitle: Text('أفضل وزن: ${pr.toStringAsFixed(1)} كجم'),
                  trailing: const Icon(Icons.show_chart),
                  onTap: () => setState(() => _selectedExerciseId = exercise.id),
                ),
              );
            }),
            const SizedBox(height: 12),
            if (_selectedExerciseId != null) const Text('تاريخ الأوزان', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (history != null)
              history.when(
                data: (points) {
                  if (_selectedExerciseId == null || points.isEmpty) return const SizedBox.shrink();
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        height: 220,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  for (int i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].weight),
                                ],
                                isCurved: true,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, _) {
                                    final i = value.toInt();
                                    if (i < 0 || i >= points.length) return const SizedBox.shrink();
                                    return Text(AppDateUtils.shortDate(points[i].date), style: const TextStyle(fontSize: 10));
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('تعذر تحميل الرسم البياني'),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('تعذر تحميل بيانات التقدم')),
    );
  }
}
