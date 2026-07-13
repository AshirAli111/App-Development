import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/ai_assistant_service.dart';

/// ROLE TYPE
enum AiRole { student, tutor }

class AiChatScreen extends StatefulWidget {
  final AiRole role;

  const AiChatScreen({super.key, required this.role});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_AiMessage> _messages = [];

  bool _isTyping = false;

  String get _greeting => widget.role == AiRole.student
      ? "Hi 👋 I’m the NextStepLearning assistant. Ask me about finding tutors, booking classes, payments, or anything else."
      : "Hello 👋 I’m the NextStepLearning assistant. Ask me about your profile, payouts, scheduling, students, or anything else.";

  /// Per-user, per-role storage key so history survives leaving the screen.
  String _storageKey = '';

  @override
  void initState() {
    super.initState();
    _messages.add(_AiMessage(text: _greeting, isUser: false));
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final auth = context.read<AuthProvider>();
    _storageKey = 'ai_chat_${widget.role.name}_${auth.userId}';
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as List;
      final saved = decoded
          .map((m) => _AiMessage(
                text: m['text'] as String,
                isUser: m['isUser'] as bool,
              ))
          .toList();
      if (saved.isNotEmpty && mounted) {
        setState(() {
          _messages
            ..clear()
            ..addAll(saved);
        });
        _scrollToBottom();
      }
    } catch (_) {
      // Ignore corrupt history.
    }
  }

  Future<void> _persist() async {
    if (_storageKey.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(
      _messages.map((m) => {'text': m.text, 'isUser': m.isUser}).toList(),
    );
    await prefs.setString(_storageKey, data);
  }

  Future<void> _clearChat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear chat?'),
        content: const Text('This will delete this conversation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _messages
        ..clear()
        ..add(_AiMessage(text: _greeting, isUser: false));
    });
    if (_storageKey.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    }
  }

  // ------------------------------------------------------------------
  // SEND MESSAGE
  // ------------------------------------------------------------------
  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Snapshot the conversation (excluding the greeting) as history.
    final history = _messages
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.text,
            })
        .toList();

    setState(() {
      _messages.add(_AiMessage(text: text, isUser: true));
      _isTyping = true;
      _controller.clear();
    });
    _persist();

    _scrollToBottom();

    final auth = context.read<AuthProvider>();
    final service =
        AiAssistantService(baseUrl: auth.baseUrl, token: auth.accessToken);

    String aiReply;
    try {
      aiReply = await service.sendMessage(message: text, history: history);
    } catch (e) {
      aiReply =
          "Sorry, I couldn't reach the assistant just now. Please try again in a moment.";
    }

    if (!mounted) return;
    setState(() {
      _messages.add(_AiMessage(text: aiReply, isUser: false));
      _isTyping = false;
    });
    _persist();

    _scrollToBottom();
  }


  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ------------------------------------------------------------------
  // UI
  // ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.role == AiRole.student
              ? "AI Study Assistant"
              : "AI Teaching Assistant",
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Clear chat',
            icon: const Icon(LucideIcons.trash2),
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // CHAT MESSAGES
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _typingBubble(theme);
                }

                final msg = _messages[index];
                return _chatBubble(msg, theme);
              },
            ),
          ),

          // INPUT BAR
          _inputBar(theme),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // CHAT BUBBLE
  // ------------------------------------------------------------------
  Widget _chatBubble(_AiMessage msg, ThemeData theme) {
    final isUser = msg.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Text(
          msg.text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isUser ? Colors.white : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // TYPING INDICATOR
  // ------------------------------------------------------------------
  Widget _typingBubble(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 6,
              height: 6,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text("AI is typing..."),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // INPUT BAR
  // ------------------------------------------------------------------
  Widget _inputBar(ThemeData theme) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: .15),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Focus(
                onKeyEvent: (node, event) {
                  // Enter sends; Shift+Enter inserts a newline.
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter &&
                      !HardwareKeyboard.instance.isShiftPressed) {
                    _sendMessage();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: const InputDecoration(
                    hintText: "Ask AI anything...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.send),
              color: theme.colorScheme.primary,
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// MESSAGE MODEL (LOCAL)
// ----------------------------------------------------------------------
class _AiMessage {
  final String text;
  final bool isUser;

  _AiMessage({required this.text, required this.isUser});
}
