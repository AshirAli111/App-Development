import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _keyAccessToken = 'auth_access_token';
  static const _keyRefreshToken = 'auth_refresh_token';
  static const _keyUserId = 'auth_user_id';
  static const _keyRole = 'auth_role';
  static const _keyEmail = 'auth_email';
  static const _keyFullName = 'auth_full_name';
  static const _keyBaseUrl = 'auth_base_url';

  String _accessToken = '';
  String _refreshToken = '';
  String _userId = '';
  String _role = '';
  String _email = '';
  String _fullName = '';
  String _baseUrl = 'http://localhost:8080';
  bool _isLoading = true;

  String get accessToken => _accessToken;
  String get refreshToken => _refreshToken;
  String get userId => _userId;
  String get role => _role;
  String get email => _email;
  String get fullName => _fullName;
  String get baseUrl => _baseUrl;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _accessToken.isNotEmpty;

  AuthService get _authService => AuthService(baseUrl: _baseUrl);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_keyAccessToken) ?? '';
    _refreshToken = prefs.getString(_keyRefreshToken) ?? '';
    _userId = prefs.getString(_keyUserId) ?? '';
    _role = prefs.getString(_keyRole) ?? '';
    _email = prefs.getString(_keyEmail) ?? '';
    _fullName = prefs.getString(_keyFullName) ?? '';
    _baseUrl = prefs.getString(_keyBaseUrl) ?? 'http://localhost:8080';

    // Try to refresh token if we have one
    if (_refreshToken.isNotEmpty) {
      try {
        final result = await _authService.refreshToken(_refreshToken);
        _accessToken = result['accessToken'] as String;
        _refreshToken = result['refreshToken'] as String;
        await _persistTokens();
      } catch (_) {
        // Refresh failed — clear everything
        await _clearAll();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final result = await _authService.login(email: email, password: password);
    await _handleAuthResponse(result);
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
  }) async {
    final result = await _authService.register(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
      phone: phone,
    );
    await _handleAuthResponse(result);
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBaseUrl, url);
    notifyListeners();
  }

  Future<void> logout() async {
    await _clearAll();
    notifyListeners();
  }

  Future<void> tryRefreshToken() async {
    if (_refreshToken.isEmpty) throw Exception('No refresh token');
    final result = await _authService.refreshToken(_refreshToken);
    _accessToken = result['accessToken'] as String;
    _refreshToken = result['refreshToken'] as String;
    await _persistTokens();
    notifyListeners();
  }

  Future<void> _handleAuthResponse(Map<String, dynamic> result) async {
    _accessToken = result['accessToken'] as String;
    _refreshToken = result['refreshToken'] as String;

    final user = result['user'] as Map<String, dynamic>;
    _userId = user['id'] as String? ?? '';
    _role = user['role'] as String? ?? '';
    _email = user['email'] as String? ?? '';
    _fullName = user['fullName'] as String? ?? '';

    await _persistAll();
    notifyListeners();
  }

  Future<void> _persistAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, _accessToken);
    await prefs.setString(_keyRefreshToken, _refreshToken);
    await prefs.setString(_keyUserId, _userId);
    await prefs.setString(_keyRole, _role);
    await prefs.setString(_keyEmail, _email);
    await prefs.setString(_keyFullName, _fullName);
    await prefs.setString(_keyBaseUrl, _baseUrl);
  }

  Future<void> _persistTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, _accessToken);
    await prefs.setString(_keyRefreshToken, _refreshToken);
  }

  Future<void> _clearAll() async {
    _accessToken = '';
    _refreshToken = '';
    _userId = '';
    _role = '';
    _email = '';
    _fullName = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyFullName);
  }
}
