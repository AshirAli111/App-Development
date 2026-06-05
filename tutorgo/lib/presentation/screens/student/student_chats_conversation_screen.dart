import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:next_step_learning/presentation/screens/student/request_bottomsheet.dart';

import '../../../core/theme/spacing.dart';

class StudentChatConversation extends StatefulWidget {
  final String name;
  final String? imageUrl;

  const StudentChatConversation({super.key, required this.name, this.imageUrl});

  @override
  State<StudentChatConversation> createState() =>
      _StudentChatConversationState();
}

class _StudentChatConversationState extends State<StudentChatConversation> {
  final TextEditingController messageCtrl = TextEditingController();

  List<Map<String, dynamic>> messages = [
    {"text": "Hello Sir!", "isMe": true, "time": "3:12 PM", "status": "seen"},
    {
      "text": "How can I help you today?",
      "isMe": false,
      "time": "3:13 PM",
      "status": "delivered",
    },
  ];

  // ----------------------------------------------------------
  // STATUS CHECK
  // ----------------------------------------------------------
  Widget _statusIcon(String status) {
    switch (status) {
      case "sent":
        return Icon(Icons.check, size: 18, color: Theme.of(context).hintColor);
      case "delivered":
        return Icon(
          Icons.done_all,
          size: 18,
          color: Theme.of(context).hintColor,
        );
      case "seen":
        return Icon(
          Icons.done_all,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        );
      default:
        return const SizedBox();
    }
  }

  // ----------------------------------------------------------
  // ADD REQUEST BUBBLE TO CHAT
  // ----------------------------------------------------------
  void _addRequestBubble(Map<String, String> data) {
    setState(() {
      messages.add({
        "isRequest": true,
        "course": data["course"],
        "day": data["day"],
        "time": data["time"],
        "isMe": true,
        "timeStamp": "Now",
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0.6,
        backgroundColor: Theme.of(context).cardColor,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                widget.imageUrl ?? "https://i.pravatar.cc/150?img=10",
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Text(widget.name, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(LucideIcons.phone), onPressed: () {}),
          IconButton(icon: const Icon(LucideIcons.video), onPressed: () {}),
        ],
      ),

      body: Column(
        children: [
          // CHAT LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.s16),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final msg = messages[i];

                if (msg["isRequest"] == true) {
                  return _requestBubble(msg);
                }

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
                      color: isMe
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withValues(alpha: .15),
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
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: isMe
                                    ? Colors.white
                                    : Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              msg["time"],
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isMe
                                        ? Colors.white70
                                        : Theme.of(context).hintColor,
                                  ),
                            ),
                            if (isMe)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: _statusIcon(msg["status"]),
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

          // ------------------------------------------
          // INPUT AREA
          // ------------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: .2),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.plusCircle),
                  onPressed: () async {
                    final result = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (_) => const RequestBottomSheet(),
                    );

                    if (result != null) {
                      _addRequestBubble(result);
                    }
                  },
                ),

                Expanded(
                  child: TextField(
                    controller: messageCtrl,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      hintStyle: Theme.of(context).textTheme.bodyMedium,
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),

                IconButton(
                  icon: Icon(
                    LucideIcons.send,
                    color: Theme.of(context).colorScheme.primary,
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

  // ----------------------------------------------------------
  // REQUEST BUBBLE UI
  // ----------------------------------------------------------
  Widget _requestBubble(Map<String, dynamic> req) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 220,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.primary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Session Request",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Course: ${req['course']}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              "Day: ${req['day']}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              "Time: ${req['time']}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Text(
              "Status: Pending",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
