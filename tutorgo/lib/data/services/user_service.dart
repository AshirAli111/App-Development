import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl;
  final String token;
  final String userId;

  UserService({
    required this.baseUrl,
    required this.token,
    required this.userId,
  });

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-user-id': userId,
      };

  Future<Map<String, dynamic>?> getMyProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/me'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateProfile(
      Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/me'),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getTutors({
    String? subject,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (subject != null && subject.isNotEmpty) params['subject'] = subject;

    final uri = Uri.parse('$baseUrl/api/users/tutors')
        .replace(queryParameters: params);

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['tutors'] ?? []);
    }
    return [];
  }

  Future<Map<String, dynamic>?> getTutor(String tutorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/tutors/$tutorId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  /// Deletes the account after verifying [password]. Returns null on success,
  /// or an error message (e.g. wrong password) on failure.
  Future<String?> deleteAccount(String password) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/users/me'),
      headers: _headers,
      body: jsonEncode({'password': password}),
    );
    if (response.statusCode == 200) return null;
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['error'] ?? 'Failed to delete account').toString();
    } catch (_) {
      return 'Failed to delete account';
    }
  }
}
