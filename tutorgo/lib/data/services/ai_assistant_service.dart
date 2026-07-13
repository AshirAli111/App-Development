import 'dart:convert';
import 'package:http/http.dart' as http;

/// The assistant's reply plus the moderated ("blurred") copy of the message
/// the user sent — phone numbers and abusive words come back masked with `*`
/// so the UI can show the censored version in the sender's own bubble.
class AiChatResult {
  final String reply;
  final String sanitizedMessage;
  const AiChatResult({required this.reply, required this.sanitizedMessage});
}

/// Talks to the backend AI assistant (`POST /api/ai/chat`), which proxies to
/// Gemini. The API key lives on the backend, never in the app.
class AiAssistantService {
  final String baseUrl;
  final String token;

  AiAssistantService({required this.baseUrl, required this.token});

  /// [history] is prior turns as `{'role': 'user'|'assistant', 'content': ...}`.
  Future<AiChatResult> sendMessage({
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
      return AiChatResult(
        reply: data['reply'] as String,
        sanitizedMessage: data['sanitizedMessage'] as String? ?? message,
      );
    }
    throw Exception(data['error'] ?? 'The assistant is unavailable right now.');
  }
}
