import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/auth_service.dart';
import '../utils/response.dart';

class AuthRoutes {
  final _authService = AuthService();

  Router get router {
    final router = Router();

    router.post('/register', _register);
    router.post('/login', _login);
    router.post('/refresh', _refresh);

    return router;
  }

  Future<Response> _register(Request request) async {
    try {
      final body = await parseBody(request);

      final email = body['email'] as String?;
      final password = body['password'] as String?;
      final fullName = body['fullName'] as String?;
      final role = body['role'] as String?;

      if (email == null || password == null || fullName == null || role == null) {
        return errorResponse('email, password, fullName, and role are required');
      }

      if (password.length < 6) {
        return errorResponse('Password must be at least 6 characters');
      }

      final result = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        phone: body['phone'] as String?,
      );

      return jsonResponse(result, statusCode: 201);
    } on Exception catch (e) {
      return errorResponse(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Response> _login(Request request) async {
    try {
      final body = await parseBody(request);

      final email = body['email'] as String?;
      final password = body['password'] as String?;

      if (email == null || password == null) {
        return errorResponse('email and password are required');
      }

      final result = await _authService.login(
        email: email,
        password: password,
      );

      return jsonResponse(result);
    } on Exception catch (e) {
      return errorResponse(
        e.toString().replaceFirst('Exception: ', ''),
        statusCode: 401,
      );
    }
  }

  Future<Response> _refresh(Request request) async {
    try {
      final body = await parseBody(request);
      final refreshToken = body['refreshToken'] as String?;

      if (refreshToken == null) {
        return errorResponse('refreshToken is required');
      }

      final result = await _authService.refreshToken(refreshToken);
      return jsonResponse(result);
    } on Exception catch (e) {
      return errorResponse(
        e.toString().replaceFirst('Exception: ', ''),
        statusCode: 401,
      );
    }
  }
}
