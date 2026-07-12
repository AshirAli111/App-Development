import 'dart:convert';
import 'package:http/http.dart' as http;

class QuizService {
  final String baseUrl;
  final String token;
  final String userId;
  final String role;

  QuizService({
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

  Future<List<Map<String, dynamic>>> getQuizzes() async {
    final res = await http.get(Uri.parse('$baseUrl/api/quizzes/'),
        headers: _headers);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(data['quizzes'] ?? []);
    }
    return [];
  }

  Future<Map<String, dynamic>?> createQuiz({
    required String studentId,
    required String title,
    required String subject,
    required List<Map<String, dynamic>> questions,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/quizzes/'),
      headers: _headers,
      body: jsonEncode({
        'studentId': studentId,
        'title': title,
        'subject': subject,
        'questions': questions,
      }),
    );
    if (res.statusCode == 201) return jsonDecode(res.body) as Map<String, dynamic>;
    return null;
  }

  Future<Map<String, dynamic>?> submitQuiz(
      String quizId, List<int> answers) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/quizzes/$quizId/submit'),
      headers: _headers,
      body: jsonEncode({'answers': answers}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
    return null;
  }
}
