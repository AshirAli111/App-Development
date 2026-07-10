import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  final String baseUrl;
  final String token;
  final String userId;

  NotificationService({
    required this.baseUrl,
    required this.token,
    required this.userId,
  });

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-user-id': userId,
      };

  Future<List<Map<String, dynamic>>> getNotifications({
    bool unreadOnly = false,
    int page = 1,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
    };
    if (unreadOnly) params['unreadOnly'] = 'true';

    final uri = Uri.parse('$baseUrl/api/notifications/')
        .replace(queryParameters: params);

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['notifications'] ?? []);
    }
    return [];
  }

  Future<void> markAsRead(String notificationId) async {
    await http.put(
      Uri.parse('$baseUrl/api/notifications/$notificationId/read'),
      headers: _headers,
    );
  }

  Future<void> markAllAsRead() async {
    await http.put(
      Uri.parse('$baseUrl/api/notifications/read-all'),
      headers: _headers,
    );
  }
}
