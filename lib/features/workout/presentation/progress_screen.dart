import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/shared/providers/app_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressDataProvider);

    return progress.when(
      data: (data) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'منحنى حجم التمرين',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 220,
                  child: data.chart.isEmpty
                      ? const Center(child: Text('لا توجد بيانات كافية للرسم البياني'))
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  for (int index = 0; index < data.chart.length; index++)
                                    FlSpot(index.toDouble(), data.chart[index].value),
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
                                    final index = value.toInt();
                                    if (index < 0 || index >= data.chart.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return Text(data.chart[index].label);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'أفضل الأرقام لكل تمرين',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (data.prs.isEmpty) const Text('لا توجد أرقام شخصية مسجلة بعد'),
            ...data.prs.map((item) {
              return Card(
                child: ListTile(
                  title: Text(item.exerciseName),
                  subtitle: Text('أفضل وزن: ${item.bestWeight} كجم - التكرارات: ${item.bestReps}'),
                  trailing: Text(item.sessionDate.length >= 10 ? item.sessionDate.substring(0, 10) : item.sessionDate),
                ),
              );
            }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('تعذر تحميل بيانات التقدم')),
    );
  }
}
