import 'package:flutter/material.dart';
import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/routes/app_routes.dart';

class TutorChatsScreen extends StatelessWidget {
  const TutorChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final chats = [
      {
        "name": "Ayesha",
        "message": "Sir I completed the assignment.",
        "time": "3:45 PM",
        "unread": 2,
        "image": "https://i.pravatar.cc/150?img=1",
      },
      {
        "name": "Bilal",
        "message": "Thank you Sir!",
        "time": "1:12 PM",
        "unread": 0,
        "image": "https://i.pravatar.cc/150?img=5",
      },
      {
        "name": "Sara",
        "message": "Can we reschedule today's session?",
        "time": "11:01 AM",
        "unread": 1,
        "image": "https://i.pravatar.cc/150?img=3",
      },
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // HEADER
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.cardColor,
        elevation: 0.6,
        centerTitle: true,
        title: Text("My Chats", style: theme.textTheme.titleLarge),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.only(top: AppSpacing.s12),
        itemCount: chats.length,
        itemBuilder: (context, i) {
          final chat = chats[i];

          return InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.tutorChatConversation,
                arguments: {"name": chat["name"], "imageUrl": chat["image"]},
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s12,
              ),
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s12,
                vertical: AppSpacing.s4,
              ),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: .15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(chat["image"] as String),
                  ),

                  const SizedBox(width: AppSpacing.s12),

                  // NAME + MESSAGE
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat["name"] as String,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          chat["message"] as String,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: AppSpacing.s12),

                  // TIME + UNREAD BADGE
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        chat["time"] as String,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.s8),

                      chat["unread"] != 0
                          ? Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                chat["unread"].toString(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
