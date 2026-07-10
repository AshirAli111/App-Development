import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/session_service.dart';
import '../utils/response.dart';

class SessionRoutes {
  final _sessionService = SessionService();

  Router get router {
    final router = Router();

    router.post('/', _createSession);
    router.get('/', _getSessions);
    router.get('/<id>', _getSession);
    router.put('/<id>', _updateSession);
    router.delete('/<id>', _cancelSession);
    router.get('/<id>/instances', _getInstances);

    return router;
  }

  Future<Response> _createSession(Request request) async {
    try {
      final body = await parseBody(request);

      final required = ['studentId', 'tutorId', 'subject', 'recurrence', 'pricePerSessionPKR'];
      for (final field in required) {
        if (body[field] == null) {
          return errorResponse('$field is required');
        }
      }

      final result = await _sessionService.createSession(body);
      return jsonResponse(result, statusCode: 201);
    } on Exception catch (e) {
      return errorResponse(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Response> _getSessions(Request request) async {
    final userId = request.headers['x-user-id'];
    final role = request.headers['x-user-role'];
    if (userId == null || role == null) {
      return errorResponse('Unauthorized', statusCode: 401);
    }

    final sessions = await _sessionService.getSessionsByUser(userId, role);
    return jsonResponse({'sessions': sessions});
  }

  Future<Response> _getSession(Request request, String id) async {
    final session = await _sessionService.getSessionById(id);
    if (session == null) {
      return errorResponse('Session not found', statusCode: 404);
    }
    return jsonResponse(session);
  }

  Future<Response> _updateSession(Request request, String id) async {
    try {
      final body = await parseBody(request);
      await _sessionService.updateSession(id, body);
      final updated = await _sessionService.getSessionById(id);
      return jsonResponse(updated);
    } on Exception catch (e) {
      return errorResponse(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Response> _cancelSession(Request request, String id) async {
    try {
      await _sessionService.cancelSession(id);
      return jsonResponse({'message': 'Session cancelled'});
    } on Exception catch (e) {
      return errorResponse(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Response> _getInstances(Request request, String id) async {
    final instances = await _sessionService.getInstancesBySession(id);
    return jsonResponse({'instances': instances});
  }
}
