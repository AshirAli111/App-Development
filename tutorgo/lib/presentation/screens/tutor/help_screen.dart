import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';

class HelpCenterScreen extends StatelessWidget {
  HelpCenterScreen({super.key});

  final List<Map<String, String>> faqs = [
    {
      "q": "How do I update my profile?",
      "a": "Go to Profile → Edit Profile and update your information.",
    },
    {
      "q": "How can I withdraw money?",
      "a":
          "Connect your bank account in Payout Settings and request a withdrawal.",
    },
    {
      "q": "How are sessions booked?",
      "a": "Students can book sessions based on your available schedule.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Help Center",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.s20),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return _faqTile(
            context,
            question: faqs[index]["q"]!,
            answer: faqs[index]["a"]!,
          );
        },
      ),
    );
  }

  Widget _faqTile(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: .15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        iconColor: Theme.of(context).colorScheme.primary,
        collapsedIconColor: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
        title: Text(question, style: Theme.of(context).textTheme.titleMedium),
        childrenPadding: const EdgeInsets.all(AppSpacing.s16),
        children: [Text(answer, style: Theme.of(context).textTheme.bodyMedium)],
      ),
    );
  }
}
