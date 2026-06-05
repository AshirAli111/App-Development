import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:next_step_learning/presentation/screens/student/student_chats_conversation_screen.dart';

import '../../../core/theme/spacing.dart';

class StudentMessagesScreen extends StatelessWidget {
  const StudentMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Text(
                "Messages",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),

            Expanded(child: _chatList(context)),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // CHAT LIST
  // ----------------------------------------------------------
  Widget _chatList(BuildContext context) {
    final chats = [
      {
        "name": "Ayesha",
        "message": "Don't forget tomorrow's class 😊",
        "time": "3:24 PM",
        "unread": 2,
        "online": true,
      },
      {
        "name": "Bilal",
        "message": "I uploaded your assignment.",
        "time": "1:02 PM",
        "unread": 0,
        "online": false,
      },
      {
        "name": "Sara",
        "message": "Check the biology notes when free.",
        "time": "Yesterday",
        "unread": 0,
        "online": true,
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      itemCount: chats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final chat = chats[i];
        final unread = chat["unread"] as int;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentChatConversation(
                  name: chat["name"].toString(),
                  imageUrl: null,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // AVATAR + ONLINE DOT
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.15),
                      child: Icon(
                        LucideIcons.user,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                    if (chat["online"] == true)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 14,
                          width: 14,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).cardColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: AppSpacing.s16),

                // NAME + LAST MESSAGE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat["name"].toString(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chat["message"].toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // TIME + UNREAD BADGE
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      chat["time"].toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),

                    if (unread > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          unread.toString(),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
