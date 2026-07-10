import 'package:mongo_dart/mongo_dart.dart';
import '../config/database.dart';
import '../models/session_model.dart';

class SessionService {
  DbCollection get _sessions => Database.instance.collection('sessions');
  DbCollection get _instances =>
      Database.instance.collection('session_instances');

  Future<Map<String, dynamic>> createSession(Map<String, dynamic> data) async {
    final session = SessionModel(
      studentId: ObjectId.fromHexString(data['studentId']),
      tutorId: ObjectId.fromHexString(data['tutorId']),
      subject: data['subject'],
      recurrence: Recurrence(
        dayOfWeek: data['recurrence']['dayOfWeek'],
        startTime: data['recurrence']['startTime'],
        endTime: data['recurrence']['endTime'],
        startDate: DateTime.parse(data['recurrence']['startDate']),
        endDate: data['recurrence']['endDate'] != null
            ? DateTime.parse(data['recurrence']['endDate'])
            : null,
      ),
      pricePerSessionPKR: data['pricePerSessionPKR'],
      notes: data['notes'],
    );

    final result = await _sessions.insertOne(session.toMap());

    // Generate initial session instances for the next 4 weeks
    await _generateInstances(
      sessionId: result.id as ObjectId,
      studentId: session.studentId,
      tutorId: session.tutorId,
      recurrence: session.recurrence,
      weeksAhead: 4,
    );

    return {...session.toMap(), '_id': result.id};
  }

  Future<void> _generateInstances({
    required ObjectId sessionId,
    required ObjectId studentId,
    required ObjectId tutorId,
    required Recurrence recurrence,
    required int weeksAhead,
  }) async {
    final now = DateTime.now();
    final instances = <Map<String, dynamic>>[];

    for (int week = 0; week < weeksAhead; week++) {
      // Calculate the next occurrence of the day
      final daysUntil =
          (recurrence.dayOfWeek - now.weekday + 7) % 7 + (week * 7);
      final date = now.add(Duration(days: daysUntil));
      final scheduledDate = DateTime(date.year, date.month, date.day);

      // Skip dates before the start date
      if (scheduledDate.isBefore(recurrence.startDate)) {
        continue;
      }

      // Skip dates after the end date
      if (recurrence.endDate != null &&
          scheduledDate.isAfter(recurrence.endDate!)) {
        break;
      }

      final instance = SessionInstanceModel(
        sessionId: sessionId,
        studentId: studentId,
        tutorId: tutorId,
        scheduledDate: scheduledDate,
        startTime: recurrence.startTime,
        endTime: recurrence.endTime,
      );
      instances.add(instance.toMap());
    }

    if (instances.isNotEmpty) {
      await _instances.insertAll(instances);
    }
  }

  DbCollection get _users => Database.instance.collection('users');

  Future<List<Map<String, dynamic>>> getSessionsByUser(
    String userId,
    String role,
  ) async {
    final field = role == 'tutor' ? 'tutorId' : 'studentId';
    final docs = await _sessions
        .find(where.eq(field, ObjectId.fromHexString(userId)).eq('status', 'active'))
        .toList();

    // Enrich each session with the student's and tutor's name + avatar so the
    // apps can render them (sessions only store the raw ObjectIds).
    final enriched = <Map<String, dynamic>>[];
    for (final doc in docs) {
      final student = doc['studentId'] is ObjectId
          ? await _users.findOne(where.eq('_id', doc['studentId']))
          : null;
      final tutor = doc['tutorId'] is ObjectId
          ? await _users.findOne(where.eq('_id', doc['tutorId']))
          : null;
      enriched.add({
        ...doc,
        'studentName': student?['fullName'],
        'studentImage': student?['profileImage'],
        'tutorName': tutor?['fullName'],
        'tutorImage': tutor?['profileImage'],
      });
    }
    return enriched;
  }

  Future<Map<String, dynamic>?> getSessionById(String sessionId) async {
    return await _sessions.findOne(
      where.eq('_id', ObjectId.fromHexString(sessionId)),
    );
  }

  Future<void> updateSession(
    String sessionId,
    Map<String, dynamic> updates,
  ) async {
    updates.remove('_id');
    updates['updatedAt'] = DateTime.now();

    final modifier = ModifierBuilder();
    updates.forEach((key, value) {
      modifier.set(key, value);
    });

    await _sessions.updateOne(
      where.eq('_id', ObjectId.fromHexString(sessionId)),
      modifier,
    );
  }

  Future<void> cancelSession(String sessionId) async {
    await _sessions.updateOne(
      where.eq('_id', ObjectId.fromHexString(sessionId)),
      modify
          .set('status', 'cancelled')
          .set('updatedAt', DateTime.now()),
    );

    // Cancel all future scheduled instances
    await _instances.updateMany(
      where
          .eq('sessionId', ObjectId.fromHexString(sessionId))
          .eq('status', 'scheduled')
          .gte('scheduledDate', DateTime.now()),
      modify.set('status', 'cancelled'),
    );
  }

  // Session instances
  Future<List<Map<String, dynamic>>> getInstancesBySession(
    String sessionId,
  ) async {
    return await _instances
        .find(where
            .eq('sessionId', ObjectId.fromHexString(sessionId))
            .sortBy('scheduledDate'))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getInstancesByUserAndDate(
    String userId,
    String role,
    DateTime date,
  ) async {
    final field = role == 'tutor' ? 'tutorId' : 'studentId';
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await _instances
        .find(where
            .eq(field, ObjectId.fromHexString(userId))
            .gte('scheduledDate', startOfDay)
            .lt('scheduledDate', endOfDay)
            .sortBy('startTime'))
        .toList();
  }

  Future<void> updateInstance(
    String instanceId,
    Map<String, dynamic> updates,
  ) async {
    updates.remove('_id');
    final modifier = ModifierBuilder();
    updates.forEach((key, value) {
      modifier.set(key, value);
    });

    await _instances.updateOne(
      where.eq('_id', ObjectId.fromHexString(instanceId)),
      modifier,
    );
  }
}
