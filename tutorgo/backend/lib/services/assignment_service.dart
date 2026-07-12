import 'package:mongo_dart/mongo_dart.dart';
import '../config/database.dart';

class AssignmentService {
  DbCollection get _assignments => Database.instance.collection('assignments');
  DbCollection get _users => Database.instance.collection('users');

  /// Tutor creates an assignment for a student.
  Future<Map<String, dynamic>> create(
      Map<String, dynamic> data, String tutorId) async {
    final doc = <String, dynamic>{
      'tutorId': ObjectId.fromHexString(tutorId),
      'studentId': ObjectId.fromHexString(data['studentId'] as String),
      'title': (data['title'] ?? 'Assignment').toString(),
      'subject': (data['subject'] ?? '').toString(),
      'description': (data['description'] ?? '').toString(),
      'submission': null,
      'marks': null,
      'feedback': null,
      'gradedAt': null,
      'createdAt': DateTime.now(),
    };
    final res = await _assignments.insertOne(doc);
    return {...doc, '_id': res.id};
  }

  Future<List<Map<String, dynamic>>> listForUser(
      String userId, String role) async {
    final field = role == 'tutor' ? 'tutorId' : 'studentId';
    final docs = await _assignments
        .find(where
            .eq(field, ObjectId.fromHexString(userId))
            .sortBy('createdAt', descending: true))
        .toList();

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
        'tutorName': tutor?['fullName'],
      });
    }
    return enriched;
  }

  /// Student uploads a file submission (base64).
  Future<Map<String, dynamic>?> submit(
      String id, Map<String, dynamic> data) async {
    final assignment =
        await _assignments.findOne(where.eq('_id', ObjectId.fromHexString(id)));
    if (assignment == null) return null;

    final submission = {
      'fileBase64': data['fileBase64'],
      'fileName': (data['fileName'] ?? 'submission').toString(),
      'submittedAt': DateTime.now(),
    };
    await _assignments.updateOne(
      where.eq('_id', ObjectId.fromHexString(id)),
      modify.set('submission', submission),
    );
    return {...assignment, 'submission': submission};
  }

  /// Tutor grades the submission (marks + feedback).
  Future<Map<String, dynamic>?> grade(
      String id, Map<String, dynamic> data) async {
    final assignment =
        await _assignments.findOne(where.eq('_id', ObjectId.fromHexString(id)));
    if (assignment == null) return null;

    await _assignments.updateOne(
      where.eq('_id', ObjectId.fromHexString(id)),
      modify
          .set('marks', data['marks'])
          .set('feedback', (data['feedback'] ?? '').toString())
          .set('gradedAt', DateTime.now()),
    );
    return await _assignments
        .findOne(where.eq('_id', ObjectId.fromHexString(id)));
  }
}
