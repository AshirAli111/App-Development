import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/chat_service.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/utils/image_utils.dart';
import 'student_chats_conversation_screen.dart';
import 'book_session_sheet.dart';

void showTutorProfilePopup(BuildContext context, Map data) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (_) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.45,
        maxChildSize: 0.90,
        builder: (_, controller) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.s20),
            child: ListView(
              controller: controller,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),

                Center(
                  child: Builder(
                    builder: (context) {
                      final avatar = profileImageProvider(data["image"]);
                      return CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.15),
                        backgroundImage: avatar,
                        child: avatar == null
                            ? Icon(
                                LucideIcons.user,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),

                Center(
                  child: Text(
                    data["name"],
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Center(
                  child: Text(
                    data["subject"],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      "${data["rating"]}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "• PKR ${data["price"]}/hr",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.s24),

                Text(
                  "About Tutor",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  (data["bio"] ?? '').toString().trim().isNotEmpty
                      ? data["bio"].toString()
                      : "No bio provided yet.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: AppSpacing.s24),

                OutlinedButton.icon(
                  onPressed: () => _bookSession(context, data),
                  icon: const Icon(LucideIcons.calendarPlus, size: 18),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  label: const Text("Book Session"),
                ),
                const SizedBox(height: AppSpacing.s12),

                ElevatedButton(
                  onPressed: () => _startChat(context, data),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Chat with Tutor"),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

/// Starts (or reuses) a chat with the tutor and opens the conversation.
Future<void> _startChat(BuildContext context, Map data) async {
  final auth = context.read<AuthProvider>();
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);

  final tutorId = (data["id"] ?? '').toString();
  if (tutorId.isEmpty) {
    messenger.showSnackBar(
      const SnackBar(content: Text('This tutor is unavailable for chat.')),
    );
    return;
  }

  // Close the popup first.
  navigator.pop();

  final chatService = ChatService(
    baseUrl: auth.baseUrl,
    token: auth.accessToken,
    userId: auth.userId,
  );

  final chat = await chatService.startChat(tutorId);
  final chatId = (chat?['_id'] ?? '').toString();

  if (chatId.isEmpty) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not start the chat. Try again.')),
    );
    return;
  }

  navigator.push(
    MaterialPageRoute(
      builder: (_) => StudentChatConversation(
        name: (data["name"] ?? 'Tutor').toString(),
        imageUrl: data["image"] as String?,
        chatId: chatId,
        baseUrl: auth.baseUrl,
        token: auth.accessToken,
        userId: auth.userId,
      ),
    ),
  );
}

/// Opens the booking sheet and confirms a session with the tutor.
Future<void> _bookSession(BuildContext context, Map data) async {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);

  final tutorId = (data["id"] ?? '').toString();
  if (tutorId.isEmpty) {
    messenger.showSnackBar(
      const SnackBar(content: Text('This tutor is unavailable for booking.')),
    );
    return;
  }

  final priceRaw = data["price"];
  final price = priceRaw is num
      ? priceRaw.toInt()
      : int.tryParse(priceRaw?.toString() ?? '') ?? 0;

  final booked = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BookSessionSheet(
      tutorId: tutorId,
      tutorName: (data["name"] ?? 'Tutor').toString(),
      subject: (data["subject"] ?? 'General').toString(),
      pricePerSession: price,
    ),
  );

  if (booked == true) {
    navigator.pop(); // close the profile popup
    messenger.showSnackBar(
      const SnackBar(content: Text('Session booked! See it in Learning History.')),
    );
  }
}
