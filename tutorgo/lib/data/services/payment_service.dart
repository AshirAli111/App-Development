import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  final String baseUrl;
  final String token;
  final String userId;
  final String role;

  PaymentService({
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

  Future<List<Map<String, dynamic>>> getPayments({int page = 1}) async {
    final uri = Uri.parse('$baseUrl/api/payments/')
        .replace(queryParameters: {'page': page.toString()});

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['payments'] ?? []);
    }
    return [];
  }

  Future<Map<String, dynamic>?> getPaymentSummary() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/payments/summary'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>?> createPayment({
    required String studentId,
    required String tutorId,
    required int amountPKR,
    required String method,
    String? sessionInstanceId,
  }) async {
    final body = <String, dynamic>{
      'studentId': studentId,
      'tutorId': tutorId,
      'amountPKR': amountPKR,
      'method': method,
    };
    if (sessionInstanceId != null) body['sessionInstanceId'] = sessionInstanceId;

    final response = await http.post(
      Uri.parse('$baseUrl/api/payments/'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }
}
