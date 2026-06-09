import 'package:mongo_dart/mongo_dart.dart';

class PaymentModel {
  final ObjectId? id;
  final ObjectId studentId;
  final ObjectId tutorId;
  final ObjectId? sessionInstanceId;
  final int amountPKR;
  final String status; // pending, completed, refunded
  final String method; // cash, bank_transfer, easypaisa, jazzcash, stripe
  final DateTime transactionDate;
  final DateTime createdAt;

  PaymentModel({
    this.id,
    required this.studentId,
    required this.tutorId,
    this.sessionInstanceId,
    required this.amountPKR,
    this.status = 'pending',
    required this.method,
    DateTime? transactionDate,
    DateTime? createdAt,
  })  : transactionDate = transactionDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    if (id != null) '_id': id,
    'studentId': studentId,
    'tutorId': tutorId,
    'sessionInstanceId': sessionInstanceId,
    'amountPKR': amountPKR,
    'status': status,
    'method': method,
    'transactionDate': transactionDate,
    'createdAt': createdAt,
  };

  factory PaymentModel.fromMap(Map<String, dynamic> map) => PaymentModel(
    id: map['_id'],
    studentId: map['studentId'] is ObjectId
        ? map['studentId']
        : ObjectId.fromHexString(map['studentId'].toString()),
    tutorId: map['tutorId'] is ObjectId
        ? map['tutorId']
        : ObjectId.fromHexString(map['tutorId'].toString()),
    sessionInstanceId: map['sessionInstanceId'] is ObjectId
        ? map['sessionInstanceId']
        : (map['sessionInstanceId'] != null
            ? ObjectId.fromHexString(map['sessionInstanceId'].toString())
            : null),
    amountPKR: map['amountPKR'] ?? 0,
    status: map['status'] ?? 'pending',
    method: map['method'] ?? 'cash',
    transactionDate: map['transactionDate'] is DateTime
        ? map['transactionDate']
        : DateTime.now(),
    createdAt: map['createdAt'] is DateTime ? map['createdAt'] : DateTime.now(),
  );
}
