import 'dart:math';
import 'package:mongo_dart/mongo_dart.dart';
import '../config/database.dart';

class StripeService {
  DbCollection get _stripeSessions =>
      Database.instance.collection('stripe_sessions');
  DbCollection get _payments => Database.instance.collection('payments');

  String _generateSessionId() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return 'cs_mock_$hex';
  }

  Future<Map<String, dynamic>> createCheckoutSession({
    required String studentId,
    required String tutorId,
    required int amountPKR,
    String? sessionInstanceId,
  }) async {
    final sessionId = _generateSessionId();
    final now = DateTime.now();

    // Create payment record with stripe method
    final paymentDoc = {
      'studentId': ObjectId.fromHexString(studentId),
      'tutorId': ObjectId.fromHexString(tutorId),
      'sessionInstanceId': sessionInstanceId != null
          ? ObjectId.fromHexString(sessionInstanceId)
          : null,
      'amountPKR': amountPKR,
      'status': 'pending',
      'method': 'stripe',
      'stripeSessionId': sessionId,
      'transactionDate': now,
      'createdAt': now,
    };

    final paymentResult = await _payments.insertOne(paymentDoc);

    // Create stripe session
    final stripeSession = {
      'sessionId': sessionId,
      'paymentId': paymentResult.id,
      'studentId': ObjectId.fromHexString(studentId),
      'tutorId': ObjectId.fromHexString(tutorId),
      'amountPKR': amountPKR,
      'status': 'pending',
      'createdAt': now,
      'completedAt': null,
    };

    await _stripeSessions.insertOne(stripeSession);

    return {
      'sessionId': sessionId,
      'amountPKR': amountPKR,
      'status': 'pending',
    };
  }

  Future<Map<String, dynamic>?> getSession(String sessionId) async {
    return await _stripeSessions.findOne(where.eq('sessionId', sessionId));
  }

  Future<Map<String, dynamic>?> confirmSession(String sessionId) async {
    final session =
        await _stripeSessions.findOne(where.eq('sessionId', sessionId));
    if (session == null) return null;

    if (session['status'] == 'completed') {
      return session;
    }

    final now = DateTime.now();

    // Update stripe session
    await _stripeSessions.updateOne(
      where.eq('sessionId', sessionId),
      modify.set('status', 'completed').set('completedAt', now),
    );

    // Update payment status
    await _payments.updateOne(
      where.eq('_id', session['paymentId']),
      modify.set('status', 'completed'),
    );

    return {
      ...session,
      'status': 'completed',
      'completedAt': now,
    };
  }
}
