import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';
import '../../../data/services/notification_prefs.dart';

class StudentNotificationsScreen extends StatefulWidget {
  const StudentNotificationsScreen({super.key});

  @override
  State<StudentNotificationsScreen> createState() =>
      _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState
    extends State<StudentNotificationsScreen> {
  bool messages = true;
  bool reminders = true;
  bool updates = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final m = await NotificationPrefs.messagesEnabled();
    final r = await NotificationPrefs.remindersEnabled();
    if (mounted) {
      setState(() {
        messages = m;
        reminders = r;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.4,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [
          _toggleTile(
            context,
            "Messages",
            messages,
            (v) {
              setState(() => messages = v);
              NotificationPrefs.setMessagesEnabled(v);
            },
          ),
          _toggleTile(
            context,
            "Class Reminders",
            reminders,
            (v) {
              setState(() => reminders = v);
              NotificationPrefs.setRemindersEnabled(v);
            },
          ),
          _toggleTile(
            context,
            "App Updates",
            updates,
            (v) => setState(() => updates = v),
          ),
        ],
      ),
    );
  }

  Widget _toggleTile(
    BuildContext context,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: .15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Switch(
            value: value,
            activeThumbColor: Theme.of(context).colorScheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
