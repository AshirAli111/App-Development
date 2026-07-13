import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/chat_service.dart';
import '../services/content_moderation_service.dart';
import '../utils/response.dart';

class ChatRoutes {
  final _chatService = ChatService();
  final _moderation = ContentModerationService();

  Router get router {
    final router = Router();

    router.get('/', _getChats);
    router.post('/start', _startChat);
    router.get('/<id>/messages', _getMessages);
    router.post('/<id>/messages', _sendMessage);
    router.put('/<id>/read', _markAsRead);
    router.get('/<id>/active-call', _getActiveCall);

    return router;
  }

  Future<Response> _startChat(Request request) async {
    final userId = request.headers['x-user-id'];
    if (userId == null) return errorResponse('Unauthorized', statusCode: 401);

    final body = await parseBody(request);
    final otherUserId = body['otherUserId'] as String?;

    if (otherUserId == null || otherUserId.isEmpty) {
      return errorResponse('otherUserId is required');
    }

    if (userId == otherUserId) {
      return errorResponse('Cannot start chat with yourself');
    }

    final chat = await _chatService.getOrCreateChat(userId, otherUserId);
    return jsonResponse({'chat': chat}, statusCode: 201);
  }

  Future<Response> _getActiveCall(Request request, String id) async {
    final userId = request.headers['x-user-id'];
    if (userId == null) return errorResponse('Unauthorized', statusCode: 401);

    final activeCall = await _chatService.getActiveCall(id);
    return jsonResponse({'activeCall': activeCall});
  }

  Future<Response> _getChats(Request request) async {
    final userId = request.headers['x-user-id'];
    if (userId == null) return errorResponse('Unauthorized', statusCode: 401);

    final chats = await _chatService.getUserChats(userId);
    return jsonResponse({'chats': chats});
  }

  Future<Response> _getMessages(Request request, String id) async {
    final page =
        int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;
    final limit =
        int.tryParse(request.url.queryParameters['limit'] ?? '50') ?? 50;

    final messages = await _chatService.getMessages(id, page: page, limit: limit);
    return jsonResponse({'messages': messages, 'page': page, 'limit': limit});
  }

  Future<Response> _sendMessage(Request request, String id) async {
    try {
      final userId = request.headers['x-user-id'];
      if (userId == null) return errorResponse('Unauthorized', statusCode: 401);

      final body = await parseBody(request);
      var text = body['text'] as String?;

      if (text == null || text.isEmpty) {
        return errorResponse('text is required');
      }

      // Mask phone numbers and abusive words before the message is stored —
      // `call_invite` carries a Jitsi room name, not user text, so it is
      // left untouched (TICKET-19).
      final type = body['type'] as String? ?? 'text';
      if (type != 'call_invite') {
        text = _moderation.sanitize(text);
      }

      final message = await _chatService.sendMessage(
        chatId: id,
        senderId: userId,
        text: text,
        type: body['type'] as String? ?? 'text',
        sessionRequest: body['sessionRequest'] as Map<String, dynamic>?,
      );

      return jsonResponse(message, statusCode: 201);
    } on Exception catch (e) {
      return errorResponse(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Response> _markAsRead(Request request, String id) async {
    final userId = request.headers['x-user-id'];
    if (userId == null) return errorResponse('Unauthorized', statusCode: 401);

    await _chatService.markAsRead(id, userId);
    return jsonResponse({'message': 'Marked as read'});
  }
}
