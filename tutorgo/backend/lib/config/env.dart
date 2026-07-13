import 'dart:io';
import 'package:dotenv/dotenv.dart';

class Env {
  static late DotEnv _dotEnv;

  static void load() {
    _dotEnv = DotEnv(includePlatformEnvironment: true)..load(['${Directory.current.path}/.env']);
  }

  static String get mongoUri => _dotEnv['MONGO_URI'] ?? '';
  static String get dbName => _dotEnv['DB_NAME'] ?? 'tutorgo_db';
  static String get jwtSecret => _dotEnv['JWT_SECRET'] ?? 'default_secret';
  static int get jwtExpiry => int.parse(_dotEnv['JWT_EXPIRY'] ?? '3600');
  static int get refreshTokenExpiry => int.parse(_dotEnv['REFRESH_TOKEN_EXPIRY'] ?? '604800');
  static int get port => int.parse(_dotEnv['PORT'] ?? '8080');

  static String get openRouterApiKey => _dotEnv['OPENROUTER_API_KEY'] ?? '';
  static String get openRouterModel =>
      _dotEnv['OPENROUTER_MODEL'] ?? 'meta-llama/llama-3.3-70b-instruct';
}
