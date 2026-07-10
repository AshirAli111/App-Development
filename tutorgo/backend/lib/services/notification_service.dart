import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';
import '../config/database.dart';
import '../models/notification_model.dart';

class NotificationService {
  DbCollection get _notifications =>
      Database.instance.collection('notifications');
  DbCollection get _instances =>
      Database.instance.collection('session_instances');

  Timer? _schedulerTimer;

  Future<List<Map<String, dynamic>>> getUserNotifications(
    String userId, {
    bool unreadOnly = false,
    int page = 1,
    int limit = 20,
  }) async {
    var query = where.eq('userId', ObjectId.fromHexString(userId));

    if (unreadOnly) {
      query = query.eq('isRead', false);
    }

    // Only return notifications that are scheduled for now or earlier
    query = query.lte('scheduledFor', DateTime.now());

    final skip = (page - 1) * limit;
    return await _notifications
        .find(query.sortBy('createdAt', descending: true).skip(skip).limit(limit))
        .toList();
  }

  Future<Map<String, dynamic>> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? referenceId,
    DateTime? scheduledFor,
  }) async {
    final notification = NotificationModel(
      userId: ObjectId.fromHexString(userId),
      title: title,
      body: body,
      type: type,
      referenceId: referenceId != null
          ? ObjectId.fromHexString(referenceId)
          : null,
      scheduledFor: scheduledFor ?? DateTime.now(),
    );

    final result = await _notifications.insertOne(notification.toMap());
    return {...notification.toMap(), '_id': result.id};
  }

  Future<void> markAsRead(String notificationId) async {
    await _notifications.updateOne(
      where.eq('_id', ObjectId.fromHexString(notificationId)),
      modify.set('isRead', true),
    );
  }

  Future<void> markAllAsRead(String userId) async {
    await _notifications.updateMany(
      where
          .eq('userId', ObjectId.fromHexString(userId))
          .eq('isRead', false),
      modify.set('isRead', true),
    );
  }

  /// Starts the notification scheduler that creates session reminders.
  /// The callback is fully guarded: a transient DB error (e.g. Atlas idle
  /// disconnect) must never bubble out of the Timer and crash the server.
  void startScheduler() {
    _schedulerTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) async {
        try {
          await Database.ensureConnected();
          await _processScheduledReminders();
        } catch (e) {
          print('Notification scheduler tick skipped: $e');
        }
      },
    );
    print('Notification scheduler started (runs every 1 minute)');
  }

  void stopScheduler() {
    _schedulerTimer?.cancel();
    _schedulerTimer = null;
  }

  /// Creates reminder notifications 30 minutes before sessions
  Future<void> _processScheduledReminders() async {
    final now = DateTime.now();
    final reminderWindow = now.add(const Duration(minutes: 30));

    // Find sessions happening in the next 30 minutes that don't have reminders yet
    final upcomingSessions = await _instances
        .find(where
            .eq('status', 'scheduled')
            .gte('scheduledDate', DateTime(now.year, now.month, now.day))
            .lte('scheduledDate', DateTime(now.year, now.month, now.day, 23, 59)))
        .toList();

    for (final session in upcomingSessions) {
      final scheduledDate = session['scheduledDate'] as DateTime;
      final startTime = session['startTime'] as String;
      final parts = startTime.split(':');
      final sessionTime = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      // Check if session is within 30 minutes from now
      if (sessionTime.isAfter(now) && sessionTime.isBefore(reminderWindow)) {
        final studentId = (session['studentId'] as ObjectId).oid;
        final tutorId = (session['tutorId'] as ObjectId).oid;

        // Check if reminder already exists
        final existingReminder = await _notifications.findOne(where
            .eq('referenceId', session['_id'])
            .eq('type', 'session_reminder'));

        if (existingReminder == null) {
          // Create reminders for both student and tutor
          await createNotification(
            userId: studentId,
            title: 'Session Reminder',
            body: 'Your session starts at $startTime',
            type: 'session_reminder',
            referenceId: (session['_id'] as ObjectId).oid,
            scheduledFor: now,
          );

          await createNotification(
            userId: tutorId,
            title: 'Session Reminder',
            body: 'Your session starts at $startTime',
            type: 'session_reminder',
            referenceId: (session['_id'] as ObjectId).oid,
            scheduledFor: now,
          );
        }
      }
    }
  }
}
