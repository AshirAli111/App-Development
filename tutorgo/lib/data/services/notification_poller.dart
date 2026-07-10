import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../core/utils/app_globals.dart';
import '../../presentation/screens/student/student_chats_conversation_screen.dart';
import '../../presentation/screens/tutor/tutor_chat_conversation_screen.dart';
import 'chat_service.dart';
import 'notification_service.dart';
import 'notification_prefs.dart';
import 'local_notification_service.dart';

/// Polls the backend while the app runs and raises OS notifications (+ in-app
/// banners) for new chat messages and class-reminder records. De-dupes so the
/// same message/reminder never notifies twice, and primes a baseline on start
/// so existing items don't fire on launch.
class NotificationPoller {
  NotificationPoller._();
  static final NotificationPoller instance = NotificationPoller._();

  Timer? _timer;
  String? _baseUrl;
  String? _token;
  String? _userId;
  String _role = 'student';
  bool _primed = false;

  /// Chat currently open on screen — message notifications for it are suppressed.
  static String? activeChatId;

  final Set<String> _seenReminderIds = {};
  final Map<String, String> _lastMsgTs = {};
  final Map<String, Map<String, dynamic>> _chatInfo = {}; // chatId -> {name,image}

  void start({
    required String baseUrl,
    required String token,
    required String userId,
    required String role,
  }) {
    if (token.isEmpty || userId.isEmpty) return;
    // Already running for this user.
    if (_timer != null && _userId == userId && _baseUrl == baseUrl) return;
    stop();
    _baseUrl = baseUrl;
    _token = token;
    _userId = userId;
    _role = role;
    _primed = false;
    _seenReminderIds.clear();
    _lastMsgTs.clear();
    _chatInfo.clear();
    // Route OS-notification taps (mobile) to the chat as well.
    LocalNotificationService.instance.onChatTap = openChat;
    _timer = Timer.periodic(const Duration(seconds: 8), (_) => _tick());
    _tick(); // baseline immediately
  }

  /// Opens the conversation for [chatId] using the navigator key.
  void openChat(String chatId) {
    final nav = navigatorKey.currentState;
    final baseUrl = _baseUrl;
    final token = _token;
    final userId = _userId;
    if (nav == null || baseUrl == null || token == null || userId == null) {
      return;
    }
    final info = _chatInfo[chatId] ?? const {};
    final name = (info['name'] ?? 'Chat').toString();
    final image = info['image'] as String?;

    nav.push(MaterialPageRoute(
      builder: (_) => _role == 'tutor'
          ? TutorChatConversation(
              name: name,
              imageUrl: image,
              chatId: chatId,
              baseUrl: baseUrl,
              token: token,
              userId: userId,
            )
          : StudentChatConversation(
              name: name,
              imageUrl: image,
              chatId: chatId,
              baseUrl: baseUrl,
              token: token,
              userId: userId,
            ),
    ));
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _userId = null;
    _baseUrl = null;
    _token = null;
  }

  Future<void> _tick() async {
    final baseUrl = _baseUrl;
    final token = _token;
    final userId = _userId;
    if (baseUrl == null || token == null || userId == null) return;

    final notifService =
        NotificationService(baseUrl: baseUrl, token: token, userId: userId);
    final chatService =
        ChatService(baseUrl: baseUrl, token: token, userId: userId);

    // ---- Class reminders ----
    try {
      final notifs = await notifService.getNotifications();
      for (final n in notifs) {
        final id = (n['_id'] ?? '').toString();
        final type = (n['type'] ?? '').toString();
        if (id.isEmpty || type != 'session_reminder') continue;
        if (!_seenReminderIds.add(id)) continue; // already seen
        if (_primed) {
          final title = (n['title'] ?? 'Class Reminder').toString();
          final body = (n['body'] ?? '').toString();
          await LocalNotificationService.instance.showReminder(title, body);
          // In-app banner too (guaranteed on desktop) — respect the toggle.
          if (await NotificationPrefs.remindersEnabled()) {
            showInAppBanner(title, body, icon: LucideIcons.bell);
          }
        }
      }
    } catch (_) {
      // ignore transient errors
    }

    // ---- New chat messages ----
    try {
      final chats = await chatService.getChats();
      for (final chat in chats) {
        final chatId = (chat['_id'] ?? '').toString();
        final last = chat['lastMessage'] as Map<String, dynamic>?;
        if (chatId.isEmpty) continue;

        final otherUser = chat['otherUser'] as Map<String, dynamic>?;
        final name = (otherUser?['name'] ?? 'New message').toString();
        // Cache so a notification tap can open the right conversation.
        _chatInfo[chatId] = {'name': name, 'image': otherUser?['profileImage']};

        if (last == null) continue;
        final ts = (last['timestamp'] ?? '').toString();
        final senderId = (last['senderId'] ?? '').toString();
        final prev = _lastMsgTs[chatId];
        _lastMsgTs[chatId] = ts;

        if (!_primed) continue; // baseline pass
        if (ts.isEmpty || ts == prev) continue; // nothing new
        if (senderId == userId) continue; // my own message
        if (chatId == activeChatId) continue; // already viewing this chat

        if (!await NotificationPrefs.messagesEnabled()) continue;
        final text = (last['text'] ?? '').toString();
        await LocalNotificationService.instance
            .showMessage(name, text, payload: chatId);
        showInAppBanner(name, text, onTap: () => openChat(chatId));
      }
    } catch (_) {
      // ignore transient errors
    }

    _primed = true;
  }
}
