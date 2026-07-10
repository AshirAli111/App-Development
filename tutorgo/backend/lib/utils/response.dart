import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';

Response jsonResponse(dynamic data, {int statusCode = 200}) {
  return Response(
    statusCode,
    body: jsonEncode(_sanitize(data)),
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

/// Recursively converts MongoDB types (ObjectId, DateTime) to JSON-safe values
dynamic _sanitize(dynamic value) {
  if (value == null) return null;
  if (value is ObjectId) return value.oid;
  if (value is DateTime) return value.toIso8601String();
  if (value is Map) {
    return value.map((key, v) => MapEntry(key.toString(), _sanitize(v)));
  }
  if (value is List) {
    return value.map(_sanitize).toList();
  }
  return value;
}
