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
  // Read raw bytes and decode as UTF-8 tolerantly, so a stray non-UTF-8 byte
  // (e.g. a client that sent CP1252) can't crash request handling.
  final bytes = await request
      .read()
      .fold<List<int>>(<int>[], (b, chunk) => b..addAll(chunk));
  if (bytes.isEmpty) return {};
  final body = utf8.decode(bytes, allowMalformed: true);
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
