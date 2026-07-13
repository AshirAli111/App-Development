import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/banks.dart';
import '../../../core/theme/spacing.dart';
import '../../widgets/phone_number_field.dart';

class StudentPaymentMethodsScreen extends StatelessWidget {
  const StudentPaymentMethodsScreen({super.key});

  IconData _iconFor(String id) {
    switch (id) {
      case 'bank_transfer':
        return Icons.account_balance;
      default:
        return Icons.phone_android;
    }
  }

  Color _colorFor(String id) {
    switch (id) {
      case 'easypaisa':
        return const Color(0xFF4CAF50);
      case 'jazzcash':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF2196F3);
    }
  }

  void _onTapChannel(BuildContext context, PaymentChannel channel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PayChannelSheet(channel: channel),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        itemCount: kPaymentChannels.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final channel = kPaymentChannels[i];
          final color = _colorFor(channel.id);
          return GestureDetector(
            onTap: () => _onTapChannel(context, channel),
            child: Container(
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
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_iconFor(channel.id), color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      channel.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Shows NextStepLearning's receiving account for the chosen channel and lets
/// the student enter the account they are paying from.
class _PayChannelSheet extends StatefulWidget {
  final PaymentChannel channel;
  const _PayChannelSheet({required this.channel});

  @override
  State<_PayChannelSheet> createState() => _PayChannelSheetState();
}

class _PayChannelSheetState extends State<_PayChannelSheet> {
  final _formKey = GlobalKey<FormState>();
  final _payerController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _payerController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    final amount = _amountController.text.trim();
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 60),
            const SizedBox(height: 12),
            const Text(
              'Payment Submitted',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your ${widget.channel.name} payment of PKR $amount to '
              'NextStepLearning has been recorded. It will be confirmed shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final channel = widget.channel;
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(12));

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
            Text('Pay via ${channel.name}', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.s16),

            // NextStepLearning destination account
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pay to NextStepLearning',
                      style: theme.textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.s8),
                  _detailRow(theme, channel.destinationLabel,
                      channel.destinationHolder),
                  const SizedBox(height: AppSpacing.s4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          channel.destinationAccount,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        tooltip: 'Copy',
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: channel.destinationAccount),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Account number copied')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s20),

            // Amount to send
            Text('Amount to send', style: theme.textTheme.labelMedium),
            const SizedBox(height: AppSpacing.s8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Amount (PKR)',
                prefixText: 'PKR ',
                border: border,
              ),
              validator: (v) {
                final amount = int.tryParse((v ?? '').trim());
                if (amount == null || amount <= 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.s20),

            // Payer's own account
            Text('Your paying account', style: theme.textTheme.labelMedium),
            const SizedBox(height: AppSpacing.s8),
            if (channel.payerIsPhone)
              PhoneNumberField(
                label: channel.payerFieldLabel,
                onChanged: (_) {},
              )
            else
              TextFormField(
                controller: _payerController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: channel.payerFieldLabel,
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
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Send Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
