import 'package:flutter/material.dart';
import 'package:gym_tracker/core/constants/app_colors.dart';

/// شريط تقدم المغذيات الكبرى
class MacroProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final Color color;
  final String unit;

  const MacroProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.target,
    this.color = AppColors.primary,
    this.unit = 'غ',
  });

  @override
  Widget build(BuildContext context) {
    final double progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final bool exceeded = target > 0 && current > target;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
              ),
              Text(
                '${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: exceeded ? AppColors.warning : Colors.grey[600],
                      fontWeight: exceeded ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                exceeded ? AppColors.warning : color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
