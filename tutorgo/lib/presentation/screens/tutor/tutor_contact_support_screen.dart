import 'package:flutter/material.dart';

import 'package:next_step_learning/core/theme/spacing.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final TextEditingController messageCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text("Contact Support", style: theme.textTheme.titleLarge),
      ),

      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Describe your issue", style: theme.textTheme.titleMedium),

            const SizedBox(height: AppSpacing.s16),

            TextField(
              controller: messageCtrl,
              maxLines: 8,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: "Write your message here...",
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.s24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Send Message",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
