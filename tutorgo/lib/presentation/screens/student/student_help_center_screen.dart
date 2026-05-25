import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';

class StudentHelpCenterScreen extends StatelessWidget {
  const StudentHelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {"q": "How do I book a class?", "a": "Go to any tutor and send request."},
      {"q": "How do I message a tutor?", "a": "Open tutor profile → Chat."},
      {"q": "What are subscriptions?", "a": "You can buy class packages."},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Help Center",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).cardColor,
        elevation: .3,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.s16),
        itemCount: faqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final item = faqs[i];

          return Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: .15),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item["q"]!, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(item["a"]!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          );
        },
      ),
    );
  }
}
