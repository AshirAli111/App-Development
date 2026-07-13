import 'dart:convert';
import 'dart:io';

import '../config/env.dart';

/// Calls Google Gemini (`generateContent`) to produce the NextStepLearning
/// assistant's reply.
///
/// The system prompt is built server-side so the API key never leaves the
/// backend and the assistant's behaviour stays consistent across clients. Using
/// Gemini (a hosted API) means the assistant works wherever the backend is
/// deployed, not only on a local machine.
class AiAssistantService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Max prior turns kept for context (keeps token use predictable).
  static const int _maxHistory = 12;

  Future<String> reply({
    required String role,
    required String message,
    List<Map<String, dynamic>> history = const [],
    String userContext = '',
  }) async {
    if (Env.geminiApiKey.isEmpty) {
      throw Exception('AI assistant is not configured (missing API key)');
    }

    var system = _systemPrompt(role);
    if (userContext.isNotEmpty) {
      system = '$system\n\nABOUT THE CURRENT USER (use this to answer '
          'questions about their account, students, tutors, or schedule; '
          'do not invent anything beyond it):\n$userContext';
    }

    // Build Gemini `contents`. Gemini uses the role name "model" for the
    // assistant's turns; the incoming history uses "assistant".
    final contents = <Map<String, dynamic>>[];
    final trimmed = history.length > _maxHistory
        ? history.sublist(history.length - _maxHistory)
        : history;
    for (final m in trimmed) {
      final r = m['role']?.toString();
      final c = m['content']?.toString();
      if ((r == 'user' || r == 'assistant') && c != null && c.isNotEmpty) {
        contents.add({
          'role': r == 'assistant' ? 'model' : 'user',
          'parts': [
            {'text': c}
          ],
        });
      }
    }
    contents.add({
      'role': 'user',
      'parts': [
        {'text': message}
      ],
    });

    final payload = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': system}
        ],
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.3,
        'maxOutputTokens': 500,
      },
    });

    final endpoint = Uri.parse(
        '$_baseUrl/${Env.geminiModel}:generateContent');

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    try {
      final request = await client.postUrl(endpoint);
      request.headers.contentType = ContentType.json;
      request.headers.set('x-goog-api-key', Env.geminiApiKey);
      request.add(utf8.encode(payload));

      final response = await request.close();
      // Buffer the whole body before decoding: streaming through utf8.decoder
      // throws when a multi-byte character is split across chunks.
      final bytes =
          await response.fold<List<int>>(<int>[], (b, chunk) => b..addAll(chunk));
      final body = utf8.decode(bytes, allowMalformed: true);

      if (response.statusCode != 200) {
        String detail = 'HTTP ${response.statusCode}';
        try {
          final err = jsonDecode(body);
          detail = err['error']?['message']?.toString() ?? detail;
        } catch (_) {}
        throw Exception('AI service error: $detail');
      }

      final data = jsonDecode(body) as Map<String, dynamic>;
      final text = _extractText(data);
      if (text == null || text.isEmpty) {
        throw Exception('AI service returned an empty response');
      }
      return text;
    } finally {
      client.close(force: true);
    }
  }

  /// Pulls the reply text out of a Gemini `generateContent` response by
  /// concatenating every text part of the first candidate.
  String? _extractText(Map<String, dynamic> data) {
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return null;
    final first = candidates[0] as Map?;
    final content = first?['content'] as Map?;
    final parts = content?['parts'] as List?;
    if (parts == null || parts.isEmpty) return null;
    final buffer = StringBuffer();
    for (final p in parts) {
      final t = (p as Map?)?['text']?.toString();
      if (t != null) buffer.write(t);
    }
    final text = buffer.toString().trim();
    return text.isEmpty ? null : text;
  }

  String _systemPrompt(String role) {
    final now = DateTime.now();
    final roleWord = role == 'tutor' ? 'tutor' : 'student';

    return '''
You are the NextStepLearning assistant — the in-app AI helper for NextStepLearning,
an AI-powered online tutoring platform based in Pakistan that connects students with
tutors. All prices are in Pakistani Rupees (PKR).

CURRENT CONTEXT
- The person you are talking to is a $roleWord.
- Current date & time (Pakistan, server clock): ${now.toIso8601String()}.
- Platform country: Pakistan.

STYLE
- Be precise and to the point. Prefer 1-4 short sentences or a tight bullet list.
- No filler, no repetition, no long preambles. Answer first, then a brief how-to if useful.
- Use plain, friendly language. Only use headings/bullets when they aid clarity.

WHAT YOU HELP WITH
1. Onboarding & Navigation — getting started and finding screens (Home, Discover/Courses,
   Chats, Schedule, Profile/Settings).
2. Teacher Discovery & Matching — students find tutors by course/subject; tutors show
   subjects, experience, rating, and an hourly rate in PKR.
3. Registration & Enrollment — sign up with email + password, pick a role (student/tutor),
   then complete the profile (courses/subjects, phone, etc.).
4. Booking & Scheduling — book one-off or recurring sessions; class reminders are sent
   before sessions.
5. Account & Billing Support — students pay NextStepLearning via EasyPaisa, JazzCash, or
   Bank Transfer and enter the amount to send; tutors add a payout account (a Pakistani
   bank or EasyPaisa/JazzCash) to receive earnings. Forgot password is verified with the
   account's email + phone number (no code is emailed).
6. Role-Aware Behavior — answer for the current role ($roleWord). Do not give tutor-only
   steps to a student or vice versa.
7. Escalation to Human Support — for account-specific problems you cannot resolve
   (payments not received, suspected fraud, blocked account, bugs), tell the user to open
   Help Center or Contact Support in the app. Do not invent case numbers.
8. Trust & Safety Guardrails — NEVER ask for or accept passwords, OTPs, full card numbers,
   card PINs, or CNIC. Never invent tutor names, ratings, prices, or availability — if you
   don't know a specific value, say so and point them to the relevant screen. Decline
   harmful, illegal, or clearly off-topic-abusive requests.
9. Language & Privacy Rules — NEVER use abusive, insulting, or vulgar words in ANY
   language, including English and Roman Urdu/Hindi (e.g. beghairat, kutta, pagal,
   kamina, harami, bewakoof and similar insults). NEVER ask for, repeat, or share phone
   numbers — contact must stay inside the app. Messages you receive may contain words or
   numbers masked with "*"; that content was blurred by the platform's abuse filter —
   never try to guess, reconstruct, or repeat it. If the user is abusive, stay calm,
   don't mirror their language, and politely ask them to keep the chat respectful.

GENERAL QUESTIONS
- You may answer general questions (e.g. current time/date, what country the app serves,
  simple facts, math). For the current time/date, use the CURRENT CONTEXT above.
- If a question needs live data you don't have (e.g. today's weather, live exchange rates),
  say you don't have that and, if relevant, suggest where to check.

If a request is outside the app and not a reasonable general question, gently steer back to
how you can help with NextStepLearning.''';
  }
}
