import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/payment_service.dart';
import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/presentation/components/inputs/phone_field.dart';

/// Student sends money to the platform (admin) account via a chosen gateway.
class SendPaymentScreen extends StatefulWidget {
  /// Preselected method id (easypaisa | jazzcash | bank_transfer | card).
  final String? method;
  const SendPaymentScreen({super.key, this.method});

  @override
  State<SendPaymentScreen> createState() => _SendPaymentScreenState();
}

class _SendPaymentScreenState extends State<SendPaymentScreen> {
  // Platform (admin) destination accounts shown to the student.
  static const _admin = <String, Map<String, String>>{
    'easypaisa': {'label': 'Easypaisa', 'account': '0345-1234567 (NextStepLearning)'},
    'jazzcash': {'label': 'JazzCash', 'account': '0301-7654321 (NextStepLearning)'},
    'bank_transfer': {
      'label': 'Bank Transfer',
      'account': 'Meezan Bank • 0123 4567 8901 2345 (NextStepLearning)'
    },
    'card': {'label': 'Card', 'account': 'Secure card payment'},
  };

  final _amountCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  late String _method;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _method = widget.method ?? 'easypaisa';
    _nameCtrl.text = context.read<AuthProvider>().fullName;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    _accountCtrl.dispose();
    super.dispose();
  }

  String get _accountHint {
    switch (_method) {
      case 'easypaisa':
      case 'jazzcash':
        return 'Your mobile number (e.g. 03xx-xxxxxxx)';
      case 'card':
        return 'Your card number';
      default:
        return 'Your bank account number / IBAN';
    }
  }

  bool _accountValid(String v) {
    final digits = v.replaceAll(RegExp(r'\D'), '');
    switch (_method) {
      case 'easypaisa':
      case 'jazzcash':
        return digits.length >= 10; // country code + 10 local digits
      case 'card':
        return digits.length >= 12;
      default:
        return digits.length >= 8;
    }
  }

  Future<void> _pay() async {
    final amount = int.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) return _snack('Enter a valid amount');
    if (_nameCtrl.text.trim().isEmpty) return _snack('Enter your name');
    if (!_accountValid(_accountCtrl.text.trim())) {
      return _snack('Enter valid account details for ${_admin[_method]!['label']}');
    }

    setState(() => _submitting = true);
    final auth = context.read<AuthProvider>();
    final service = PaymentService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
      role: auth.role,
    );
    final result = await service.createDeposit(
      amountPKR: amount,
      method: _method,
      senderName: _nameCtrl.text.trim(),
      senderAccount: _accountCtrl.text.trim(),
    );
    if (!mounted) return;
    if (result != null) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Payment successful'),
          content: Text(
              'PKR $amount sent to NextStepLearning via ${_admin[_method]!['label']}.'),
          actions: [
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
          ],
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } else {
      setState(() => _submitting = false);
      _snack('Payment failed. Try again.');
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final admin = _admin[_method]!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Send Payment', style: theme.textTheme.titleLarge),
        backgroundColor: theme.cardColor,
        elevation: 0.4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field('Amount (PKR)', _amountCtrl,
                keyboardType: TextInputType.number),
            const SizedBox(height: AppSpacing.s16),
            Text('Pay with', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _admin.entries.map((e) {
                final selected = _method == e.key;
                return ChoiceChip(
                  label: Text(e.value['label']!),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    _method = e.key;
                    _accountCtrl.clear();
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.s16),

            // Admin destination info
            Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: .3)),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.landmark, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Send to (NextStepLearning)',
                            style: theme.textTheme.bodySmall),
                        Text(admin['account']!,
                            style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s20),

            _field('Your Name', _nameCtrl),
            const SizedBox(height: AppSpacing.s16),
            if (_method == 'easypaisa' || _method == 'jazzcash') ...[
              Text(_accountHint, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 6),
              PhoneField(controller: _accountCtrl),
            ] else
              _field(_accountHint, _accountCtrl,
                  keyboardType: TextInputType.number),
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
                onPressed: _submitting ? null : _pay,
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Pay Now',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          decoration: InputDecoration(
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
          ),
        ),
      ],
    );
  }
}
