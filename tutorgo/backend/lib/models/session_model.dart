import 'package:mongo_dart/mongo_dart.dart';

class Recurrence {
  final int dayOfWeek; // 1=Mon, 7=Sun
  final String startTime; // HH:mm
  final String endTime; // HH:mm
  final DateTime startDate;
  final DateTime? endDate;

  Recurrence({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toMap() => {
    'dayOfWeek': dayOfWeek,
    'startTime': startTime,
    'endTime': endTime,
    'startDate': startDate,
    'endDate': endDate,
  };

  factory Recurrence.fromMap(Map<String, dynamic> map) => Recurrence(
    dayOfWeek: map['dayOfWeek'],
    startTime: map['startTime'],
    endTime: map['endTime'],
    startDate: map['startDate'] is DateTime
        ? map['startDate']
        : DateTime.parse(map['startDate'].toString()),
    endDate: map['endDate'] != null
        ? (map['endDate'] is DateTime
            ? map['endDate']
            : DateTime.parse(map['endDate'].toString()))
        : null,
  );
}

class SessionModel {
  final ObjectId? id;
  final ObjectId studentId;
  final ObjectId tutorId;
  final String subject;
  final Recurrence recurrence;
  final String status; // active, paused, cancelled, completed
  final int pricePerSessionPKR;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  SessionModel({
    this.id,
    required this.studentId,
    required this.tutorId,
    required this.subject,
    required this.recurrence,
    this.status = 'active',
    required this.pricePerSessionPKR,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    if (id != null) '_id': id,
    'studentId': studentId,
    'tutorId': tutorId,
    'subject': subject,
    'recurrence': recurrence.toMap(),
    'status': status,
    'pricePerSessionPKR': pricePerSessionPKR,
    'notes': notes,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory SessionModel.fromMap(Map<String, dynamic> map) => SessionModel(
    id: map['_id'],
    studentId: map['studentId'] is ObjectId
        ? map['studentId']
        : ObjectId.fromHexString(map['studentId'].toString()),
    tutorId: map['tutorId'] is ObjectId
        ? map['tutorId']
        : ObjectId.fromHexString(map['tutorId'].toString()),
    subject: map['subject'],
    recurrence: Recurrence.fromMap(map['recurrence']),
    status: map['status'] ?? 'active',
    pricePerSessionPKR: map['pricePerSessionPKR'],
    notes: map['notes'],
    createdAt: map['createdAt'] is DateTime ? map['createdAt'] : DateTime.now(),
    updatedAt: map['updatedAt'] is DateTime ? map['updatedAt'] : DateTime.now(),
  );
}

class SessionInstanceModel {
  final ObjectId? id;
  final ObjectId sessionId;
  final ObjectId studentId;
  final ObjectId tutorId;
  final DateTime scheduledDate;
  final String startTime;
  final String endTime;
  final String status; // scheduled, completed, cancelled, missed
  final int? rating;
  final String? feedback;
  final DateTime createdAt;

  SessionInstanceModel({
    this.id,
    required this.sessionId,
    required this.studentId,
    required this.tutorId,
    required this.scheduledDate,
    required this.startTime,
    required this.endTime,
    this.status = 'scheduled',
    this.rating,
    this.feedback,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    if (id != null) '_id': id,
    'sessionId': sessionId,
    'studentId': studentId,
    'tutorId': tutorId,
    'scheduledDate': scheduledDate,
    'startTime': startTime,
    'endTime': endTime,
    'status': status,
    'rating': rating,
    'feedback': feedback,
    'createdAt': createdAt,
  };

  factory SessionInstanceModel.fromMap(Map<String, dynamic> map) =>
      SessionInstanceModel(
        id: map['_id'],
        sessionId: map['sessionId'] is ObjectId
            ? map['sessionId']
            : ObjectId.fromHexString(map['sessionId'].toString()),
        studentId: map['studentId'] is ObjectId
            ? map['studentId']
            : ObjectId.fromHexString(map['studentId'].toString()),
        tutorId: map['tutorId'] is ObjectId
            ? map['tutorId']
            : ObjectId.fromHexString(map['tutorId'].toString()),
        scheduledDate: map['scheduledDate'] is DateTime
            ? map['scheduledDate']
            : DateTime.parse(map['scheduledDate'].toString()),
        startTime: map['startTime'],
        endTime: map['endTime'],
        status: map['status'] ?? 'scheduled',
        rating: map['rating'],
        feedback: map['feedback'],
        createdAt:
            map['createdAt'] is DateTime ? map['createdAt'] : DateTime.now(),
      );
}
