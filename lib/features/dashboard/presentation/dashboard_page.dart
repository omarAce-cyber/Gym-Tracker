import 'package:flutter/material.dart';
import 'package:gym_tracker/core/constants/app_strings.dart';
import 'package:gym_tracker/features/nutrition/presentation/nutrition_page.dart';
import 'package:gym_tracker/features/profile/presentation/profile_page.dart';
import 'package:gym_tracker/features/workout/presentation/workout_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomeOverview(),
    WorkoutPage(),
    NutritionPage(),
    ProfilePage(),
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
          NavigationDestination(icon: Icon(Icons.person), label: AppStrings.profile),
        ],
      ),
    );
  }
}

class _HomeOverview extends StatelessWidget {
  const _HomeOverview();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('مرحبًا بك في متتبع الصالة'),
    );
  }
}
