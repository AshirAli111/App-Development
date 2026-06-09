import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:next_step_learning/data/services/chat_service.dart';
import 'package:next_step_learning/presentation/screens/student/student_chats_conversation_screen.dart';

import '../../../core/theme/spacing.dart';

class StudentMessagesScreen extends StatefulWidget {
  final String baseUrl;
  final String token;
  final String userId;

  const StudentMessagesScreen({
    super.key,
    this.baseUrl = 'http://localhost:8080',
    this.token = '',
    this.userId = '',
  });

  @override
  State<StudentMessagesScreen> createState() => _StudentMessagesScreenState();
}

class _StudentMessagesScreenState extends State<StudentMessagesScreen> {
  late final ChatService _chatService;
  List<Map<String, dynamic>> _chats = [];
  bool _loading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(
      baseUrl: widget.baseUrl,
      token: widget.token,
      userId: widget.userId,
    );
    _loadChats();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _loadChats());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadChats() async {
    final chats = await _chatService.getChats();
    if (mounted) {
      setState(() {
        _chats = chats;
        _loading = false;
      });
    }
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '';
    final dt = DateTime.tryParse(isoTime);
    if (dt == null) return '';
    final now = DateTime.now();
    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:${dt.minute.toString().padLeft(2, '0')} $amPm';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Text(
                "Messages",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _chats.isEmpty
                      ? Center(
                          child: Text(
                            'No conversations yet',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : _chatList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      itemCount: _chats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final chat = _chats[i];
        final otherUser = chat['otherUser'] as Map<String, dynamic>? ?? {};
        final name = otherUser['name'] ?? 'Unknown';
        final lastMessage = chat['lastMessage'] as Map<String, dynamic>?;
        final unreadCount = chat['unreadCount'] as Map<String, dynamic>? ?? {};
        final unread = unreadCount[widget.userId] ?? 0;
        final chatId = chat['_id'] ?? '';
        final timestamp = lastMessage?['timestamp'];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentChatConversation(
                  name: name,
                  imageUrl: otherUser['profileImage'],
                  chatId: chatId,
                  baseUrl: widget.baseUrl,
                  token: widget.token,
                  userId: widget.userId,
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
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.15),
                  backgroundImage: otherUser['profileImage'] != null
                      ? NetworkImage(otherUser['profileImage'])
                      : null,
                  child: otherUser['profileImage'] == null
                      ? Icon(
                          LucideIcons.user,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastMessage?['text'] ?? 'No messages yet',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(timestamp),
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
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white),
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
