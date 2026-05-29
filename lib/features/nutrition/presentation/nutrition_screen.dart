import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/core/utils/date_utils.dart';
import 'package:gym_tracker/features/nutrition/data/models/meal_model.dart';
import 'package:gym_tracker/shared/providers/app_providers.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealsProvider);
    final mealLogs = ref.watch(mealLogsProvider);

    return DefaultTabController(
      length: 2,
      child: Column(
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
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('تعذر تحميل الوجبات')),
                ),
                mealLogs.when(
                  data: (logs) {
                    final loadedMeals = meals.asData?.value ?? <MealModel>[];
                    final mealsById = <int, String>{
                      for (final meal in loadedMeals)
                        if (meal.id != null) meal.id!: meal.name,
                    };
                    if (logs.isEmpty) return const Center(child: Text('لا توجد سجلات تغذية'));
                    return ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        final mealName = mealsById[log.mealId] ?? 'وجبة غير معروفة';
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(mealName),
                            subtitle: Text(
                              'الكمية: ${log.quantityInGram} غرام - التاريخ: ${AppDateUtils.shortDate(log.date)}',
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('تعذر تحميل السجل الغذائي')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
