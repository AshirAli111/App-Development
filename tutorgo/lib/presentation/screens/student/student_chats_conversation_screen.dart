import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:next_step_learning/core/utils/image_utils.dart';
import 'package:next_step_learning/data/services/chat_service.dart';
import 'package:next_step_learning/data/services/call_service.dart';
import 'package:next_step_learning/data/services/notification_poller.dart';
import 'package:next_step_learning/presentation/screens/student/request_bottomsheet.dart';

import '../../../core/theme/spacing.dart';

class StudentChatConversation extends StatefulWidget {
  final String name;
  final String? imageUrl;
  final String chatId;
  final String baseUrl;
  final String token;
  final String userId;

  const StudentChatConversation({
    super.key,
    required this.name,
    this.imageUrl,
    this.chatId = '',
    this.baseUrl = 'http://localhost:8080',
    this.token = '',
    this.userId = '',
  });

  @override
  State<StudentChatConversation> createState() =>
      _StudentChatConversationState();
}

class _StudentChatConversationState extends State<StudentChatConversation> {
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
        _messages = messages.reversed.toList(); // API returns newest first
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
    final latest = messages.first; // newest message
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

  Future<void> _sendSessionRequest(Map<String, String> data) async {
    await _chatService.sendMessage(
      widget.chatId,
      text: 'Session Request: ${data['course']} - ${data['day']} at ${data['time']}',
      type: 'session_request',
      sessionRequest: {
        'subject': data['course'] ?? '',
        'dayOfWeek': _dayToInt(data['day'] ?? ''),
        'startTime': data['time'] ?? '',
        'endTime': '',
        'pricePerSessionPKR': 0,
      },
    );
    await _loadMessages();
  }

  int _dayToInt(String day) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days.indexOf(day) + 1;
  }

  Widget _statusIcon(String status) {
    switch (status) {
      case "sent":
        return Icon(Icons.check, size: 18, color: Theme.of(context).hintColor);
      case "delivered":
        return Icon(Icons.done_all, size: 18, color: Theme.of(context).hintColor);
      case "seen":
        return Icon(Icons.done_all, size: 18, color: Theme.of(context).colorScheme.primary);
      default:
        return const SizedBox();
    }
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '';
    final dt = DateTime.tryParse(isoTime);
    if (dt == null) return '';
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${dt.minute.toString().padLeft(2, '0')} $amPm';
  }

  @override
  Widget build(BuildContext context) {
    final avatar = profileImageProvider(widget.imageUrl);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0.6,
        backgroundColor: Theme.of(context).cardColor,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              backgroundImage: avatar,
              child: avatar == null
                  ? Icon(LucideIcons.user,
                      color: Theme.of(context).colorScheme.primary)
                  : null,
            ),
            const SizedBox(width: AppSpacing.s12),
            Text(widget.name, style: Theme.of(context).textTheme.titleLarge),
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
                      return _buildMessageBubble(msg);
                    },
                  ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final type = msg['type'] ?? 'text';
    final isMe = msg['senderId'] == widget.userId;

    if (type == 'session_request') {
      return _requestBubble(msg, isMe);
    }

    if (type == 'call_invite' || type == 'call_ended' || type == 'call_declined') {
      return _callEventBubble(msg, type);
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
              msg['text'] ?? '',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isMe
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(msg['createdAt']),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isMe ? Colors.white70 : Theme.of(context).hintColor,
                      ),
                ),
                if (isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: _statusIcon(msg['status'] ?? 'sent'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _requestBubble(Map<String, dynamic> msg, bool isMe) {
    final sessionReq = msg['sessionRequest'] as Map<String, dynamic>?;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
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
            if (sessionReq != null) ...[
              Text("Subject: ${sessionReq['subject'] ?? ''}",
                  style: Theme.of(context).textTheme.bodyMedium),
              Text("Time: ${sessionReq['startTime'] ?? ''}",
                  style: Theme.of(context).textTheme.bodyMedium),
            ] else
              Text(msg['text'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),
            Text(
              "Status: ${sessionReq?['status'] ?? 'pending'}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _callEventBubble(Map<String, dynamic> msg, String type) {
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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Theme.of(context).hintColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            ),
            const SizedBox(width: 6),
            Text(
              _formatTime(msg['createdAt']),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
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
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => const RequestBottomSheet(),
              );
              if (result != null) {
                _sendSessionRequest(Map<String, String>.from(result));
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
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(
              LucideIcons.send,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
