import 'package:mongo_dart/mongo_dart.dart';
import '../config/database.dart';
import '../models/chat_model.dart';

class ChatService {
  DbCollection get _chats => Database.instance.collection('chats');
  DbCollection get _messages => Database.instance.collection('messages');
  DbCollection get _users => Database.instance.collection('users');

  Future<Map<String, dynamic>> getOrCreateChat(
    String userId1,
    String userId2,
  ) async {
    final oid1 = ObjectId.fromHexString(userId1);
    final oid2 = ObjectId.fromHexString(userId2);

    // Check if chat already exists between these two users
    var chat = await _chats.findOne(where.all('participants', [oid1, oid2]));

    if (chat == null) {
      final newChat = ChatModel(
        participants: [oid1, oid2],
        unreadCount: {userId1: 0, userId2: 0},
      );
      final result = await _chats.insertOne(newChat.toMap());
      chat = {...newChat.toMap(), '_id': result.id};
    }

    // Enrich with participant info
    return await _enrichChat(chat, userId1);
  }

  Future<List<Map<String, dynamic>>> getUserChats(String userId) async {
    final oid = ObjectId.fromHexString(userId);
    final chats = await _chats
        .find(where.eq('participants', oid).sortBy('updatedAt', descending: true))
        .toList();

    // Enrich each chat with the other participant's info
    final enriched = <Map<String, dynamic>>[];
    for (final chat in chats) {
      enriched.add(await _enrichChat(chat, userId));
    }
    return enriched;
  }

  /// Adds otherUser { name, profileImage } to chat document
  Future<Map<String, dynamic>> _enrichChat(
    Map<String, dynamic> chat,
    String currentUserId,
  ) async {
    final participants = (chat['participants'] as List)
        .map((p) => p is ObjectId ? p : ObjectId.fromHexString(p.toString()))
        .toList();

    final otherUserId = participants.firstWhere(
      (p) => p.oid != currentUserId,
      orElse: () => participants.first,
    );

    final otherUser = await _users.findOne(where.eq('_id', otherUserId));

    return {
      ...chat,
      'otherUser': otherUser != null
          ? {
              '_id': otherUser['_id'],
              'name': otherUser['name'] ?? 'Unknown',
              'profileImage': otherUser['profileImage'],
              'role': otherUser['role'],
            }
          : {'name': 'Unknown'},
    };
  }

  Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String type = 'text',
    Map<String, dynamic>? sessionRequest,
  }) async {
    final message = MessageModel(
      chatId: ObjectId.fromHexString(chatId),
      senderId: ObjectId.fromHexString(senderId),
      text: text,
      type: type,
      sessionRequest: sessionRequest != null
          ? SessionRequest.fromMap(sessionRequest)
          : null,
    );

    final result = await _messages.insertOne(message.toMap());

    // Update chat's last message and unread count
    final chat = await _chats.findOne(
      where.eq('_id', ObjectId.fromHexString(chatId)),
    );

    if (chat != null) {
      final participants = (chat['participants'] as List)
          .map((p) => (p as ObjectId).oid)
          .toList();
      final otherUserId = participants.firstWhere((id) => id != senderId);

      final unreadCount = Map<String, int>.from(chat['unreadCount'] ?? {});
      unreadCount[otherUserId] = (unreadCount[otherUserId] ?? 0) + 1;

      await _chats.updateOne(
        where.eq('_id', ObjectId.fromHexString(chatId)),
        modify
            .set('lastMessage', {
              'text': text,
              'senderId': ObjectId.fromHexString(senderId),
              'timestamp': DateTime.now(),
            })
            .set('unreadCount', unreadCount)
            .set('updatedAt', DateTime.now()),
      );
    }

    return {...message.toMap(), '_id': result.id};
  }

  Future<List<Map<String, dynamic>>> getMessages(
    String chatId, {
    int page = 1,
    int limit = 50,
  }) async {
    final skip = (page - 1) * limit;
    return await _messages
        .find(where
            .eq('chatId', ObjectId.fromHexString(chatId))
            .sortBy('createdAt', descending: true)
            .skip(skip)
            .limit(limit))
        .toList();
  }

  Future<void> markAsRead(String chatId, String userId) async {
    // Mark all messages in this chat as seen
    await _messages.updateMany(
      where
          .eq('chatId', ObjectId.fromHexString(chatId))
          .ne('senderId', ObjectId.fromHexString(userId))
          .ne('status', 'seen'),
      modify.set('status', 'seen'),
    );

    // Reset unread count
    await _chats.updateOne(
      where.eq('_id', ObjectId.fromHexString(chatId)),
      modify.set('unreadCount.$userId', 0),
    );
  }

  Future<void> updateMessageStatus(String messageId, String status) async {
    await _messages.updateOne(
      where.eq('_id', ObjectId.fromHexString(messageId)),
      modify.set('status', status),
    );
  }

  /// Returns the most recent call_invite message in the chat that hasn't been
  /// ended or declined (i.e., no subsequent call_ended/call_declined message).
  Future<Map<String, dynamic>?> getActiveCall(String chatId) async {
    final lastCallInvite = await _messages
        .find(where
            .eq('chatId', ObjectId.fromHexString(chatId))
            .eq('type', 'call_invite')
            .sortBy('createdAt', descending: true)
            .limit(1))
        .toList();

    if (lastCallInvite.isEmpty) return null;

    final invite = lastCallInvite.first;
    final inviteTime = invite['createdAt'] as DateTime;

    // Check if there's a call_ended or call_declined after this invite
    final endedMessages = await _messages
        .find(where
            .eq('chatId', ObjectId.fromHexString(chatId))
            .oneFrom('type', ['call_ended', 'call_declined'])
            .gte('createdAt', inviteTime)
            .limit(1))
        .toList();

    if (endedMessages.isNotEmpty) return null;

    // Check if invite is older than 60 seconds (expired)
    if (DateTime.now().difference(inviteTime).inSeconds > 60) return null;

    return invite;
  }
}
