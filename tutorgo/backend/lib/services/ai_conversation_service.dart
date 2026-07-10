import 'package:mongo_dart/mongo_dart.dart';
import '../config/database.dart';
import '../models/ai_conversation_model.dart';

class AiConversationService {
  DbCollection get _conversations =>
      Database.instance.collection('ai_conversations');

  Future<List<Map<String, dynamic>>> getUserConversations(
    String userId,
  ) async {
    return await _conversations
        .find(where
            .eq('userId', ObjectId.fromHexString(userId))
            .sortBy('updatedAt', descending: true))
        .toList();
  }

  Future<Map<String, dynamic>> createConversation({
    required String userId,
    required String role,
    required String firstMessage,
  }) async {
    final title = firstMessage.length > 50
        ? '${firstMessage.substring(0, 50)}...'
        : firstMessage;

    final conversation = AiConversationModel(
      userId: ObjectId.fromHexString(userId),
      role: role,
      title: title,
      messages: [
        AiMessage(text: firstMessage, isUser: true),
      ],
    );

    final result = await _conversations.insertOne(conversation.toMap());
    return {...conversation.toMap(), '_id': result.id};
  }

  Future<Map<String, dynamic>?> addMessage({
    required String conversationId,
    required String text,
    required bool isUser,
  }) async {
    final message = AiMessage(text: text, isUser: isUser);

    await _conversations.updateOne(
      where.eq('_id', ObjectId.fromHexString(conversationId)),
      modify
          .push('messages', message.toMap())
          .set('updatedAt', DateTime.now()),
    );

    return await _conversations.findOne(
      where.eq('_id', ObjectId.fromHexString(conversationId)),
    );
  }

  Future<Map<String, dynamic>?> getConversation(
    String conversationId,
  ) async {
    return await _conversations.findOne(
      where.eq('_id', ObjectId.fromHexString(conversationId)),
    );
  }

  Future<void> deleteConversation(String conversationId) async {
    await _conversations.deleteOne(
      where.eq('_id', ObjectId.fromHexString(conversationId)),
    );
  }
}
