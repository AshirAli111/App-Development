import 'package:mongo_dart/mongo_dart.dart';
import '../config/database.dart';
import '../models/payment_model.dart';

class PaymentService {
  DbCollection get _payments => Database.instance.collection('payments');

  Future<Map<String, dynamic>> createPayment({
    required String studentId,
    required String tutorId,
    String? sessionInstanceId,
    required int amountPKR,
    required String method,
  }) async {
    final payment = PaymentModel(
      studentId: ObjectId.fromHexString(studentId),
      tutorId: ObjectId.fromHexString(tutorId),
      sessionInstanceId: sessionInstanceId != null
          ? ObjectId.fromHexString(sessionInstanceId)
          : null,
      amountPKR: amountPKR,
      method: method,
    );

    final result = await _payments.insertOne(payment.toMap());
    return {...payment.toMap(), '_id': result.id};
  }

  Future<List<Map<String, dynamic>>> getPaymentsByUser(
    String userId,
    String role, {
    int page = 1,
    int limit = 20,
  }) async {
    final field = role == 'tutor' ? 'tutorId' : 'studentId';
    final skip = (page - 1) * limit;

    return await _payments
        .find(where
            .eq(field, ObjectId.fromHexString(userId))
            .sortBy('createdAt', descending: true)
            .skip(skip)
            .limit(limit))
        .toList();
  }

  Future<void> updatePaymentStatus(
    String paymentId,
    String status,
  ) async {
    final validStatuses = ['pending', 'completed', 'refunded'];
    if (!validStatuses.contains(status)) {
      throw Exception('Invalid payment status: $status');
    }

    await _payments.updateOne(
      where.eq('_id', ObjectId.fromHexString(paymentId)),
      modify.set('status', status),
    );
  }

  Future<Map<String, dynamic>> getPaymentSummary(
    String userId,
    String role,
  ) async {
    final field = role == 'tutor' ? 'tutorId' : 'studentId';
    final payments = await _payments
        .find(where.eq(field, ObjectId.fromHexString(userId)))
        .toList();

    int totalPKR = 0;
    int pendingPKR = 0;
    int completedPKR = 0;

    for (final p in payments) {
      final amount = p['amountPKR'] as int;
      totalPKR += amount;
      if (p['status'] == 'pending') pendingPKR += amount;
      if (p['status'] == 'completed') completedPKR += amount;
    }

    return {
      'totalPKR': totalPKR,
      'pendingPKR': pendingPKR,
      'completedPKR': completedPKR,
      'totalTransactions': payments.length,
    };
  }
}
