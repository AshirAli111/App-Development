import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/auth_service.dart';
import '../services/ocr_results_service.dart';
import '../services/user_service.dart';
import '../utils/response.dart';

class UserRoutes {
  final _userService = UserService();
  final _authService = AuthService();
  final _ocrResults = OcrResultsService();

  Router get router {
    final router = Router();

    router.get('/me', _getMe);
    router.put('/me', _updateMe);
    router.put('/me/credentials', _updateCredentials);
    router.delete('/me', _deleteMe);
    router.get('/tutors', _getTutors);
    router.get('/tutors/<id>', _getTutorById);

    return router;
  }

  /// Change email and/or password after verifying the current password.
  Future<Response> _updateCredentials(Request request) async {
    final userId = request.headers['x-user-id'];
    if (userId == null) return errorResponse('Unauthorized', statusCode: 401);

    try {
      final body = await parseBody(request);
      final currentPassword = body['currentPassword'] as String?;
      if (currentPassword == null || currentPassword.isEmpty) {
        return errorResponse('currentPassword is required');
      }

      final updated = await _authService.changeCredentials(
        userId: userId,
        currentPassword: currentPassword,
        newEmail: body['newEmail'] as String?,
        newPassword: body['newPassword'] as String?,
      );
      return jsonResponse(updated);
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      final status = msg.contains('already in use')
          ? 409
          : msg.contains('incorrect')
              ? 401
              : 400;
      return errorResponse(msg, statusCode: status);
    }
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

      // Capture the raw documents before updateUser mutates the body: when a
      // tutor submits registration documents, their OCR text is extracted and
      // stored on the same user document (`ocrResults`) for admin verification.
      final documents = (body['tutorProfile'] is Map)
          ? (body['tutorProfile'] as Map)['documents']
          : null;

      final updated = await _userService.updateUser(userId, body);

      if (updated == null) {
        return errorResponse('User not found', statusCode: 404);
      }

      if (documents is Map && documents.isNotEmpty) {
        // Fire-and-forget: OCR of up to 4 documents can take a while, so the
        // profile update responds now and ocrResults lands moments later.
        unawaited(_ocrResults.processAndStore(
          userId: userId,
          documents: Map<String, dynamic>.from(documents),
        ));
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
