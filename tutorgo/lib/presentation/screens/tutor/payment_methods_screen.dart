import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/user_service.dart';

/// Shows the tutor's saved payout account (from Payout Settings).
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  Map<String, dynamic>? _payout;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final service = UserService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
    );
    final profile = await service.getMyProfile();
    if (mounted) {
      setState(() {
        _payout = profile?['tutorProfile']?['payoutAccount']
            as Map<String, dynamic>?;
        _loading = false;
      });
    }
  }

  String _maskedAccount(String account) {
    final digits = account.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 4) return account;
    return '•••• ${digits.substring(digits.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPayout = _payout != null &&
        (_payout!['accountNumber'] ?? '').toString().isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Payment Methods", style: theme.textTheme.titleLarge),
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Payout Account", style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.s16),
                  if (hasPayout)
                    _payoutCard(context)
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.s20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Column(
                        children: [
                          Icon(LucideIcons.wallet,
                              size: 40, color: theme.colorScheme.primary),
                          const SizedBox(height: 12),
                          Text('No payout account set up yet',
                              style: theme.textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.s16),
                  Row(
                    children: [
                      Icon(LucideIcons.info,
                          size: 16, color: theme.textTheme.bodySmall?.color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'To add or change your payout account, go to Payout Settings.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _payoutCard(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final method = (_payout!['method'] ?? '').toString();
    final bank = (_payout!['bank'] ?? '').toString();
    final holder = (_payout!['accountHolder'] ?? '').toString();
    final account = (_payout!['accountNumber'] ?? '').toString();
    final title = method == 'Bank Transfer' && bank.isNotEmpty ? bank : method;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              method == 'Bank Transfer'
                  ? LucideIcons.landmark
                  : LucideIcons.smartphone,
              size: 28,
              color: primary,
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s4),
                Text(_maskedAccount(account),
                    style: theme.textTheme.bodyMedium),
                if (holder.isNotEmpty)
                  Text(holder, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
