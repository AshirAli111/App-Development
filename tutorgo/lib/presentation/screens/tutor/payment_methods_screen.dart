import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:next_step_learning/core/theme/spacing.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Payment Methods", style: theme.textTheme.titleLarge),
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s20,
          vertical: AppSpacing.s20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Saved Cards", style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.s16),

            _cardItem(
              context: context,
              brand: "Visa",
              masked: "**** **** **** 9238",
              icon: LucideIcons.creditCard,
            ),
            const SizedBox(height: AppSpacing.s16),

            _cardItem(
              context: context,
              brand: "Mastercard",
              masked: "**** **** **** 5521",
              icon: LucideIcons.creditCard,
            ),

            const SizedBox(height: AppSpacing.s32),

            _addCardButton(context),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 💳 CARD ITEM
  // -------------------------------------------------------------
  Widget _cardItem({
    required BuildContext context,
    required String brand,
    required String masked,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: .15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: primary),
          ),

          const SizedBox(width: AppSpacing.s16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(brand, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s4),
                Text(masked, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),

          Icon(Icons.chevron_right, color: theme.iconTheme.color),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // ➕ Add New Card Button
  // -------------------------------------------------------------
  Widget _addCardButton(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            "Add New Card",
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
