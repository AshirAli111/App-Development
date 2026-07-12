import 'dart:convert';
import 'package:http/http.dart' as http;

class AssignmentService {
  final String baseUrl;
  final String token;
  final String userId;
  final String role;

  AssignmentService({
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

  Future<List<Map<String, dynamic>>> getAssignments() async {
    final res = await http.get(Uri.parse('$baseUrl/api/assignments/'),
        headers: _headers);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(data['assignments'] ?? []);
    }
    return [];
  }

  Future<Map<String, dynamic>?> createAssignment({
    required String studentId,
    required String title,
    required String subject,
    required String description,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/assignments/'),
      headers: _headers,
      body: jsonEncode({
        'studentId': studentId,
        'title': title,
        'subject': subject,
        'description': description,
      }),
    );
    if (res.statusCode == 201) return jsonDecode(res.body) as Map<String, dynamic>;
    return null;
  }

  Future<Map<String, dynamic>?> submitAssignment(
      String id, String fileBase64, String fileName) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/assignments/$id/submit'),
      headers: _headers,
      body: jsonEncode({'fileBase64': fileBase64, 'fileName': fileName}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
    return null;
  }

  Future<Map<String, dynamic>?> gradeAssignment(
      String id, int marks, String feedback) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/assignments/$id/grade'),
      headers: _headers,
      body: jsonEncode({'marks': marks, 'feedback': feedback}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
    return null;
  }
}
