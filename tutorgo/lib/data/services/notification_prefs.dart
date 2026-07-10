import 'package:shared_preferences/shared_preferences.dart';

/// Device-local on/off preferences for notifications (not synced to the account).
class NotificationPrefs {
  static const _kMessages = 'notif_messages_enabled';
  static const _kReminders = 'notif_reminders_enabled';

  static Future<bool> messagesEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kMessages) ?? true;
  }

  static Future<void> setMessagesEnabled(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kMessages, value);
  }

  static Future<bool> remindersEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kReminders) ?? true;
  }

  static Future<void> setRemindersEnabled(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kReminders, value);
  }
}
