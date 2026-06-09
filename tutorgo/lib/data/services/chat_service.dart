import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String baseUrl;
  final String token;
  final String userId;

  ChatService({
    required this.baseUrl,
    required this.token,
    required this.userId,
  });

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-user-id': userId,
      };

  /// Fetch all chats for current user
  Future<List<Map<String, dynamic>>> getChats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/chats/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['chats'] ?? []);
    }
    return [];
  }

  /// Fetch messages for a specific chat
  Future<List<Map<String, dynamic>>> getMessages(
    String chatId, {
    int page = 1,
    int limit = 50,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/chats/$chatId/messages?page=$page&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['messages'] ?? []);
    }
    return [];
  }

  /// Send a message to a chat
  Future<Map<String, dynamic>?> sendMessage(
    String chatId, {
    required String text,
    String type = 'text',
    Map<String, dynamic>? sessionRequest,
  }) async {
    final body = <String, dynamic>{
      'text': text,
      'type': type,
    };
    if (sessionRequest != null) {
      body['sessionRequest'] = sessionRequest;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/chats/$chatId/messages'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  /// Start or get existing chat with another user
  Future<Map<String, dynamic>?> startChat(String otherUserId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/chats/start'),
      headers: _headers,
      body: jsonEncode({'otherUserId': otherUserId}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['chat'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// Mark a chat as read
  Future<void> markAsRead(String chatId) async {
    await http.put(
      Uri.parse('$baseUrl/api/chats/$chatId/read'),
      headers: _headers,
    );
  }

  /// Get active call for a chat
  Future<Map<String, dynamic>?> getActiveCall(String chatId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/chats/$chatId/active-call'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['activeCall'] as Map<String, dynamic>?;
    }
    return null;
  }
}
