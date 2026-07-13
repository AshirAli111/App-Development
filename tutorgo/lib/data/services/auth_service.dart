import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl;

  AuthService({required this.baseUrl});

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(data['error'] ?? 'Login failed');
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
      'fullName': fullName,
      'role': role,
    };
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;

    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) {
      return data;
    }
    throw Exception(data['error'] ?? 'Registration failed');
  }

  /// Verifies a password-reset request using the account's email + phone.
  /// No code is sent; returns `{ resetToken }` when both match one account.
  Future<Map<String, dynamic>> verifyIdentity({
    required String email,
    required String phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-identity'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'phone': phone}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(data['error'] ?? 'Verification failed');
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'resetToken': resetToken, 'newPassword': newPassword}),
    );

    if (response.statusCode == 200) return;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(data['error'] ?? 'Failed to reset password');
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(data['error'] ?? 'Token refresh failed');
  }
}
