import 'package:next_step_learning/data/dummy/services/ai_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

  @override
  void initState() {
    super.initState();

    // Initial AI greeting
    _messages.add(
      _AiMessage(
        text: widget.role == AiRole.student
            ? "Hi 👋 I’m your AI study assistant. Ask me anything!"
            : "Hello 👋 I’m your AI teaching assistant. How can I help today?",
        isUser: false,
      ),
    );
    _checkAvailableModels();
  }

  void _checkAvailableModels() async {
    debugPrint("Checking available models...");
    final availableModels = await AiService.listAvailableModels();
    if (availableModels.isNotEmpty) {
      debugPrint("Found models: $availableModels");
    }
  }

  // ------------------------------------------------------------------
  // SEND MESSAGE
  // ------------------------------------------------------------------
  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_AiMessage(text: text, isUser: true));
      _isTyping = true;
      _controller.clear();
    });

    _scrollToBottom();

    // Fake AI delay (replace with real API later)
    await Future.delayed(const Duration(seconds: 1));

    // final aiReply = _generateAiReply(text);
    final aiReply = await AiService.sendMessage(
      message: text,
      isStudent: widget.role == AiRole.student,
    );

    setState(() {
      _messages.add(_AiMessage(text: aiReply, isUser: false));
      _isTyping = false;
    });

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
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Ask AI anything...",
                  border: InputBorder.none,
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
