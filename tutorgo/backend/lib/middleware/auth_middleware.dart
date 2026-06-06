import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../config/env.dart';

Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) {
      final authHeader = request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(401,
            body: jsonEncode({'error': 'Missing or invalid authorization header'}),
            headers: {'content-type': 'application/json'});
      }

      final token = authHeader.substring(7);

      try {
        final jwt = JWT.verify(token, SecretKey(Env.jwtSecret));
        final payload = jwt.payload as Map<String, dynamic>;

        // Add user info to request context via headers
        final updatedRequest = request.change(headers: {
          'x-user-id': payload['userId'],
          'x-user-role': payload['role'],
          'x-user-email': payload['email'],
        });

        return innerHandler(updatedRequest);
      } on JWTExpiredException {
        return Response(401,
            body: jsonEncode({'error': 'Token expired'}),
            headers: {'content-type': 'application/json'});
      } on JWTException catch (e) {
        return Response(401,
            body: jsonEncode({'error': 'Invalid token: ${e.message}'}),
            headers: {'content-type': 'application/json'});
      }
    };
  };
}
