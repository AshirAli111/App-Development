import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/ai_conversation_service.dart';
import '../utils/response.dart';

class AiRoutes {
  final _aiService = AiConversationService();

  Router get router {
    final router = Router();

    router.get('/conversations', _getConversations);
    router.post('/conversations', _createConversation);
    router.get('/conversations/<id>', _getConversation);
    router.post('/conversations/<id>/message', _addMessage);
    router.delete('/conversations/<id>', _deleteConversation);

    return router;
  }

  Future<Response> _getConversations(Request request) async {
    final userId = request.headers['x-user-id'];
    if (userId == null) return errorResponse('Unauthorized', statusCode: 401);

    final conversations = await _aiService.getUserConversations(userId);
    return jsonResponse({'conversations': conversations});
  }

  Future<Response> _createConversation(Request request) async {
    try {
      final userId = request.headers['x-user-id'];
      final role = request.headers['x-user-role'];
      if (userId == null || role == null) {
        return errorResponse('Unauthorized', statusCode: 401);
      }

      final body = await parseBody(request);
      final message = body['message'] as String?;

      if (message == null || message.isEmpty) {
        return errorResponse('message is required');
      }

      final conversation = await _aiService.createConversation(
        userId: userId,
        role: role,
        firstMessage: message,
      );

      return jsonResponse(conversation, statusCode: 201);
    } on Exception catch (e) {
      return errorResponse(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Response> _getConversation(Request request, String id) async {
    final conversation = await _aiService.getConversation(id);
    if (conversation == null) {
      return errorResponse('Conversation not found', statusCode: 404);
    }
    return jsonResponse(conversation);
  }

  Future<Response> _addMessage(Request request, String id) async {
    try {
      final body = await parseBody(request);
      final text = body['text'] as String?;
      final isUser = body['isUser'] as bool? ?? true;

      if (text == null || text.isEmpty) {
        return errorResponse('text is required');
      }

      final updated = await _aiService.addMessage(
        conversationId: id,
        text: text,
        isUser: isUser,
      );

      if (updated == null) {
        return errorResponse('Conversation not found', statusCode: 404);
      }

      return jsonResponse(updated);
    } on Exception catch (e) {
      return errorResponse(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Response> _deleteConversation(Request request, String id) async {
    await _aiService.deleteConversation(id);
    return jsonResponse({'message': 'Conversation deleted'});
  }
}
