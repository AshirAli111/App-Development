import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';

class StudentLanguageScreen extends StatelessWidget {
  const StudentLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languages = ["English", "Urdu", "Arabic", "Hindi"];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Language", style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.4,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.s16),
        itemCount: languages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: .15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              languages[i],
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        },
      ),
    );
  }
}
