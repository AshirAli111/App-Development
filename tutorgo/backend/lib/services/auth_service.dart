import 'package:dbcrypt/dbcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../config/database.dart';
import '../config/env.dart';
import '../models/user_model.dart';

class AuthService {
  final _dbcrypt = DBCrypt();

  DbCollection get _users => Database.instance.collection('users');

  String _hashPassword(String password) {
    final salt = _dbcrypt.gensaltWithRounds(10);
    return _dbcrypt.hashpw(password, salt);
  }

  bool _verifyPassword(String password, String hash) {
    return _dbcrypt.checkpw(password, hash);
  }

  String _generateToken(String userId, String role, String email) {
    final jwt = JWT({
      'userId': userId,
      'role': role,
      'email': email,
    });
    return jwt.sign(
      SecretKey(Env.jwtSecret),
      expiresIn: Duration(seconds: Env.jwtExpiry),
    );
  }

  String _generateRefreshToken(String userId) {
    final jwt = JWT({
      'userId': userId,
      'type': 'refresh',
    });
    return jwt.sign(
      SecretKey(Env.jwtSecret),
      expiresIn: Duration(seconds: Env.refreshTokenExpiry),
    );
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
  }) async {
    // Check if email already exists
    final existing = await _users.findOne(where.eq('email', email));
    if (existing != null) {
      throw Exception('Email already registered');
    }

    // Validate role
    if (role != 'student' && role != 'tutor') {
      throw Exception('Role must be "student" or "tutor"');
    }

    final hashedPassword = _hashPassword(password);

    final user = UserModel(
      email: email,
      password: hashedPassword,
      fullName: fullName,
      role: role,
      phone: phone,
      studentProfile: role == 'student' ? StudentProfile() : null,
      tutorProfile: role == 'tutor' ? TutorProfile() : null,
    );

    final result = await _users.insertOne(user.toMap());
    final userId = (result.id as ObjectId).oid;

    final accessToken = _generateToken(userId, role, email);
    final refreshToken = _generateRefreshToken(userId);

    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': UserModel.fromMap({...user.toMap(), '_id': result.id}).toPublicMap(),
    };
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final userDoc = await _users.findOne(where.eq('email', email));
    if (userDoc == null) {
      throw Exception('Invalid email or password');
    }

    final user = UserModel.fromMap(userDoc);

    if (!_verifyPassword(password, user.password)) {
      throw Exception('Invalid email or password');
    }

    if (!user.isActive) {
      throw Exception('Account is deactivated');
    }

    final userId = (user.id as ObjectId).oid;
    final accessToken = _generateToken(userId, user.role, user.email);
    final refreshToken = _generateRefreshToken(userId);

    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toPublicMap(),
    };
  }

  /// Resets a user's password after verifying their email + registered phone.
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String phone,
    required String newPassword,
  }) async {
    if (newPassword.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    final userDoc = await _users.findOne(where.eq('email', email.trim()));
    // Generic message so we don't reveal which field was wrong.
    const mismatch = 'No account matches that email and phone number';
    if (userDoc == null) {
      throw Exception(mismatch);
    }

    final user = UserModel.fromMap(userDoc);
    final storedPhone = (user.phone ?? '').trim();
    if (storedPhone.isEmpty || storedPhone != phone.trim()) {
      throw Exception(mismatch);
    }

    await _users.updateOne(
      where.eq('_id', user.id),
      modify
          .set('password', _hashPassword(newPassword))
          .set('updatedAt', DateTime.now()),
    );

    return {'message': 'Password reset successful'};
  }

  Future<Map<String, dynamic>> refreshToken(String token) async {
    try {
      final jwt = JWT.verify(token, SecretKey(Env.jwtSecret));
      final payload = jwt.payload as Map<String, dynamic>;

      if (payload['type'] != 'refresh') {
        throw Exception('Invalid refresh token');
      }

      final userId = payload['userId'] as String;
      final userDoc = await _users.findOne(
        where.eq('_id', ObjectId.fromHexString(userId)),
      );

      if (userDoc == null) {
        throw Exception('User not found');
      }

      final user = UserModel.fromMap(userDoc);
      final accessToken = _generateToken(userId, user.role, user.email);
      final newRefreshToken = _generateRefreshToken(userId);

      return {
        'accessToken': accessToken,
        'refreshToken': newRefreshToken,
      };
    } on JWTExpiredException {
      throw Exception('Refresh token expired. Please login again.');
    }
  }
}
