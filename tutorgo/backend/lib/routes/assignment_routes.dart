import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/assignment_service.dart';
import '../utils/response.dart';

class AssignmentRoutes {
  final _service = AssignmentService();

  Router get router {
    final router = Router();
    router.post('/', _create);
    router.get('/', _list);
    router.post('/<id>/submit', _submit);
    router.put('/<id>/grade', _grade);
    return router;
  }

  Future<Response> _create(Request request) async {
    try {
      final tutorId = request.headers['x-user-id'];
      if (tutorId == null) return errorResponse('Unauthorized', statusCode: 401);
      final body = await parseBody(request);
      if (body['studentId'] == null || body['title'] == null) {
        return errorResponse('studentId and title are required');
      }
      final result = await _service.create(body, tutorId);
      return jsonResponse(result, statusCode: 201);
    } on Exception catch (e) {
      return errorResponse(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Response> _list(Request request) async {
    final userId = request.headers['x-user-id'];
    final role = request.headers['x-user-role'];
    if (userId == null || role == null) {
      return errorResponse('Unauthorized', statusCode: 401);
    }
    final assignments = await _service.listForUser(userId, role);
    return jsonResponse({'assignments': assignments});
  }

  Future<Response> _submit(Request request, String id) async {
    try {
      final body = await parseBody(request);
      if (body['fileBase64'] == null) {
        return errorResponse('fileBase64 is required');
      }
      final result = await _service.submit(id, body);
      if (result == null) {
        return errorResponse('Assignment not found', statusCode: 404);
      }
      return jsonResponse(result);
    } on Exception catch (e) {
      return errorResponse(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Response> _grade(Request request, String id) async {
    try {
      final body = await parseBody(request);
      final result = await _service.grade(id, body);
      if (result == null) {
        return errorResponse('Assignment not found', statusCode: 404);
      }
      return jsonResponse(result);
    } on Exception catch (e) {
      return errorResponse(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
