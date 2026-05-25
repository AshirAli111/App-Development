import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';

class StudentPaymentMethodsScreen extends StatelessWidget {
  const StudentPaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final methods = [
      {"name": "Visa **** 4242"},
      {"name": "Jazzcash"},
      {"name": "Easypaisa"},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Payment Methods",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).cardColor,
        elevation: .3,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.s16),
        itemCount: methods.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: .15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  methods[i]["name"]!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).iconTheme.color,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
