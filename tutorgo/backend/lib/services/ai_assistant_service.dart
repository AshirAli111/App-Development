import 'dart:convert';
import 'dart:io';

import '../config/env.dart';

/// Calls OpenRouter (Llama) to produce the NextStepLearning assistant's reply.
///
/// The system prompt is built server-side so the API key never leaves the
/// backend and the assistant's behaviour stays consistent across clients.
class AiAssistantService {
  static final Uri _endpoint =
      Uri.parse('https://openrouter.ai/api/v1/chat/completions');

  /// Max prior turns kept for context (keeps token use predictable).
  static const int _maxHistory = 12;

  Future<String> reply({
    required String role,
    required String message,
    List<Map<String, dynamic>> history = const [],
    String userContext = '',
  }) async {
    if (Env.openRouterApiKey.isEmpty) {
      throw Exception('AI assistant is not configured (missing API key)');
    }

    var system = _systemPrompt(role);
    if (userContext.isNotEmpty) {
      system = '$system\n\nABOUT THE CURRENT USER (use this to answer '
          'questions about their account, students, tutors, or schedule; '
          'do not invent anything beyond it):\n$userContext';
    }

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': system},
    ];

    // Append recent history (already in {role, content} form).
    final trimmed = history.length > _maxHistory
        ? history.sublist(history.length - _maxHistory)
        : history;
    for (final m in trimmed) {
      final r = m['role']?.toString();
      final c = m['content']?.toString();
      if ((r == 'user' || r == 'assistant') && c != null && c.isNotEmpty) {
        messages.add({'role': r!, 'content': c});
      }
    }
    messages.add({'role': 'user', 'content': message});

    final payload = jsonEncode({
      'model': Env.openRouterModel,
      'messages': messages,
      'temperature': 0.3,
      'max_tokens': 500,
    });

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    try {
      final request = await client.postUrl(_endpoint);
      request.headers.set(HttpHeaders.authorizationHeader,
          'Bearer ${Env.openRouterApiKey}');
      request.headers.contentType = ContentType.json;
      // OpenRouter attribution headers (optional but recommended).
      request.headers.set('HTTP-Referer', 'https://nextsteplearning.app');
      request.headers.set('X-Title', 'NextStepLearning');
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
      final choices = data['choices'] as List?;
      String? text;
      if (choices != null && choices.isNotEmpty) {
        final message = choices[0]['message'] as Map?;
        text = message?['content']?.toString().trim();
      }
      if (text == null || text.isEmpty) {
        throw Exception('AI service returned an empty response');
      }
      return text;
    } finally {
      client.close(force: true);
    }
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
- Be precise and to the point. Prefer 1–4 short sentences or a tight bullet list.
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

GENERAL QUESTIONS
- You may answer general questions (e.g. current time/date, what country the app serves,
  simple facts, math). For the current time/date, use the CURRENT CONTEXT above.
- If a question needs live data you don't have (e.g. today's weather, live exchange rates),
  say you don't have that and, if relevant, suggest where to check.

If a request is outside the app and not a reasonable general question, gently steer back to
how you can help with NextStepLearning.''';
  }
}
