import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';

class StudentLearningHistoryScreen extends StatelessWidget {
  const StudentLearningHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = [
      {"title": "Algebra – Chapter 1", "date": "Jan 22, 2025"},
      {"title": "Physics – Forces", "date": "Jan 20, 2025"},
      {"title": "Biology – Cells", "date": "Jan 18, 2025"},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Learning History",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.4,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.s16),
        itemCount: history.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final h = history[i];

          return Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: .15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  h["title"]!,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(h["date"]!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          );
        },
      ),
    );
  }
}
