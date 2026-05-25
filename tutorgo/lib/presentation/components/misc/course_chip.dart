import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

class CourseChip extends StatelessWidget {
  final String label;
  final bool selected;

  const CourseChip({super.key, required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : AppColors.textDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
