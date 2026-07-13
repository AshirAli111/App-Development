import 'dart:convert';
import 'package:http/http.dart' as http;

/// Talks to the backend AI assistant (`POST /api/ai/chat`), which proxies to
/// Llama via OpenRouter. The API key lives on the backend, never in the app.
class AiAssistantService {
  final String baseUrl;
  final String token;

  AiAssistantService({required this.baseUrl, required this.token});

  /// [history] is prior turns as `{'role': 'user'|'assistant', 'content': ...}`.
  Future<String> sendMessage({
    required String message,
    List<Map<String, String>> history = const [],
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ai/chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'message': message, 'history': history}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return data['reply'] as String;
    }
    throw Exception(data['error'] ?? 'The assistant is unavailable right now.');
  }
}
