import 'dart:convert';
import 'package:shelf/shelf.dart';

Response jsonResponse(dynamic data, {int statusCode = 200}) {
  return Response(
    statusCode,
    body: jsonEncode(data),
    headers: {'content-type': 'application/json'},
  );
}

Response errorResponse(String message, {int statusCode = 400}) {
  return Response(
    statusCode,
    body: jsonEncode({'error': message}),
    headers: {'content-type': 'application/json'},
  );
}

Future<Map<String, dynamic>> parseBody(Request request) async {
  final body = await request.readAsString();
  if (body.isEmpty) return {};
  return jsonDecode(body) as Map<String, dynamic>;
}
