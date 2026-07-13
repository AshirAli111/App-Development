import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import 'package:next_step_learning/core/constants/banks.dart';
import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/user_service.dart';
import 'package:next_step_learning/presentation/widgets/phone_number_field.dart';

class PayoutSettingsScreen extends StatefulWidget {
  const PayoutSettingsScreen({super.key});

  @override
  State<PayoutSettingsScreen> createState() => _PayoutSettingsScreenState();
}

class _PayoutSettingsScreenState extends State<PayoutSettingsScreen> {
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

  String _maskedIdentifier(Map<String, dynamic> payout) {
    final isWallet = payout['kind'] == 'wallet';
    final raw = (isWallet ? payout['phone'] : payout['accountNumber'])
            ?.toString() ??
        '';
    final digits = raw.replaceAll(RegExp(r'\s'), '');
    if (digits.length <= 4) return digits;
    return '**** ${digits.substring(digits.length - 4)}';
  }

  IconData _iconFor(Map<String, dynamic> payout) {
    return payout['kind'] == 'wallet'
        ? LucideIcons.smartphone
        : LucideIcons.banknote;
  }

  Future<void> _openAddSheet() async {
    final saved = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddPayoutSheet(),
    );

    if (saved == null) return;

    setState(() => _loading = true);
    final updated = await _userService.updateProfile({'payoutAccount': saved});
    if (!mounted) return;
    setState(() {
      _payout = (updated?['payoutAccount'] as Map<String, dynamic>?) ?? saved;
      _loading = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payout method saved')),
      );
    }
  }

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
                  Text("Active Payout Method",
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.s16),
                  if (_payout == null)
                    _emptyState(context)
                  else
                    _payoutCard(
                      context: context,
                      title: _payout!['method']?.toString() ?? 'Payout Method',
                      subtitle:
                          '${_payout!['accountName'] ?? ''} — ${_maskedIdentifier(_payout!)}',
                      icon: _iconFor(_payout!),
                      active: true,
                    ),
                  const Spacer(),
                  _addNewButton(context),
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
          Text(
            "No payout method yet",
            style: theme.textTheme.titleMedium,
          ),
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
          if (active)
            Icon(Icons.check_circle, color: primary, size: 22),
        ],
      ),
    );
  }

  Widget _addNewButton(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _openAddSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            _payout == null ? "Add Payout Method" : "Change Payout Method",
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet that collects a new payout account (bank or wallet).
class _AddPayoutSheet extends StatefulWidget {
  const _AddPayoutSheet();

  @override
  State<_AddPayoutSheet> createState() => _AddPayoutSheetState();
}

class _AddPayoutSheetState extends State<_AddPayoutSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  PayoutOption? _selected;
  String _phone = '';

  @override
  void dispose() {
    _nameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selected == null) return;

    final payout = <String, dynamic>{
      'method': _selected!.name,
      'kind': _selected!.isWallet ? 'wallet' : 'bank',
      'accountName': _nameController.text.trim(),
    };
    if (_selected!.isWallet) {
      payout['phone'] = _phone.trim();
    } else {
      payout['accountNumber'] = _accountNumberController.text.trim();
    }

    Navigator.pop(context, payout);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(12));
    final isWallet = _selected?.isWallet ?? false;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.s20,
        right: AppSpacing.s20,
        top: AppSpacing.s20,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text("Add Payout Method", style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.s20),

            // Bank / wallet dropdown
            DropdownButtonFormField<PayoutOption>(
              initialValue: _selected,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Bank / Wallet',
                border: border,
              ),
              items: [
                DropdownMenuItem<PayoutOption>(
                  enabled: false,
                  child: Text('— Mobile Wallets —',
                      style: theme.textTheme.labelSmall),
                ),
                ...kWallets.map(
                  (o) => DropdownMenuItem(value: o, child: Text(o.name)),
                ),
                DropdownMenuItem<PayoutOption>(
                  enabled: false,
                  child:
                      Text('— Banks —', style: theme.textTheme.labelSmall),
                ),
                ...kPakistaniBanks.map(
                  (o) => DropdownMenuItem(value: o, child: Text(o.name)),
                ),
              ],
              validator: (v) => v == null ? 'Please select a bank or wallet' : null,
              onChanged: (v) => setState(() => _selected = v),
            ),
            const SizedBox(height: AppSpacing.s16),

            // Account holder name
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Account Holder Name',
                border: border,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Account holder name is required'
                  : null,
            ),
            const SizedBox(height: AppSpacing.s16),

            // Identifier: wallet phone (10 digits) OR bank account number
            if (isWallet)
              PhoneNumberField(
                label: 'Wallet Number',
                onChanged: (value) => _phone = value,
              )
            else
              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Account Number / IBAN',
                  border: border,
                ),
                validator: (v) => (v == null || v.trim().length < 6)
                    ? 'Enter a valid account number'
                    : null,
              ),
            const SizedBox(height: AppSpacing.s24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Save Payout Method'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
