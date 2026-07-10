import 'package:mongo_dart/mongo_dart.dart';

class NotificationModel {
  final ObjectId? id;
  final ObjectId userId;
  final String title;
  final String body;
  final String type; // session_reminder, message, session_request, payment, system
  final ObjectId? referenceId;
  final bool isRead;
  final DateTime scheduledFor;
  final DateTime createdAt;

  NotificationModel({
    this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    this.isRead = false,
    required this.scheduledFor,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    if (id != null) '_id': id,
    'userId': userId,
    'title': title,
    'body': body,
    'type': type,
    'referenceId': referenceId,
    'isRead': isRead,
    'scheduledFor': scheduledFor,
    'createdAt': createdAt,
  };

  factory NotificationModel.fromMap(Map<String, dynamic> map) =>
      NotificationModel(
        id: map['_id'],
        userId: map['userId'] is ObjectId
            ? map['userId']
            : ObjectId.fromHexString(map['userId'].toString()),
        title: map['title'] ?? '',
        body: map['body'] ?? '',
        type: map['type'] ?? 'system',
        referenceId: map['referenceId'],
        isRead: map['isRead'] ?? false,
        scheduledFor: map['scheduledFor'] is DateTime
            ? map['scheduledFor']
            : DateTime.now(),
        createdAt:
            map['createdAt'] is DateTime ? map['createdAt'] : DateTime.now(),
      );
}
