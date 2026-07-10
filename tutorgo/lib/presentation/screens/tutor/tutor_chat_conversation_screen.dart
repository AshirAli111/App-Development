import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:next_step_learning/data/services/chat_service.dart';
import 'package:next_step_learning/data/services/call_service.dart';
import 'package:next_step_learning/data/services/notification_poller.dart';
import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/core/utils/image_utils.dart';

class TutorChatConversation extends StatefulWidget {
  final String name;
  final String? imageUrl;
  final String chatId;
  final String baseUrl;
  final String token;
  final String userId;

  const TutorChatConversation({
    super.key,
    required this.name,
    this.imageUrl,
    this.chatId = '',
    this.baseUrl = 'http://localhost:8080',
    this.token = '',
    this.userId = '',
  });

  @override
  State<TutorChatConversation> createState() => _TutorChatConversationState();
}

class _TutorChatConversationState extends State<TutorChatConversation> {
  final TextEditingController messageCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final ChatService _chatService;
  late final CallService _callService;
  List<Map<String, dynamic>> _messages = [];
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
    _callService = CallService(
      chatService: _chatService,
      userName: widget.name,
    );
    _loadMessages();
    _chatService.markAsRead(widget.chatId);
    NotificationPoller.activeChatId = widget.chatId;
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _pollMessages());
  }

  @override
  void dispose() {
    if (NotificationPoller.activeChatId == widget.chatId) {
      NotificationPoller.activeChatId = null;
    }
    _pollTimer?.cancel();
    messageCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final messages = await _chatService.getMessages(widget.chatId);
    if (mounted) {
      setState(() {
        _messages = messages.reversed.toList();
        _loading = false;
      });
      _scrollToBottom();
      _checkForIncomingCall(messages);
    }
  }

  Future<void> _pollMessages() async {
    final messages = await _chatService.getMessages(widget.chatId);
    if (mounted && messages.length != _messages.length) {
      setState(() {
        _messages = messages.reversed.toList();
      });
      _scrollToBottom();
      _chatService.markAsRead(widget.chatId);
      _checkForIncomingCall(messages);
    }
  }

  void _checkForIncomingCall(List<Map<String, dynamic>> messages) {
    if (messages.isEmpty) return;
    final latest = messages.first;
    if (latest['type'] == 'call_invite' &&
        latest['senderId'] != widget.userId) {
      final createdAt = DateTime.tryParse(latest['createdAt'] ?? '');
      if (createdAt != null &&
          DateTime.now().difference(createdAt).inSeconds < 30) {
        _showIncomingCallDialog(latest['text'] ?? '');
      }
    }
  }

  void _showIncomingCallDialog(String roomName) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Incoming Call'),
        content: Text('${widget.name} is calling you...'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _callService.declineCall(widget.chatId);
            },
            child: const Text('Decline', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _callService.joinCall(roomName);
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = messageCtrl.text.trim();
    if (text.isEmpty) return;

    messageCtrl.clear();
    await _chatService.sendMessage(widget.chatId, text: text);
    await _loadMessages();
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '';
    final dt = DateTime.tryParse(isoTime);
    if (dt == null) return '';
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${dt.minute.toString().padLeft(2, '0')} $amPm';
  }

  Widget _statusIcon(BuildContext context, String status) {
    final theme = Theme.of(context);
    switch (status) {
      case "sent":
        return Icon(Icons.check, size: 18, color: theme.iconTheme.color?.withValues(alpha: 0.6));
      case "delivered":
        return Icon(Icons.done_all, size: 18, color: theme.iconTheme.color?.withValues(alpha: 0.6));
      case "seen":
        return Icon(Icons.done_all, size: 18, color: theme.colorScheme.primary);
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatar = profileImageProvider(widget.imageUrl);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0.6,
        backgroundColor: theme.cardColor,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
              backgroundImage: avatar,
              child: avatar == null
                  ? Icon(LucideIcons.user, color: theme.colorScheme.primary)
                  : null,
            ),
            const SizedBox(width: AppSpacing.s12),
            Text(widget.name, style: theme.textTheme.titleMedium),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.phone),
            onPressed: () => _callService.startVoiceCall(widget.chatId),
          ),
          IconButton(
            icon: const Icon(LucideIcons.video),
            onPressed: () => _callService.startVideoCall(widget.chatId),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) {
                      final msg = _messages[i];
                      return _buildMessageBubble(context, msg);
                    },
                  ),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, Map<String, dynamic> msg) {
    final theme = Theme.of(context);
    final type = msg['type'] ?? 'text';
    final isMe = msg['senderId'] == widget.userId;

    if (type == 'session_request') {
      return _requestBubble(context, msg, isMe);
    }

    if (type == 'call_invite' || type == 'call_ended' || type == 'call_declined') {
      return _callEventBubble(context, msg, type);
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
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
              msg['text'] ?? '',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isMe ? Colors.white : theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(msg['createdAt']),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isMe
                        ? Colors.white70
                        : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                  ),
                ),
                if (isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: _statusIcon(context, msg['status'] ?? 'sent'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _requestBubble(BuildContext context, Map<String, dynamic> msg, bool isMe) {
    final theme = Theme.of(context);
    final sessionReq = msg['sessionRequest'] as Map<String, dynamic>?;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 220,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.primary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Session Request",
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            if (sessionReq != null) ...[
              Text("Subject: ${sessionReq['subject'] ?? ''}",
                  style: theme.textTheme.bodyMedium),
              Text("Time: ${sessionReq['startTime'] ?? ''}",
                  style: theme.textTheme.bodyMedium),
            ] else
              Text(msg['text'] ?? '', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 10),
            Text(
              "Status: ${sessionReq?['status'] ?? 'pending'}",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _callEventBubble(BuildContext context, Map<String, dynamic> msg, String type) {
    final theme = Theme.of(context);
    IconData icon;
    String label;
    switch (type) {
      case 'call_invite':
        icon = LucideIcons.phone;
        label = 'Call started';
        break;
      case 'call_ended':
        icon = LucideIcons.phoneOff;
        label = 'Call ended';
        break;
      case 'call_declined':
        icon = LucideIcons.phoneMissed;
        label = 'Call declined';
        break;
      default:
        icon = LucideIcons.phone;
        label = '';
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: theme.hintColor),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            const SizedBox(width: 6),
            Text(
              _formatTime(msg['createdAt']),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(LucideIcons.send, color: theme.colorScheme.primary),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
