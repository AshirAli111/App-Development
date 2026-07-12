import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/user_service.dart';
import 'package:next_step_learning/core/constants/banks.dart';
import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/presentation/components/inputs/phone_field.dart';

/// Tutor enters the bank/wallet account where they want to receive payouts.
class PayoutSettingsScreen extends StatefulWidget {
  const PayoutSettingsScreen({super.key});

  @override
  State<PayoutSettingsScreen> createState() => _PayoutSettingsScreenState();
}

class _PayoutSettingsScreenState extends State<PayoutSettingsScreen> {
  static const _methods = ['Bank Transfer', 'Easypaisa', 'JazzCash'];

  final _holderCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  String _method = 'Bank Transfer';
  String? _bank;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _holderCtrl.dispose();
    _accountCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final service = UserService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
    );
    final profile = await service.getMyProfile();
    final payout = profile?['tutorProfile']?['payoutAccount']
        as Map<String, dynamic>?;
    if (mounted) {
      setState(() {
        if (payout != null) {
          final m = (payout['method'] ?? '').toString();
          if (_methods.contains(m)) _method = m;
          final b = (payout['bank'] ?? '').toString();
          if (kPakistaniBanks.contains(b)) _bank = b;
          _holderCtrl.text = (payout['accountHolder'] ?? '').toString();
          _accountCtrl.text = (payout['accountNumber'] ?? '').toString();
        }
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final isBank = _method == 'Bank Transfer';
    if (isBank && _bank == null) return _snack('Select a bank');
    if (_holderCtrl.text.trim().isEmpty) {
      return _snack('Enter the account holder name');
    }
    final digits = _accountCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (isBank && digits.length < 8) {
      return _snack('Enter a valid account number / IBAN');
    }
    if (!isBank && digits.length < 10) {
      return _snack('Enter a valid mobile number');
    }
    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    final service = UserService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
    );
    final result = await service.updateProfile({
      'tutorProfile': {
        'payoutAccount': {
          'method': _method,
          'bank': isBank ? _bank : '',
          'accountHolder': _holderCtrl.text.trim(),
          'accountNumber': _accountCtrl.text.trim(),
        },
      },
    });
    if (!mounted) return;
    setState(() => _saving = false);
    _snack(result != null
        ? 'Payout account saved'
        : 'Could not save payout account');
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text('Payout Settings', style: theme.textTheme.titleLarge),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Where should we send your earnings?',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.s20),
                  Text('Method', style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _method,
                    isExpanded: true,
                    items: _methods
                        .map((m) =>
                            DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => _method = v ?? _method),
                    decoration: _dec(theme),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  if (_method == 'Bank Transfer') ...[
                    Text('Bank', style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _bank,
                      isExpanded: true,
                      hint: const Text('Select bank'),
                      items: kPakistaniBanks
                          .map((b) =>
                              DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (v) => setState(() => _bank = v),
                      decoration: _dec(theme),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    _field('Account Holder Name', _holderCtrl),
                    const SizedBox(height: AppSpacing.s16),
                    _field('Account Number / IBAN', _accountCtrl,
                        keyboardType: TextInputType.number),
                  ] else ...[
                    _field('Account Holder Name', _holderCtrl),
                    const SizedBox(height: AppSpacing.s16),
                    Text('Mobile Number', style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 6),
                    PhoneField(controller: _accountCtrl),
                  ],
                  const SizedBox(height: AppSpacing.s32),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Save Payout Account',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  InputDecoration _dec(ThemeData theme) => InputDecoration(
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
      );

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType? keyboardType}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 6),
        TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            decoration: _dec(theme)),
      ],
    );
  }
}
