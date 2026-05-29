import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/shared/providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    final sessions = ref.watch(workoutSessionsProvider);
    final logs = ref.watch(mealLogsProvider);

    return users.when(
      data: (list) {
        if (list.isEmpty) {
          return const Center(child: Text('لا يوجد ملف مستخدم حتى الآن'));
        }
        final user = list.first;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(user.name.isNotEmpty ? user.name.characters.first : '؟'),
            ),
            const SizedBox(height: 12),
            Text(
              user.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('الهدف'),
                subtitle: Text(_goalInArabic(user.goal)),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.monitor_weight),
                title: const Text('الوزن الحالي'),
                subtitle: Text(user.weight == null ? 'غير محدد' : '${user.weight} كجم'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.height),
                title: const Text('الطول'),
                subtitle: Text(user.height == null ? 'غير محدد' : '${user.height} سم'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text('إجمالي جلسات التمرين'),
                subtitle: Text(
                  sessions.when(
                    data: (items) => '${items.length}',
                    loading: () => '...',
                    error: (_, __) => '-',
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: const Text('إجمالي سجلات التغذية'),
                subtitle: Text(
                  logs.when(
                    data: (items) => '${items.length}',
                    loading: () => '...',
                    error: (_, __) => '-',
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('تعذر تحميل الملف الشخصي')),
    );
  }

  String _goalInArabic(String goal) {
    switch (goal) {
      case 'BuildMuscle':
        return 'بناء العضلات';
      case 'LoseWeight':
        return 'خسارة الوزن';
      case 'Maintain':
        return 'الحفاظ على الوزن';
      default:
        return goal;
    }
  }
}
