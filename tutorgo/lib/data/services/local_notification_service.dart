import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_prefs.dart';

/// Thin wrapper around flutter_local_notifications that shows OS notifications
/// (Windows toast / Android drawer / etc.) while the app is running.
/// Each show is gated by the matching device-local toggle in [NotificationPrefs].
class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  int _id = 0;

  /// Called with the chat id when the user taps a message OS notification.
  void Function(String chatId)? onChatTap;

  Future<void> init() async {
    if (_initialized) return;
    // flutter_local_notifications has no Windows/web implementation here; on
    // those platforms we rely on the in-app banner instead of OS notifications.
    if (kIsWeb || Platform.isWindows) return;
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings();
      const linux =
          LinuxInitializationSettings(defaultActionName: 'Open');

      const settings = InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
        linux: linux,
      );

      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            onChatTap?.call(payload);
          }
        },
      );

      // Android 13+ runtime permission.
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _initialized = true;
    } catch (e) {
      // Never let notification setup crash the app (e.g. unsupported platform).
      debugPrint('LocalNotificationService init failed: $e');
    }
  }

  Future<void> showMessage(String title, String body,
      {String? payload}) async {
    if (!await NotificationPrefs.messagesEnabled()) return;
    await _show(title, body,
        channelId: 'messages', channelName: 'Messages', payload: payload);
  }

  Future<void> showReminder(String title, String body) async {
    if (!await NotificationPrefs.remindersEnabled()) return;
    await _show(title, body,
        channelId: 'reminders', channelName: 'Class Reminders');
  }

  Future<void> _show(
    String title,
    String body, {
    required String channelId,
    required String channelName,
    String? payload,
  }) async {
    if (!_initialized) return;
    try {
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
        linux: const LinuxNotificationDetails(),
      );
      await _plugin.show(_id++, title, body, details, payload: payload);
    } catch (e) {
      debugPrint('LocalNotificationService show failed: $e');
    }
  }
}
