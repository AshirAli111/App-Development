import 'package:mongo_dart/mongo_dart.dart';

class AiMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  AiMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp,
  };

  factory AiMessage.fromMap(Map<String, dynamic> map) => AiMessage(
    text: map['text'] ?? '',
    isUser: map['isUser'] ?? true,
    timestamp: map['timestamp'] is DateTime
        ? map['timestamp']
        : DateTime.now(),
  );
}

class AiConversationModel {
  final ObjectId? id;
  final ObjectId userId;
  final String role; // student or tutor
  final String title;
  final List<AiMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  AiConversationModel({
    this.id,
    required this.userId,
    required this.role,
    required this.title,
    this.messages = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    if (id != null) '_id': id,
    'userId': userId,
    'role': role,
    'title': title,
    'messages': messages.map((m) => m.toMap()).toList(),
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory AiConversationModel.fromMap(Map<String, dynamic> map) =>
      AiConversationModel(
        id: map['_id'],
        userId: map['userId'] is ObjectId
            ? map['userId']
            : ObjectId.fromHexString(map['userId'].toString()),
        role: map['role'] ?? 'student',
        title: map['title'] ?? 'New Conversation',
        messages: (map['messages'] as List?)
                ?.map((m) => AiMessage.fromMap(m))
                .toList() ??
            [],
        createdAt:
            map['createdAt'] is DateTime ? map['createdAt'] : DateTime.now(),
        updatedAt:
            map['updatedAt'] is DateTime ? map['updatedAt'] : DateTime.now(),
      );
}
