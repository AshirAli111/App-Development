import 'package:mongo_dart/mongo_dart.dart';

class LastMessage {
  final String text;
  final ObjectId senderId;
  final DateTime timestamp;

  LastMessage({
    required this.text,
    required this.senderId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'text': text,
    'senderId': senderId,
    'timestamp': timestamp,
  };

  factory LastMessage.fromMap(Map<String, dynamic> map) => LastMessage(
    text: map['text'] ?? '',
    senderId: map['senderId'] is ObjectId
        ? map['senderId']
        : ObjectId.fromHexString(map['senderId'].toString()),
    timestamp: map['timestamp'] is DateTime
        ? map['timestamp']
        : DateTime.now(),
  );
}

class ChatModel {
  final ObjectId? id;
  final List<ObjectId> participants;
  final LastMessage? lastMessage;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatModel({
    this.id,
    required this.participants,
    this.lastMessage,
    this.unreadCount = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    if (id != null) '_id': id,
    'participants': participants,
    'lastMessage': lastMessage?.toMap(),
    'unreadCount': unreadCount,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory ChatModel.fromMap(Map<String, dynamic> map) => ChatModel(
    id: map['_id'],
    participants: (map['participants'] as List)
        .map((p) => p is ObjectId ? p : ObjectId.fromHexString(p.toString()))
        .toList(),
    lastMessage: map['lastMessage'] != null
        ? LastMessage.fromMap(map['lastMessage'])
        : null,
    unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
    createdAt: map['createdAt'] is DateTime ? map['createdAt'] : DateTime.now(),
    updatedAt: map['updatedAt'] is DateTime ? map['updatedAt'] : DateTime.now(),
  );
}

class SessionRequest {
  final String subject;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final int pricePerSessionPKR;
  final String status; // pending, accepted, rejected

  SessionRequest({
    required this.subject,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.pricePerSessionPKR,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() => {
    'subject': subject,
    'dayOfWeek': dayOfWeek,
    'startTime': startTime,
    'endTime': endTime,
    'pricePerSessionPKR': pricePerSessionPKR,
    'status': status,
  };

  factory SessionRequest.fromMap(Map<String, dynamic> map) => SessionRequest(
    subject: map['subject'],
    dayOfWeek: map['dayOfWeek'],
    startTime: map['startTime'],
    endTime: map['endTime'],
    pricePerSessionPKR: map['pricePerSessionPKR'],
    status: map['status'] ?? 'pending',
  );
}

class MessageModel {
  final ObjectId? id;
  final ObjectId chatId;
  final ObjectId senderId;
  final String text;
  final String type; // text, session_request, session_response
  final SessionRequest? sessionRequest;
  final String status; // sent, delivered, seen
  final DateTime createdAt;

  MessageModel({
    this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    this.type = 'text',
    this.sessionRequest,
    this.status = 'sent',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    if (id != null) '_id': id,
    'chatId': chatId,
    'senderId': senderId,
    'text': text,
    'type': type,
    'sessionRequest': sessionRequest?.toMap(),
    'status': status,
    'createdAt': createdAt,
  };

  factory MessageModel.fromMap(Map<String, dynamic> map) => MessageModel(
    id: map['_id'],
    chatId: map['chatId'] is ObjectId
        ? map['chatId']
        : ObjectId.fromHexString(map['chatId'].toString()),
    senderId: map['senderId'] is ObjectId
        ? map['senderId']
        : ObjectId.fromHexString(map['senderId'].toString()),
    text: map['text'] ?? '',
    type: map['type'] ?? 'text',
    sessionRequest: map['sessionRequest'] != null
        ? SessionRequest.fromMap(map['sessionRequest'])
        : null,
    status: map['status'] ?? 'sent',
    createdAt: map['createdAt'] is DateTime ? map['createdAt'] : DateTime.now(),
  );
}
