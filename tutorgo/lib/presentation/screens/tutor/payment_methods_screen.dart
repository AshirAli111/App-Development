import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/user_service.dart';
import 'package:next_step_learning/routes/app_routes.dart';

/// Tutor "Payment Methods" — shows ONLY the payout account the tutor added in
/// Payout Settings (no placeholder cards). Managing it routes to Payout Settings.
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  bool _loading = true;
  Map<String, dynamic>? _payout;

  UserService get _userService {
    final auth = context.read<AuthProvider>();
    return UserService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await _userService.getMyProfile();
    if (!mounted) return;
    setState(() {
      _payout = profile?['payoutAccount'] as Map<String, dynamic>?;
      _loading = false;
    });
  }

  Future<void> _manage() async {
    await Navigator.pushNamed(context, AppRoutes.payoutSettings);
    // Refresh in case the tutor added/changed the account.
    if (mounted) {
      setState(() => _loading = true);
      _load();
    }
  }

  String _maskedIdentifier(Map<String, dynamic> payout) {
    final isWallet = payout['kind'] == 'wallet';
    final raw =
        (isWallet ? payout['phone'] : payout['accountNumber'])?.toString() ?? '';
    final digits = raw.replaceAll(RegExp(r'\s'), '');
    if (digits.length <= 4) return digits;
    return '**** ${digits.substring(digits.length - 4)}';
  }

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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s20,
                vertical: AppSpacing.s20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Payout Account", style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.s16),
                  if (_payout == null)
                    _emptyState(context)
                  else
                    _accountCard(context, _payout!),
                  const Spacer(),
                  _manageButton(context),
                ],
              ),
            ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.wallet, size: 34, color: theme.iconTheme.color),
          const SizedBox(height: AppSpacing.s12),
          Text("No payout account added", style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s4),
          Text(
            "Add a bank account or mobile wallet to receive your earnings.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _accountCard(BuildContext context, Map<String, dynamic> payout) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isWallet = payout['kind'] == 'wallet';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary, width: 2),
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
            child: Icon(
              isWallet ? LucideIcons.smartphone : LucideIcons.banknote,
              color: primary,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payout['method']?.toString() ?? 'Payout Account',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  '${payout['accountName'] ?? ''} — ${_maskedIdentifier(payout)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: primary, size: 22),
        ],
      ),
    );
  }

  Widget _manageButton(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: _manage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            _payout == null ? "Add Payout Account" : "Manage Payout Account",
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
