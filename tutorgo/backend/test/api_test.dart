import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';

/// Integration tests for TutorGo Backend API
///
/// Prerequisites: Server must be running on localhost:8080
/// Start server: dart run bin/server.dart
/// Run tests:    dart test test/api_test.dart

const baseUrl = 'http://localhost:8080';
final client = HttpClient();

Future<Map<String, dynamic>> request(
  String method,
  String path, {
  Map<String, dynamic>? body,
  String? token,
}) async {
  final uri = Uri.parse('$baseUrl$path');
  late HttpClientRequest req;

  switch (method) {
    case 'GET':
      req = await client.getUrl(uri);
      break;
    case 'POST':
      req = await client.postUrl(uri);
      break;
    case 'PUT':
      req = await client.putUrl(uri);
      break;
    case 'DELETE':
      req = await client.deleteUrl(uri);
      break;
    default:
      throw Exception('Unsupported method: $method');
  }

  req.headers.set('Content-Type', 'application/json');
  if (token != null) {
    req.headers.set('Authorization', 'Bearer $token');
  }
  if (body != null) {
    req.write(jsonEncode(body));
  }

  final response = await req.close();
  final responseBody = await response.transform(utf8.decoder).join();

  return {
    'statusCode': response.statusCode,
    'body': responseBody.isNotEmpty ? jsonDecode(responseBody) : null,
  };
}

