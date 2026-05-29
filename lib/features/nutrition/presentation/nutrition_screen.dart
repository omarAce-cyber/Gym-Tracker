import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/core/utils/date_utils.dart';
import 'package:gym_tracker/features/nutrition/data/models/meal_log_model.dart';
import 'package:gym_tracker/features/nutrition/presentation/meal_form_screen.dart';
import 'package:gym_tracker/shared/providers/app_providers.dart';
import 'package:gym_tracker/shared/widgets/macro_progress_bar.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  Future<void> _logMeal(BuildContext context, WidgetRef ref, int mealId) async {
    final controller = TextEditingController(text: '100');
    final quantity = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إدخال الكمية'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'الكمية بالجرام'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(double.tryParse(controller.text)),
            child: const Text('تسجيل'),
          ),
        ],
      ),
    );
    if (quantity == null || quantity <= 0) return;
    final user = await ref.read(currentUserProvider.future);
    await ref.read(nutritionRepositoryProvider).createMealLog(
          MealLogModel(
            userId: user.id!,
            mealId: mealId,
            date: AppDateUtils.formatDate(DateTime.now()),
            quantityInGram: quantity,
          ),
        );
    ref.invalidate(mealLogsProvider);
    ref.invalidate(todayMealLogsProvider);
    ref.invalidate(dailyNutritionProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealsProvider);
    final todayLogs = ref.watch(todayMealLogsProvider);
    final todaySummary = ref.watch(dailyNutritionProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MealFormScreen()),
            );
          },
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'الوجبات'),
                Tab(text: 'السجل'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  meals.when(
                    data: (mealList) {
                      if (mealList.isEmpty) return const Center(child: Text('لا توجد وجبات محفوظة'));
                      return ListView.builder(
                        itemCount: mealList.length,
                        itemBuilder: (context, index) {
                          final meal = mealList[index];
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.restaurant),
                              title: Text(meal.name),
                              subtitle: Text(
                                'السعرات: ${meal.calories} - بروتين: ${meal.protein}غ - كارب: ${meal.carbs}غ - دهون: ${meal.fat}غ',
                              ),
                              trailing: OutlinedButton(
                                onPressed: meal.id == null ? null : () => _logMeal(context, ref, meal.id!),
                                child: const Text('تسجيل'),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(child: Text('تعذر تحميل الوجبات')),
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      todaySummary.when(
                        data: (summary) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('مجموع اليوم: ${summary.calories.toStringAsFixed(0)} سعرة'),
                                const SizedBox(height: 8),
                                MacroProgressBar(label: 'بروتين', current: summary.protein, target: 150),
                                MacroProgressBar(label: 'كارب', current: summary.carbs, target: 250, color: Colors.orange),
                                MacroProgressBar(label: 'دهون', current: summary.fat, target: 70, color: Colors.purple),
                              ],
                            ),
                          ),
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 8),
                      todayLogs.when(
                        data: (logs) {
                          if (logs.isEmpty) return const Center(child: Text('لا توجد سجلات تغذية لليوم'));
                          return Column(
                            children: logs
                                .map(
                                  (log) => Card(
                                    child: ListTile(
                                      leading: const Icon(Icons.history),
                                      title: Text(log.mealName),
                                      subtitle: Text(
                                        'الكمية: ${log.quantityInGram} غرام - سعرات: ${log.calories.toStringAsFixed(0)}',
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Center(child: Text('تعذر تحميل سجل اليوم')),
                      ),
                    ],
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
