import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiService {
  static const _apiKey = "AIzaSyAjq1jQ5-0ZlomAcZ0nN38UyOjFJMRzwu8";

  // Get available models
  static Future<List<String>> listAvailableModels() async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1/models?key=$_apiKey",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data["models"] as List;

        final modelNames = models
            .map<String>((m) => m["name"] as String)
            .toList();
        debugPrint("Available models: $modelNames");

        return modelNames;
      } else {
        debugPrint("Failed to fetch models: ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching models: $e");
      return [];
    }
  }

  // Send message using available models
  static Future<String> sendMessage({
    required String message,
    required bool isStudent,
  }) async {
    // Use the models you actually have available
    final possibleModels = [
      "gemini-2.0-flash", // Most likely to work
      "gemini-2.0-flash-001", // Alternative
      "gemini-2.0-flash-lite", // Lite version
      "gemini-2.5-flash", // If you have access
      "gemini-2.5-flash-lite", // Lite version
      "gemini-2.5-pro", // Pro version if available
    ];

    String? lastError;

    for (final modelName in possibleModels) {
      try {
        // Remove 'models/' prefix if present
        final cleanModelName = modelName.replaceAll('models/', '');

        final url = Uri.parse(
          "https://generativelanguage.googleapis.com/v1/models/$cleanModelName:generateContent?key=$_apiKey",
        );

        final rolePrompt = isStudent
            ? "You are a helpful AI tutor for students. Explain concepts simply and clearly in 2-3 sentences. Be encouraging and educational."
            : "You are an AI assistant for teachers. Provide structured, professional teaching advice with practical examples.";

        final body = {
          "contents": [
            {
              "role": "user",
              "parts": [
                {"text": "$rolePrompt\n\nUser question: $message"},
              ],
            },
          ],
          "generationConfig": {
            "temperature": 0.7,
            "topP": 0.8,
            "topK": 40,
            "maxOutputTokens": 1024,
          },
          "safetySettings": [
            {
              "category": "HARM_CATEGORY_HARASSMENT",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE",
            },
            {
              "category": "HARM_CATEGORY_HATE_SPEECH",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE",
            },
            {
              "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE",
            },
            {
              "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE",
            },
          ],
        };

        debugPrint("Trying model: $cleanModelName");
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );

        debugPrint("Response status for $cleanModelName: ${response.statusCode}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // Debug: print full response structure
          debugPrint("Success response structure: ${data.keys.toList()}");

          if (data.containsKey("candidates") &&
              data["candidates"] is List &&
              data["candidates"].isNotEmpty) {
            final candidate = data["candidates"][0];
            if (candidate.containsKey("content") &&
                candidate["content"].containsKey("parts") &&
                candidate["content"]["parts"].isNotEmpty) {
              final text = candidate["content"]["parts"][0]["text"];
              debugPrint("✅ Success with model: $cleanModelName");
              return text;
            }
          }

          // Alternative structure check
          if (data.containsKey("text")) {
            debugPrint(
              "✅ Success (alternative structure) with model: $cleanModelName",
            );
            return data["text"];
          }

          debugPrint("Unexpected response structure: $data");
          lastError = "Unexpected response structure";
        } else {
          final errorBody = response.body;
          debugPrint(
            "❌ Error with $cleanModelName: ${response.statusCode} - $errorBody",
          );

          try {
            final errorData = jsonDecode(errorBody);
            lastError = errorData["error"]["message"] ?? "Unknown error";
          } catch (_) {
            lastError = "HTTP ${response.statusCode}: $errorBody";
          }
        }
      } catch (e) {
        lastError = "Exception with $modelName: $e";
        debugPrint(lastError);
      }

      // Small delay between attempts
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // If all models fail, provide helpful guidance
    return """
⚠️ I'm having trouble connecting to the AI service. 

Available models found:
• gemini-2.0-flash
• gemini-2.0-flash-001  
• gemini-2.0-flash-lite
• gemini-2.5-flash
• gemini-2.5-flash-lite
• gemini-2.5-pro

Please check:
1. Your API key permissions
2. Billing is enabled (some models require billing)
3. Try using 'gemini-2.0-flash' model specifically

Last error: ${lastError ?? "Unknown"}
""";
  }

  // Simple test function
  static Future<bool> testConnection() async {
    try {
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=$_apiKey",
      );

      final body = {
        "contents": [
          {
            "parts": [
              {"text": "Hello, respond with just 'OK' if you can hear me."},
            ],
          },
        ],
        "generationConfig": {"maxOutputTokens": 10},
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("Test connection status: ${response.statusCode}");
      debugPrint("Test response: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Test connection error: $e");
      return false;
    }
  }
}
