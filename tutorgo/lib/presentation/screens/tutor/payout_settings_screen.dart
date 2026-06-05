import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:next_step_learning/core/theme/spacing.dart';

class PayoutSettingsScreen extends StatelessWidget {
  const PayoutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text("Payout Settings", style: theme.textTheme.titleLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s20,
          vertical: AppSpacing.s20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Active Payout Method", style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.s16),

            _payoutCard(
              context: context,
              title: "Bank Transfer",
              subtitle: "Meezan Bank — **** 4421",
              icon: LucideIcons.banknote,
              active: true,
            ),

            const SizedBox(height: AppSpacing.s32),

            Text("Other Methods", style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.s16),

            _payoutCard(
              context: context,
              title: "JazzCash",
              subtitle: "Not Connected",
              icon: LucideIcons.smartphone,
            ),

            const SizedBox(height: AppSpacing.s16),

            _payoutCard(
              context: context,
              title: "EasyPaisa",
              subtitle: "Not Connected",
              icon: LucideIcons.wallet,
            ),

            const SizedBox(height: AppSpacing.s16),

            _payoutCard(
              context: context,
              title: "PayPal",
              subtitle: "Not Connected",
              icon: Icons.payment,
            ),

            const Spacer(),
            _addNewButton(context),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------
  // 🏦 PAYOUT METHOD CARD
  // -----------------------------------------------------------------
  Widget _payoutCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    bool active = false,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? primary : theme.dividerColor,
          width: active ? 2 : 1,
        ),
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
            child: Icon(icon, color: primary, size: 26),
          ),

          const SizedBox(width: AppSpacing.s16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s4),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),

          Icon(Icons.chevron_right, color: theme.iconTheme.color, size: 22),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  // ➕ ADD NEW PAYOUT BUTTON
  // -----------------------------------------------------------------
  Widget _addNewButton(BuildContext context) {
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
            "Add New Payout Method",
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
