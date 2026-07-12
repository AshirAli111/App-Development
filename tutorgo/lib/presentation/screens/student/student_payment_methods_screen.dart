import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';
import '../payment/send_payment_screen.dart';

class StudentPaymentMethodsScreen extends StatelessWidget {
  const StudentPaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final methods = [
      {
        "id": "card",
        "name": "Pay with Card",
        "icon": Icons.credit_card,
        "color": const Color(0xFF635BFF),
      },
      {
        "id": "easypaisa",
        "name": "Easypaisa",
        "icon": Icons.phone_android,
        "color": const Color(0xFF4CAF50),
      },
      {
        "id": "jazzcash",
        "name": "JazzCash",
        "icon": Icons.phone_android,
        "color": const Color(0xFFE91E63),
      },
      {
        "id": "bank_transfer",
        "name": "Bank Transfer",
        "icon": Icons.account_balance,
        "color": const Color(0xFF2196F3),
      },
    ];

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
        itemCount: methods.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final method = methods[i];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SendPaymentScreen(method: method['id'] as String),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).shadowColor.withValues(alpha: .15),
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
