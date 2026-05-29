import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/core/constants/app_strings.dart';
import 'package:gym_tracker/core/utils/date_utils.dart';
import 'package:gym_tracker/features/nutrition/presentation/nutrition_screen.dart';
import 'package:gym_tracker/features/profile/presentation/profile_screen.dart';
import 'package:gym_tracker/features/workout/presentation/progress_screen.dart';
import 'package:gym_tracker/features/workout/presentation/workout_screen.dart';
import 'package:gym_tracker/shared/providers/app_providers.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _DashboardHomeTab(),
    WorkoutScreen(),
    NutritionScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) => setState(() => _currentIndex = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: AppStrings.dashboard),
          NavigationDestination(icon: Icon(Icons.fitness_center), label: AppStrings.workouts),
          NavigationDestination(icon: Icon(Icons.restaurant_menu), label: AppStrings.nutrition),
          NavigationDestination(icon: Icon(Icons.show_chart), label: AppStrings.progress),
          NavigationDestination(icon: Icon(Icons.person), label: AppStrings.profile),
        ],
      ),
    );
  }
}

class _DashboardHomeTab extends ConsumerWidget {
  const _DashboardHomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklySets = ref.watch(weeklySetsByMuscleProvider);
    final recentSessions = ref.watch(recentSessionsProvider);
    final dailyNutrition = ref.watch(dailyNutritionProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('الحجم الأسبوعي (مجموعات)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: weeklySets.when(
              data: (data) {
                final entries = data.entries.toList();
                if (entries.isEmpty) return const SizedBox(height: 220, child: Center(child: Text('لا توجد بيانات')));
                final maxY = entries.map((e) => e.value.toDouble()).reduce((a, b) => a > b ? a : b);
                return SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY <= 0 ? 1 : maxY + 2,
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              final i = value.toInt();
                              if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(entries[i].key, style: const TextStyle(fontSize: 10)),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(
                        entries.length,
                        (i) => BarChartGroupData(
                          x: i,
                          barRods: [BarChartRodData(toY: entries[i].value.toDouble(), width: 14)],
                        ),
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox(height: 220, child: Center(child: Text('تعذر تحميل الرسم'))),
            ),
          ),
        ),
        const SizedBox(height: 12),
        dailyNutrition.when(
          data: (summary) => _SummaryCard(title: 'سعرات اليوم', value: summary.calories.toStringAsFixed(0)),
          loading: () => const _SummaryCard(title: 'سعرات اليوم', value: '...'),
          error: (_, __) => const _SummaryCard(title: 'سعرات اليوم', value: '-'),
        ),
        const SizedBox(height: 12),
        const Text('آخر 3 جلسات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        recentSessions.when(
          data: (sessions) {
            if (sessions.isEmpty) return const Text('لا توجد جلسات');
            return Column(
              children: sessions
                  .map(
                    (session) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.fitness_center),
                        title: Text(AppDateUtils.shortDate(session.date)),
                        subtitle: Text(session.notes ?? 'بدون ملاحظات'),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('تعذر تحميل الجلسات'),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
