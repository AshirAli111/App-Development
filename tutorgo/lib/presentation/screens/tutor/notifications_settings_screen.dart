import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:next_step_learning/core/theme/spacing.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  // Toggles
  bool messages = true;
  bool calls = true;
  bool schedule = true;
  bool reminders = true;
  bool promotions = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text("Notifications", style: theme.textTheme.titleLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s20,
          vertical: AppSpacing.s20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, "General Alerts"),
            _toggleTile(
              context: context,
              title: "Messages",
              subtitle: "Receive notifications for new messages",
              icon: LucideIcons.messageCircle,
              value: messages,
              onChanged: (v) => setState(() => messages = v),
            ),
            _toggleTile(
              context: context,
              title: "Calls",
              subtitle: "Get alerts for incoming voice/video calls",
              icon: LucideIcons.phoneCall,
              value: calls,
              onChanged: (v) => setState(() => calls = v),
            ),

            const SizedBox(height: AppSpacing.s24),

            _sectionTitle(context, "Schedule"),
            _toggleTile(
              context: context,
              title: "Class Reminders",
              subtitle: "Reminders before your session starts",
              icon: LucideIcons.calendar,
              value: schedule,
              onChanged: (v) => setState(() => schedule = v),
            ),
            _toggleTile(
              context: context,
              title: "Daily Summary",
              subtitle: "Summary of today & tomorrow's sessions",
              icon: LucideIcons.clock,
              value: reminders,
              onChanged: (v) => setState(() => reminders = v),
            ),

            const SizedBox(height: AppSpacing.s24),

            _sectionTitle(context, "Other"),
            _toggleTile(
              context: context,
              title: "Promotions",
              subtitle: "Offers, discounts & app news",
              icon: LucideIcons.badgePercent,
              value: promotions,
              onChanged: (v) => setState(() => promotions = v),
            ),

            const SizedBox(height: AppSpacing.s40),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // 📌 Section Title
  // ---------------------------------------------------------
  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  // ---------------------------------------------------------
  // 🔘 Toggle Tile
  // ---------------------------------------------------------
  Widget _toggleTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      padding: const EdgeInsets.all(AppSpacing.s16),
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
          Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primary, size: 24),
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

          Switch(value: value, onChanged: onChanged, activeThumbColor: primary),
        ],
      ),
    );
  }
}
