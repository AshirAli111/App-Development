import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/data/services/chat_service.dart';
import 'package:next_step_learning/routes/app_routes.dart';

class TutorChatsScreen extends StatefulWidget {
  final String baseUrl;
  final String token;
  final String userId;

  const TutorChatsScreen({
    super.key,
    this.baseUrl = 'http://localhost:8080',
    this.token = '',
    this.userId = '',
  });

  @override
  State<TutorChatsScreen> createState() => _TutorChatsScreenState();
}

class _TutorChatsScreenState extends State<TutorChatsScreen> {
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.cardColor,
        elevation: 0.6,
        centerTitle: true,
        title: Text("My Chats", style: theme.textTheme.titleLarge),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? Center(
                  child: Text(
                    'No conversations yet',
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: AppSpacing.s12),
                  itemCount: _chats.length,
                  itemBuilder: (context, i) {
                    final chat = _chats[i];
                    final otherUser =
                        chat['otherUser'] as Map<String, dynamic>? ?? {};
                    final name = otherUser['name'] ?? 'Unknown';
                    final profileImage = otherUser['profileImage'];
                    final lastMessage =
                        chat['lastMessage'] as Map<String, dynamic>?;
                    final unreadCount =
                        chat['unreadCount'] as Map<String, dynamic>? ?? {};
                    final unread = unreadCount[widget.userId] ?? 0;
                    final chatId = chat['_id'] ?? '';
                    final timestamp = lastMessage?['timestamp'];

                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.tutorChatConversation,
                          arguments: {
                            "name": name,
                            "imageUrl": profileImage,
                            "chatId": chatId,
                            "baseUrl": widget.baseUrl,
                            "token": widget.token,
                            "userId": widget.userId,
                          },
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
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.15),
                              backgroundImage: profileImage != null
                                  ? NetworkImage(profileImage)
                                  : null,
                              child: profileImage == null
                                  ? Icon(
                                      LucideIcons.user,
                                      color: theme.colorScheme.primary,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: AppSpacing.s12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: AppSpacing.s4),
                                  Text(
                                    lastMessage?['text'] ?? 'No messages yet',
                                    style: theme.textTheme.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatTime(timestamp),
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(height: AppSpacing.s8),
                                unread > 0
                                    ? Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          unread.toString(),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
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