void main() {
  late String studentToken;
  late String tutorToken;
  late String studentId;
  late String tutorId;

  final testStudentEmail = 'test_student_${DateTime.now().millisecondsSinceEpoch}@test.com';
  final testTutorEmail = 'test_tutor_${DateTime.now().millisecondsSinceEpoch}@test.com';

  group('Health Check', () {
    test('GET /health returns 200', () async {
      final res = await request('GET', '/health');
      expect(res['statusCode'], 200);
      expect(res['body']['status'], 'ok');
    });
  });

  group('Auth - Register', () {
    test('registers a student successfully', () async {
      final res = await request('POST', '/auth/register', body: {
        'email': testStudentEmail,
        'password': 'testpass123',
        'fullName': 'Test Student',
        'role': 'student',
        'phone': '03001111111',
      });

      expect(res['statusCode'], 201);
      expect(res['body']['accessToken'], isNotEmpty);
      expect(res['body']['refreshToken'], isNotEmpty);
      expect(res['body']['user']['role'], 'student');
      expect(res['body']['user']['email'], testStudentEmail);
      expect(res['body']['user']['studentProfile'], isNotNull);

      studentToken = res['body']['accessToken'];
      studentId = res['body']['user']['id'];
    });

    test('registers a tutor successfully', () async {
      final res = await request('POST', '/auth/register', body: {
        'email': testTutorEmail,
        'password': 'testpass123',
        'fullName': 'Test Tutor',
        'role': 'tutor',
        'phone': '03002222222',
      });

      expect(res['statusCode'], 201);
      expect(res['body']['user']['role'], 'tutor');
      expect(res['body']['user']['tutorProfile'], isNotNull);

      tutorToken = res['body']['accessToken'];
      tutorId = res['body']['user']['id'];
    });

    test('rejects duplicate email', () async {
      final res = await request('POST', '/auth/register', body: {
        'email': testStudentEmail,
        'password': 'testpass123',
        'fullName': 'Duplicate',
        'role': 'student',
      });

      expect(res['statusCode'], 400);
      expect(res['body']['error'], contains('already registered'));
    });

    test('rejects missing required fields', () async {
      final res = await request('POST', '/auth/register', body: {
        'email': 'incomplete@test.com',
      });

      expect(res['statusCode'], 400);
      expect(res['body']['error'], isNotEmpty);
    });

    test('rejects invalid role', () async {
      final res = await request('POST', '/auth/register', body: {
        'email': 'bad_role@test.com',
        'password': 'testpass123',
        'fullName': 'Bad Role',
        'role': 'admin',
      });

      expect(res['statusCode'], 400);
      expect(res['body']['error'], contains('Role'));
    });

    test('rejects short password', () async {
      final res = await request('POST', '/auth/register', body: {
        'email': 'short_pass@test.com',
        'password': '12345',
        'fullName': 'Short Pass',
        'role': 'student',
      });

      expect(res['statusCode'], 400);
      expect(res['body']['error'], contains('6 characters'));
    });
  });

  group('Auth - Login', () {
    test('logs in with correct credentials', () async {
      final res = await request('POST', '/auth/login', body: {
        'email': testStudentEmail,
        'password': 'testpass123',
      });

      expect(res['statusCode'], 200);
      expect(res['body']['accessToken'], isNotEmpty);
      expect(res['body']['refreshToken'], isNotEmpty);
      expect(res['body']['user']['email'], testStudentEmail);
    });

    test('rejects wrong password', () async {
      final res = await request('POST', '/auth/login', body: {
        'email': testStudentEmail,
        'password': 'wrongpassword',
      });

      expect(res['statusCode'], 401);
      expect(res['body']['error'], contains('Invalid'));
    });

    test('rejects non-existent email', () async {
      final res = await request('POST', '/auth/login', body: {
        'email': 'nonexistent@test.com',
        'password': 'testpass123',
      });

      expect(res['statusCode'], 401);
      expect(res['body']['error'], contains('Invalid'));
    });
  });

  group('Auth - Refresh Token', () {
    test('issues new tokens with valid refresh token', () async {
      // First login to get refresh token
      final loginRes = await request('POST', '/auth/login', body: {
        'email': testStudentEmail,
        'password': 'testpass123',
      });

      final refreshToken = loginRes['body']['refreshToken'];

      final res = await request('POST', '/auth/refresh', body: {
        'refreshToken': refreshToken,
      });

      expect(res['statusCode'], 200);
      expect(res['body']['accessToken'], isNotEmpty);
      expect(res['body']['refreshToken'], isNotEmpty);
    });

    test('rejects invalid refresh token', () async {
      final res = await request('POST', '/auth/refresh', body: {
        'refreshToken': 'invalid.token.here',
      });

      expect(res['statusCode'], 401);
    });
  });

  group('Users - Protected Routes', () {
    test('GET /api/users/me returns user profile', () async {
      final res = await request('GET', '/api/users/me', token: studentToken);

      expect(res['statusCode'], 200);
      expect(res['body']['email'], testStudentEmail);
      expect(res['body']['role'], 'student');
    });

    test('GET /api/users/me rejects without token', () async {
      final res = await request('GET', '/api/users/me');

      expect(res['statusCode'], 401);
      expect(res['body']['error'], contains('authorization'));
    });

    test('GET /api/users/me rejects invalid token', () async {
      final res = await request('GET', '/api/users/me', token: 'bad.token');

      expect(res['statusCode'], 401);
    });

    test('GET /api/users/tutors returns tutor list', () async {
      final res = await request('GET', '/api/users/tutors', token: studentToken);

      expect(res['statusCode'], 200);
      expect(res['body']['tutors'], isList);
    });

    test('PUT /api/users/me updates profile', () async {
      final res = await request('PUT', '/api/users/me', token: studentToken, body: {
        'fullName': 'Updated Student Name',
        'studentProfile': {
          'age': 20,
          'grade': '10th',
          'selectedCourses': ['Mathematics', 'Science'],
        },
      });

      expect(res['statusCode'], 200);
    });
  });

  group('Chats', () {
    late String chatId;

    test('GET /api/chats/ returns empty chat list', () async {
      final res = await request('GET', '/api/chats/', token: studentToken);

      expect(res['statusCode'], 200);
      expect(res['body']['chats'], isList);
    });

    test('POST /api/chats/start creates a new chat', () async {
      final res = await request('POST', '/api/chats/start', token: studentToken, body: {
        'otherUserId': tutorId,
      });

      expect(res['statusCode'], 201);
      expect(res['body']['chat'], isNotNull);
      expect(res['body']['chat']['participants'], isList);
      expect(res['body']['chat']['otherUser'], isNotNull);
      expect(res['body']['chat']['otherUser']['name'], isNotNull);

      chatId = res['body']['chat']['_id'];
    });

    test('POST /api/chats/start returns existing chat if already exists', () async {
      final res = await request('POST', '/api/chats/start', token: studentToken, body: {
        'otherUserId': tutorId,
      });

      expect(res['statusCode'], 201);
      expect(res['body']['chat']['_id'], chatId);
    });

    test('POST /api/chats/start rejects missing otherUserId', () async {
      final res = await request('POST', '/api/chats/start', token: studentToken, body: {});

      expect(res['statusCode'], 400);
      expect(res['body']['error'], contains('otherUserId'));
    });

    test('POST /api/chats/start rejects chat with self', () async {
      final res = await request('POST', '/api/chats/start', token: studentToken, body: {
        'otherUserId': studentId,
      });

      expect(res['statusCode'], 400);
      expect(res['body']['error'], contains('yourself'));
    });

    test('POST /api/chats/:id/messages sends a text message', () async {
      final res = await request('POST', '/api/chats/$chatId/messages', token: studentToken, body: {
        'text': 'Hello from student!',
      });

      expect(res['statusCode'], 201);
      expect(res['body']['text'], 'Hello from student!');
      expect(res['body']['type'], 'text');
    });

    test('GET /api/chats/:id/messages returns messages', () async {
      final res = await request('GET', '/api/chats/$chatId/messages', token: studentToken);

      expect(res['statusCode'], 200);
      expect(res['body']['messages'], isList);
      expect(res['body']['messages'].length, greaterThan(0));
    });

    test('POST /api/chats/:id/messages sends call_invite', () async {
      final res = await request('POST', '/api/chats/$chatId/messages', token: studentToken, body: {
        'text': 'tutorgo_${chatId}_12345',
        'type': 'call_invite',
      });

      expect(res['statusCode'], 201);
      expect(res['body']['type'], 'call_invite');
      expect(res['body']['text'], contains('tutorgo_'));
    });

    test('GET /api/chats/:id/active-call returns active call', () async {
      final res = await request('GET', '/api/chats/$chatId/active-call', token: studentToken);

      expect(res['statusCode'], 200);
      expect(res['body']['activeCall'], isNotNull);
      expect(res['body']['activeCall']['type'], 'call_invite');
    });

    test('POST call_ended clears active call', () async {
      await request('POST', '/api/chats/$chatId/messages', token: studentToken, body: {
        'text': 'Call ended',
        'type': 'call_ended',
      });

      final res = await request('GET', '/api/chats/$chatId/active-call', token: studentToken);

      expect(res['statusCode'], 200);
      expect(res['body']['activeCall'], isNull);
    });

    test('PUT /api/chats/:id/read marks chat as read', () async {
      final res = await request('PUT', '/api/chats/$chatId/read', token: studentToken);

      expect(res['statusCode'], 200);
      expect(res['body']['message'], 'Marked as read');
    });

    test('GET /api/chats/ returns chat with otherUser info', () async {
      final res = await request('GET', '/api/chats/', token: studentToken);

      expect(res['statusCode'], 200);
      final chats = res['body']['chats'] as List;
      expect(chats.length, greaterThan(0));
      expect(chats.first['otherUser'], isNotNull);
      expect(chats.first['otherUser']['name'], isNotNull);
    });
  });

  group('Sessions', () {
    test('GET /api/sessions/ returns empty sessions', () async {
      final res = await request('GET', '/api/sessions/', token: studentToken);

      expect(res['statusCode'], 200);
      expect(res['body']['sessions'], isList);
    });
  });

  group('Notifications', () {
    test('GET /api/notifications/ returns empty list', () async {
      final res = await request('GET', '/api/notifications/', token: studentToken);

      expect(res['statusCode'], 200);
      expect(res['body']['notifications'], isList);
    });

    test('PUT /api/notifications/read-all succeeds', () async {
      final res = await request('PUT', '/api/notifications/read-all', token: studentToken);

      expect(res['statusCode'], 200);
    });
  });

  group('Payments', () {
    test('GET /api/payments/ returns empty list', () async {
      final res = await request('GET', '/api/payments/', token: studentToken);

      expect(res['statusCode'], 200);
      expect(res['body']['payments'], isList);
    });

    test('GET /api/payments/summary returns summary', () async {
      final res = await request('GET', '/api/payments/summary', token: studentToken);

      expect(res['statusCode'], 200);
      expect(res['body']['totalPKR'], 0);
      expect(res['body']['pendingPKR'], 0);
      expect(res['body']['completedPKR'], 0);
    });

    test('POST /api/payments/ creates mock payment', () async {
      final res = await request('POST', '/api/payments/', token: studentToken, body: {
        'studentId': studentId,
        'tutorId': tutorId,
        'amountPKR': 1500,
        'method': 'easypaisa',
      });

      expect(res['statusCode'], 201);
      expect(res['body']['amountPKR'], 1500);
      expect(res['body']['method'], 'easypaisa');
      expect(res['body']['status'], 'pending');
    });

    test('rejects invalid payment method', () async {
      final res = await request('POST', '/api/payments/', token: studentToken, body: {
        'studentId': studentId,
        'tutorId': tutorId,
        'amountPKR': 1000,
        'method': 'bitcoin',
      });

      expect(res['statusCode'], 400);
      expect(res['body']['error'], contains('method'));
    });
  });

  group('AI Conversations', () {
    late String conversationId;

    test('POST /api/ai/conversations creates conversation', () async {
      final res = await request('POST', '/api/ai/conversations', token: studentToken, body: {
        'message': 'Help me understand quadratic equations',
      });

      expect(res['statusCode'], 201);
      expect(res['body']['role'], 'student');
      expect(res['body']['messages'], isList);
      expect(res['body']['messages'].length, 1);

      conversationId = res['body']['_id'];
    });

    test('GET /api/ai/conversations lists conversations', () async {
      final res = await request('GET', '/api/ai/conversations', token: studentToken);

      expect(res['statusCode'], 200);
      expect(res['body']['conversations'], isList);
      expect(res['body']['conversations'].length, greaterThan(0));
    });

    test('POST /api/ai/conversations/:id/message adds message', () async {
      final res = await request(
        'POST',
        '/api/ai/conversations/$conversationId/message',
        token: studentToken,
        body: {'text': 'AI response here', 'isUser': false},
      );

      expect(res['statusCode'], 200);
      expect(res['body']['messages'].length, 2);
    });

    test('DELETE /api/ai/conversations/:id deletes', () async {
      final res = await request(
        'DELETE',
        '/api/ai/conversations/$conversationId',
        token: studentToken,
      );

      expect(res['statusCode'], 200);
    });
  });

  group('Mock Stripe Payment Gateway', () {
    late String stripeSessionId;

    test('POST /api/stripe/create-checkout-session creates session', () async {
      final res = await request(
        'POST',
        '/api/stripe/create-checkout-session',
        token: studentToken,
        body: {
          'studentId': studentId,
          'tutorId': tutorId,
          'amountPKR': 2000,
        },
      );

      expect(res['statusCode'], 201);
      expect(res['body']['sessionId'], startsWith('cs_mock_'));
      expect(res['body']['checkoutUrl'], contains('/api/stripe/checkout/'));
      expect(res['body']['amountPKR'], 2000);
      expect(res['body']['status'], 'pending');

      stripeSessionId = res['body']['sessionId'];
    });

    test('rejects missing required fields', () async {
      final res = await request(
        'POST',
        '/api/stripe/create-checkout-session',
        token: studentToken,
        body: {
          'studentId': studentId,
        },
      );

      expect(res['statusCode'], 400);
      expect(res['body']['error'], contains('required'));
    });

    test('rejects zero amount', () async {
      final res = await request(
        'POST',
        '/api/stripe/create-checkout-session',
        token: studentToken,
        body: {
          'studentId': studentId,
          'tutorId': tutorId,
          'amountPKR': 0,
        },
      );

      expect(res['statusCode'], 400);
      expect(res['body']['error'], contains('greater than 0'));
    });

    test('GET /api/stripe/checkout/:sessionId returns HTML page', () async {
      final uri = Uri.parse('$baseUrl/api/stripe/checkout/$stripeSessionId');
      final req = await client.getUrl(uri);
      req.headers.set('Authorization', 'Bearer $studentToken');
      final response = await req.close();
      final body = await response.transform(utf8.decoder).join();

      expect(response.statusCode, 200);
      expect(response.headers.contentType.toString(), contains('text/html'));
      expect(body, contains('TutorGo Pay'));
      expect(body, contains('PKR 2000'));
    });

    test('GET /api/stripe/session/:sessionId returns pending status', () async {
      final res = await request(
        'GET',
        '/api/stripe/session/$stripeSessionId',
        token: studentToken,
      );

      expect(res['statusCode'], 200);
      expect(res['body']['sessionId'], stripeSessionId);
      expect(res['body']['status'], 'pending');
      expect(res['body']['amountPKR'], 2000);
    });

    test('POST /api/stripe/confirm/:sessionId completes payment', () async {
      final uri = Uri.parse('$baseUrl/api/stripe/confirm/$stripeSessionId');
      final req = await client.postUrl(uri);
      req.headers.set('Authorization', 'Bearer $studentToken');
      final response = await req.close();
      final body = await response.transform(utf8.decoder).join();

      expect(response.statusCode, 200);
      expect(body, contains('Payment Successful'));
    });

    test('GET /api/stripe/session/:sessionId returns completed after confirm', () async {
      final res = await request(
        'GET',
        '/api/stripe/session/$stripeSessionId',
        token: studentToken,
      );

      expect(res['statusCode'], 200);
      expect(res['body']['status'], 'completed');
      expect(res['body']['completedAt'], isNotNull);
    });

    test('GET /api/stripe/checkout/:sessionId shows success for completed session', () async {
      final uri = Uri.parse('$baseUrl/api/stripe/checkout/$stripeSessionId');
      final req = await client.getUrl(uri);
      req.headers.set('Authorization', 'Bearer $studentToken');
      final response = await req.close();
      final body = await response.transform(utf8.decoder).join();

      expect(response.statusCode, 200);
      expect(body, contains('Payment Successful'));
    });

    test('returns 404 for non-existent session', () async {
      final res = await request(
        'GET',
        '/api/stripe/session/cs_mock_nonexistent',
        token: studentToken,
      );

      expect(res['statusCode'], 404);
    });

    test('stripe payment appears in payment history', () async {
      final res = await request('GET', '/api/payments/', token: studentToken);

      expect(res['statusCode'], 200);
      final payments = res['body']['payments'] as List;
      final stripePayment = payments.firstWhere(
        (p) => p['method'] == 'stripe',
        orElse: () => null,
      );

      expect(stripePayment, isNotNull);
      expect(stripePayment['amountPKR'], 2000);
      expect(stripePayment['status'], 'completed');
      expect(stripePayment['stripeSessionId'], stripeSessionId);
    });
  });
}
