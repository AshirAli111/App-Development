import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/user_service.dart';
import '../utils/response.dart';

class UserRoutes {
  final _userService = UserService();

  Router get router {
    final router = Router();

    router.get('/me', _getMe);
    router.put('/me', _updateMe);
    router.delete('/me', _deleteMe);
    router.get('/tutors', _getTutors);
    router.get('/tutors/<id>', _getTutorById);

    return router;
  }

  Future<Response> _getMe(Request request) async {
    final userId = request.headers['x-user-id'];
    if (userId == null) return errorResponse('Unauthorized', statusCode: 401);

    final user = await _userService.getUserById(userId);
    if (user == null) return errorResponse('User not found', statusCode: 404);

    return jsonResponse(user);
  }

  Future<Response> _updateMe(Request request) async {
    final userId = request.headers['x-user-id'];
    if (userId == null) return errorResponse('Unauthorized', statusCode: 401);

    try {
      final body = await parseBody(request);
      final updated = await _userService.updateUser(userId, body);

      if (updated == null) {
        return errorResponse('User not found', statusCode: 404);
      }
      return jsonResponse(updated);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('duplicate') || msg.contains('e11000')) {
        return errorResponse('That email is already in use',
            statusCode: 409);
      }
      return errorResponse('Failed to update profile', statusCode: 400);
    }
  }

  Future<Response> _deleteMe(Request request) async {
    final userId = request.headers['x-user-id'];
    if (userId == null) return errorResponse('Unauthorized', statusCode: 401);

    final deleted = await _userService.deleteUser(userId);
    if (!deleted) return errorResponse('User not found', statusCode: 404);

    return jsonResponse({'message': 'Account deleted successfully'});
  }

  Future<Response> _getTutors(Request request) async {
    final subject = request.url.queryParameters['subject'];
    final page = int.tryParse(request.url.queryParameters['page'] ?? '1') ?? 1;
    final limit =
        int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;

    final tutors = await _userService.getTutors(
      subject: subject,
      page: page,
      limit: limit,
    );

    return jsonResponse({'tutors': tutors, 'page': page, 'limit': limit});
  }

  Future<Response> _getTutorById(Request request, String id) async {
    final tutor = await _userService.getTutorById(id);
    if (tutor == null) return errorResponse('Tutor not found', statusCode: 404);
    return jsonResponse(tutor);
  }
}
