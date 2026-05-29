import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/core/constants/app_strings.dart';
import 'package:gym_tracker/features/nutrition/presentation/nutrition_screen.dart';
import 'package:gym_tracker/features/profile/presentation/profile_screen.dart';
import 'package:gym_tracker/features/workout/presentation/workout_screen.dart';
import 'package:gym_tracker/features/workout/presentation/progress_screen.dart';
import 'package:gym_tracker/shared/providers/app_providers.dart';

const double _chartYAxisPaddingFactor = 1.2;

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
    final weeklyVolume = ref.watch(weeklyVolumeProvider);
    final sessions = ref.watch(workoutSessionsProvider);
    final meals = ref.watch(mealLogsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'ملخص هذا الأسبوع',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: weeklyVolume.when(
              data: (points) {
                final maxY = points.isEmpty
                    ? 1.0
                    : points.map((e) => e.volume).reduce((a, b) => a > b ? a : b);
                return SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY <= 0 ? 1 : maxY * _chartYAxisPaddingFactor,
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              final index = value.toInt();
                              if (index < 0 || index >= points.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(points[index].dayLabel),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(points.length, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: points[index].volume,
                              width: 18,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox(
                height: 220,
                child: Center(child: Text('تعذر تحميل الرسم الأسبوعي')),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'جلسات التمرين',
                value: sessions.when(
                  data: (data) => '${data.length}',
                  loading: () => '...',
                  error: (_, __) => '-',
                ),
              ),
            ),
            Expanded(
              child: _SummaryCard(
                title: 'سجلات التغذية',
                value: meals.when(
                  data: (data) => '${data.length}',
                  loading: () => '...',
                  error: (_, __) => '-',
                ),
              ),
            ),
          ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
