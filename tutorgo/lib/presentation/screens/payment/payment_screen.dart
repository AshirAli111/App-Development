import 'package:flutter/material.dart';
import '../../../core/theme/spacing.dart';
import 'stripe_checkout_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String studentId;
  final String tutorId;
  final int amountPKR;
  final String? sessionInstanceId;
  final String baseUrl;
  final String token;

  const PaymentScreen({
    super.key,
    required this.studentId,
    required this.tutorId,
    required this.amountPKR,
    this.sessionInstanceId,
    this.baseUrl = 'http://localhost:8080',
    this.token = '',
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedMethod;

  final List<Map<String, dynamic>> _methods = [
    {
      'id': 'stripe',
      'name': 'Pay with Card (Stripe)',
      'icon': Icons.credit_card,
      'color': Color(0xFF635BFF),
    },
    {
      'id': 'easypaisa',
      'name': 'Easypaisa',
      'icon': Icons.phone_android,
      'color': Color(0xFF4CAF50),
    },
    {
      'id': 'jazzcash',
      'name': 'JazzCash',
      'icon': Icons.phone_android,
      'color': Color(0xFFE91E63),
    },
    {
      'id': 'bank_transfer',
      'name': 'Bank Transfer',
      'icon': Icons.account_balance,
      'color': Color(0xFF2196F3),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Make Payment',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).cardColor,
        elevation: .3,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount display
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(AppSpacing.s16),
            padding: const EdgeInsets.all(AppSpacing.s24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF635BFF), Color(0xFF0A2540)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Amount to Pay',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'PKR ${widget.amountPKR}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            child: Text(
              'Select Payment Method',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 12),

          // Payment methods list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              itemCount: _methods.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final method = _methods[index];
                final isSelected = _selectedMethod == method['id'];

                return GestureDetector(
                  onTap: () => setState(() => _selectedMethod = method['id']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? method['color'] as Color
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).shadowColor.withValues(alpha: .1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: (method['color'] as Color).withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            method['icon'] as IconData,
                            color: method['color'] as Color,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            method['name'] as String,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle,
                              color: method['color'] as Color),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Pay button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedMethod != null ? _processPayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF635BFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Text(
                  _selectedMethod != null
                      ? 'Pay PKR ${widget.amountPKR}'
                      : 'Select a method',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment() {
    if (_selectedMethod == 'stripe') {
      _openStripeCheckout();
    } else {
      // For other methods, show a mock success
      _showMockSuccess();
    }
  }

  Future<void> _openStripeCheckout() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => StripeCheckoutScreen(
          studentId: widget.studentId,
          tutorId: widget.tutorId,
          amountPKR: widget.amountPKR,
          sessionInstanceId: widget.sessionInstanceId,
          baseUrl: widget.baseUrl,
          token: widget.token,
        ),
      ),
    );

    if (result == true && mounted) {
      _showSuccessDialog();
    }
  }

  void _showMockSuccess() {
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 64),
            const SizedBox(height: 16),
            const Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'PKR ${widget.amountPKR} paid via $_selectedMethod',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(true);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
