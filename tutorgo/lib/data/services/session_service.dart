import 'dart:convert';
import 'package:http/http.dart' as http;

class SessionService {
  final String baseUrl;
  final String token;
  final String userId;
  final String role;

  SessionService({
    required this.baseUrl,
    required this.token,
    required this.userId,
    required this.role,
  });

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-user-id': userId,
        'x-user-role': role,
      };

  Future<Map<String, dynamic>?> createSession(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/sessions/'),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getMySessions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/sessions/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['sessions'] ?? []);
    }
    return [];
  }

  Future<Map<String, dynamic>?> getSession(String sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/sessions/$sessionId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateSession(
      String sessionId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/sessions/$sessionId'),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> cancelSession(String sessionId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/sessions/$sessionId'),
      headers: _headers,
    );
    return response.statusCode == 200;
  }

  Future<List<Map<String, dynamic>>> getSessionInstances(
      String sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/sessions/$sessionId/instances'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['instances'] ?? []);
    }
    return [];
  }
}
