import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:next_step_learning/routes/app_routes.dart';
import 'package:next_step_learning/core/theme/spacing.dart';

class TutorChatConversation extends StatefulWidget {
  final String name;
  final String? imageUrl;

  const TutorChatConversation({super.key, required this.name, this.imageUrl});

  @override
  State<TutorChatConversation> createState() => _TutorChatConversationState();
}

class _TutorChatConversationState extends State<TutorChatConversation> {
  final TextEditingController messageCtrl = TextEditingController();

  List<Map<String, dynamic>> messages = [
    {"text": "Hello Sir!", "isMe": false, "time": "3:12 PM", "status": "seen"},
    {
      "text": "Did you finish the assignment?",
      "isMe": true,
      "time": "3:13 PM",
      "status": "delivered",
    },
    {
      "text": "Yes Sir, sending now!",
      "isMe": false,
      "time": "3:14 PM",
      "status": "sent",
    },
  ];

  Widget _statusIcon(BuildContext context, String status) {
    final theme = Theme.of(context);

    switch (status) {
      case "sent":
        return Icon(
          Icons.check,
          size: 18,
          color: theme.iconTheme.color?.withValues(alpha: 0.6),
        );
      case "delivered":
        return Icon(
          Icons.done_all,
          size: 18,
          color: theme.iconTheme.color?.withValues(alpha: 0.6),
        );
      case "seen":
        return Icon(Icons.done_all, size: 18, color: theme.colorScheme.primary);
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ---------------- APP BAR -----------------
      appBar: AppBar(
        elevation: 0.6,
        backgroundColor: theme.cardColor,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                widget.imageUrl ?? "https://i.pravatar.cc/150?img=10",
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Text(widget.name, style: theme.textTheme.titleMedium),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.phone),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.tutorVoiceCall,
                arguments: {"name": widget.name, "imageUrl": widget.imageUrl},
              );
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.video),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.tutorVideoCall,
                arguments: {"name": widget.name, "imageUrl": widget.imageUrl},
              );
            },
          ),
        ],
      ),

      // ---------------- BODY -----------------
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.s16),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final msg = messages[i];
                bool isMe = msg["isMe"];

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.s12,
                      horizontal: AppSpacing.s16,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? theme.colorScheme.primary : theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: .15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg["text"],
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isMe
                                ? Colors.white
                                : theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              msg["time"],
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isMe
                                    ? Colors.white70
                                    : theme.textTheme.bodySmall?.color
                                          ?.withValues(alpha: 0.6),
                              ),
                            ),
                            if (isMe)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: _statusIcon(context, msg["status"]),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ---------------- INPUT FIELD -----------------
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s8,
            ),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: .2),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.plusCircle),
                  onPressed: () {},
                ),

                Expanded(
                  child: TextField(
                    controller: messageCtrl,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      hintStyle: theme.textTheme.bodyMedium,
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),

                IconButton(
                  icon: Icon(
                    LucideIcons.send,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
