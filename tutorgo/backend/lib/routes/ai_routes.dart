import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/ai_assistant_service.dart';
import '../services/ai_conversation_service.dart';
import '../services/session_service.dart';
import '../services/user_service.dart';
import '../utils/response.dart';

class AiRoutes {
  final _aiService = AiConversationService();
  final _assistant = AiAssistantService();
  final _userService = UserService();
  final _sessionService = SessionService();

  Router get router {
    final router = Router();

    router.post('/chat', _chat);
    router.get('/conversations', _getConversations);
    router.post('/conversations', _createConversation);
    router.get('/conversations/<id>', _getConversation);
    router.post('/conversations/<id>/message', _addMessage);
    router.delete('/conversations/<id>', _deleteConversation);

    return router;
  }

  /// Stateless assistant reply. Body: { message, history? } where history is a
  /// list of { role: 'user'|'assistant', content }. Role comes from the JWT.
  Future<Response> _chat(Request request) async {
    try {
      final userId = request.headers['x-user-id'];
      final role = request.headers['x-user-role'] ?? 'student';
      final body = await parseBody(request);
      final message = (body['message'] as String?)?.trim();

      if (message == null || message.isEmpty) {
        return errorResponse('message is required');
      }

      final history = (body['history'] as List?)
              ?.whereType<Map>()
              .map((m) => Map<String, dynamic>.from(m))
              .toList() ??
          const <Map<String, dynamic>>[];

      final userContext =
          userId != null ? await _buildUserContext(userId, role) : '';

      final reply = await _assistant.reply(
        role: role,
        message: message,
        history: history,
        userContext: userContext,
      );

      return jsonResponse({'reply': reply});
    } on Exception catch (e) {
      return errorResponse(
        e.toString().replaceFirst('Exception: ', ''),
        statusCode: 502,
      );
    }
  }

  /// Compact snapshot of the user's real account data (profile + active
  /// sessions), injected into the prompt so the assistant can answer questions
  /// like "who are my students". Kept short — this is a free-tier model.
  Future<String> _buildUserContext(String userId, String role) async {
    try {
      final profile = await _userService.getUserById(userId);
      if (profile == null) return '';

      final lines = <String>[];
      lines.add('Name: ${profile['fullName'] ?? 'Unknown'}');
      lines.add('Role: $role');
      if (profile['email'] != null) lines.add('Email: ${profile['email']}');
      if (profile['phone'] != null) lines.add('Phone: ${profile['phone']}');

      if (role == 'tutor') {
        final tp = profile['tutorProfile'] as Map<String, dynamic>?;
        final subjects = (tp?['subjects'] as List?)?.join(', ');
        if (subjects != null && subjects.isNotEmpty) {
          lines.add('Subjects taught: $subjects');
        }
        if (tp?['pricePerHourPKR'] != null) {
          lines.add('Rate: PKR ${tp!['pricePerHourPKR']}/hour');
        }
        if (tp?['rating'] != null) {
          lines.add(
              'Rating: ${tp!['rating']} (${tp['totalRatings'] ?? 0} ratings)');
        }
        lines.add(profile['payoutAccount'] != null
            ? 'Payout account: set up'
            : 'Payout account: not set up yet');
      } else {
        final sp = profile['studentProfile'] as Map<String, dynamic>?;
        final courses = (sp?['selectedCourses'] as List?)?.join(', ');
        if (courses != null && courses.isNotEmpty) {
          lines.add('Enrolled courses: $courses');
        }
        if (sp?['grade'] != null) lines.add('Grade: ${sp!['grade']}');
      }

      // Active sessions → the other party + subject/time.
      final sessions = await _sessionService.getSessionsByUser(userId, role);
      if (sessions.isEmpty) {
        lines.add(role == 'tutor'
            ? 'Students: none yet (no active sessions).'
            : 'Tutors: none yet (no active sessions).');
      } else {
        final counterpartKey = role == 'tutor' ? 'studentName' : 'tutorName';
        final label = role == 'tutor' ? 'Students' : 'Tutors';
        final items = <String>[];
        final seen = <String>{};
        for (final s in sessions) {
          final name = s[counterpartKey]?.toString() ?? 'Unknown';
          final subject = s['subject']?.toString();
          final rec = s['recurrence'] as Map<String, dynamic>?;
          final day = _dayName(rec?['dayOfWeek']);
          final time = rec?['startTime'];
          final when = [day, time].where((e) => e != null).join(' ');
          final key = '$name|$subject|$when';
          if (seen.add(key)) {
            final detail =
                [subject, when].where((e) => e != null && e != '').join(', ');
            items.add(detail.isEmpty ? name : '$name ($detail)');
          }
        }
        lines.add('$label (${items.length}): ${items.join('; ')}');
      }

      return lines.join('\n');
    } catch (_) {
      // Never let context-building break the chat.
      return '';
    }
  }

  String? _dayName(dynamic dayOfWeek) {
    if (dayOfWeek is! int) return null;
    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    if (dayOfWeek < 1 || dayOfWeek > 7) return null;
    return days[dayOfWeek - 1];
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
