import 'package:mongo_dart/mongo_dart.dart';
import '../config/database.dart';

class QuizService {
  DbCollection get _quizzes => Database.instance.collection('quizzes');
  DbCollection get _users => Database.instance.collection('users');

  /// Tutor creates an MCQ quiz for one of their students.
  Future<Map<String, dynamic>> create(
      Map<String, dynamic> data, String tutorId) async {
    final questions = ((data['questions'] as List?) ?? []).map((q) {
      final m = q as Map;
      return {
        'text': (m['text'] ?? '').toString(),
        'options': List<String>.from(m['options'] ?? const []),
        'correctIndex': (m['correctIndex'] ?? 0) as int,
      };
    }).toList();

    final doc = <String, dynamic>{
      'tutorId': ObjectId.fromHexString(tutorId),
      'studentId': ObjectId.fromHexString(data['studentId'] as String),
      'title': (data['title'] ?? 'Quiz').toString(),
      'subject': (data['subject'] ?? '').toString(),
      'questions': questions,
      'submission': null,
      'createdAt': DateTime.now(),
    };

    final res = await _quizzes.insertOne(doc);
    return {...doc, '_id': res.id};
  }

  /// Lists quizzes for the current user. Tutors see quizzes they created,
  /// students see quizzes assigned to them (with the answer key stripped until
  /// they submit).
  Future<List<Map<String, dynamic>>> listForUser(
      String userId, String role) async {
    final field = role == 'tutor' ? 'tutorId' : 'studentId';
    final docs = await _quizzes
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

      final out = <String, dynamic>{
        ...doc,
        'studentName': student?['fullName'],
        'tutorName': tutor?['fullName'],
      };

      // Hide the correct answers from students.
      if (role == 'student') {
        out['questions'] = ((doc['questions'] as List?) ?? [])
            .map((q) => {
                  'text': (q as Map)['text'],
                  'options': q['options'],
                })
            .toList();
      }
      enriched.add(out);
    }
    return enriched;
  }

  /// Student submits answers; the score is computed automatically.
  Future<Map<String, dynamic>?> submit(
      String quizId, List<dynamic> answers) async {
    final quiz =
        await _quizzes.findOne(where.eq('_id', ObjectId.fromHexString(quizId)));
    if (quiz == null) return null;

    final questions = (quiz['questions'] as List?) ?? [];
    int score = 0;
    for (var i = 0; i < questions.length; i++) {
      final correct = (questions[i] as Map)['correctIndex'];
      if (i < answers.length && answers[i] == correct) score++;
    }

    final submission = {
      'answers': answers,
      'score': score,
      'total': questions.length,
      'submittedAt': DateTime.now(),
    };
    await _quizzes.updateOne(
      where.eq('_id', ObjectId.fromHexString(quizId)),
      modify.set('submission', submission),
    );
    return {...quiz, 'submission': submission};
  }
}
