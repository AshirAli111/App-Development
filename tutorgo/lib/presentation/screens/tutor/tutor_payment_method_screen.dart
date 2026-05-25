import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TutorPaymentMethodsScreen extends StatelessWidget {
  const TutorPaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        title: Text(
          "Payment Methods",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _cardTile(context, "Visa •••• 3945", LucideIcons.creditCard),
          _cardTile(context, "Mastercard •••• 8872", LucideIcons.creditCard),
          _cardTile(context, "Add New Card", LucideIcons.plusCircle),
        ],
      ),
    );
  }

  Widget _cardTile(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: .15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: theme.iconTheme.color),
        ],
      ),
    );
  }
}
