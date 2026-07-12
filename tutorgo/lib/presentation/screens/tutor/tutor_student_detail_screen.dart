import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/core/theme/typography.dart';
import 'package:next_step_learning/core/utils/image_utils.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/assignment_service.dart';
import 'package:next_step_learning/data/services/call_service.dart';
import 'package:next_step_learning/data/services/chat_service.dart';
import 'package:next_step_learning/data/services/quiz_service.dart';
import 'package:next_step_learning/data/services/session_service.dart';
import 'package:next_step_learning/presentation/screens/tutor/create_assignment_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/create_quiz_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/tutor_chat_conversation_screen.dart';

class TutorStudentDetailScreen extends StatefulWidget {
  final String studentId;
  final String name;
  final String grade;
  final String? image;

  const TutorStudentDetailScreen({
    super.key,
    required this.studentId,
    required this.name,
    required this.grade,
    this.image,
  });

  @override
  State<TutorStudentDetailScreen> createState() =>
      _TutorStudentDetailScreenState();
}

class _TutorStudentDetailScreenState extends State<TutorStudentDetailScreen> {
  List<Map<String, dynamic>> _assignments = [];
  List<Map<String, dynamic>> _quizzes = [];
  List<Map<String, dynamic>> _sessions = [];
  bool _loading = true;

  AuthProvider get _auth => context.read<AuthProvider>();

  AssignmentService get _assignmentService => AssignmentService(
      baseUrl: _auth.baseUrl,
      token: _auth.accessToken,
      userId: _auth.userId,
      role: _auth.role);
  QuizService get _quizService => QuizService(
      baseUrl: _auth.baseUrl,
      token: _auth.accessToken,
      userId: _auth.userId,
      role: _auth.role);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sessionService = SessionService(
      baseUrl: _auth.baseUrl,
      token: _auth.accessToken,
      userId: _auth.userId,
      role: _auth.role,
    );
    final results = await Future.wait([
      _assignmentService.getAssignments(),
      _quizService.getQuizzes(),
      sessionService.getMySessions(),
    ]);
    if (!mounted) return;
    setState(() {
      _assignments = results[0]
          .where((a) => a['studentId'] == widget.studentId)
          .toList();
      _quizzes =
          results[1].where((q) => q['studentId'] == widget.studentId).toList();
      _sessions =
          results[2].where((s) => s['studentId'] == widget.studentId).toList();
      _loading = false;
    });
  }

  Future<String?> _ensureChat() async {
    final chatService = ChatService(
        baseUrl: _auth.baseUrl, token: _auth.accessToken, userId: _auth.userId);
    final chat = await chatService.startChat(widget.studentId);
    return (chat?['_id'] ?? '').toString();
  }

  Future<void> _openMessage() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final chatId = await _ensureChat();
    if (chatId == null || chatId.isEmpty) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Could not open chat')));
      return;
    }
    navigator.push(MaterialPageRoute(
      builder: (_) => TutorChatConversation(
        name: widget.name,
        imageUrl: widget.image,
        chatId: chatId,
        baseUrl: _auth.baseUrl,
        token: _auth.accessToken,
        userId: _auth.userId,
      ),
    ));
  }

  Future<void> _startCall({required bool video}) async {
    final messenger = ScaffoldMessenger.of(context);
    final chatId = await _ensureChat();
    if (chatId == null || chatId.isEmpty) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Could not start call')));
      return;
    }
    final callService = CallService(
      chatService: ChatService(
          baseUrl: _auth.baseUrl,
          token: _auth.accessToken,
          userId: _auth.userId),
      userName: widget.name,
    );
    video
        ? callService.startVideoCall(chatId)
        : callService.startVoiceCall(chatId);
  }

  Future<void> _createAssignment() async {
    final created = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => CreateAssignmentScreen(
          studentId: widget.studentId, studentName: widget.name),
    ));
    if (created == true) _load();
  }

  Future<void> _createQuiz() async {
    final created = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => CreateQuizScreen(
          studentId: widget.studentId, studentName: widget.name),
    ));
    if (created == true) _load();
  }

  Future<void> _gradeAssignment(Map<String, dynamic> a) async {
    final marksCtrl = TextEditingController(
        text: a['marks'] == null ? '' : a['marks'].toString());
    final feedbackCtrl =
        TextEditingController(text: (a['feedback'] ?? '').toString());

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Grade: ${a['title']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: marksCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Marks'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: feedbackCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Feedback'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (saved != true) return;

    final marks = int.tryParse(marksCtrl.text.trim()) ?? 0;
    final result = await _assignmentService.gradeAssignment(
        (a['_id'] ?? '').toString(), marks, feedbackCtrl.text.trim());
    if (!mounted) return;
    if (result != null) {
      _load();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not save grade')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatar = profileImageProvider(widget.image);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(widget.name, style: AppTypography.h2),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _card(
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor:
                              theme.colorScheme.primary.withValues(alpha: .12),
                          backgroundImage: avatar,
                          child: avatar == null
                              ? Icon(LucideIcons.user,
                                  size: 32, color: theme.colorScheme.primary)
                              : null,
                        ),
                        const SizedBox(width: AppSpacing.s16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.name, style: AppTypography.h2),
                              Text(widget.grade,
                                  style: AppTypography.body14.copyWith(
                                      color:
                                          theme.textTheme.bodyMedium?.color)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s32),

                  Text("Quick Actions", style: AppTypography.h3),
                  const SizedBox(height: AppSpacing.s16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _quickAction(LucideIcons.messageCircle, "Message",
                          _openMessage),
                      _quickAction(LucideIcons.phone, "Call",
                          () => _startCall(video: false)),
                      _quickAction(LucideIcons.video, "Video",
                          () => _startCall(video: true)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s32),

                  _sectionHeader("Assignments", _createAssignment),
                  const SizedBox(height: AppSpacing.s12),
                  if (_assignments.isEmpty)
                    _empty("No assignments given yet")
                  else
                    ..._assignments.map(_assignmentCard),
                  const SizedBox(height: AppSpacing.s32),

                  _sectionHeader("Quizzes", _createQuiz),
                  const SizedBox(height: AppSpacing.s12),
                  if (_quizzes.isEmpty)
                    _empty("No quizzes assigned yet")
                  else
                    ..._quizzes.map(_quizCard),
                  const SizedBox(height: AppSpacing.s32),

                  Text("Session History", style: AppTypography.h3),
                  const SizedBox(height: AppSpacing.s16),
                  if (_sessions.isEmpty)
                    _empty("No sessions yet")
                  else
                    ..._sessions.map(_historyTile),
                ],
              ),
            ),
    );
  }

  Widget _sectionHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.h3),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(LucideIcons.plus, size: 18),
          label: const Text("New"),
        ),
      ],
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: theme.shadowColor.withValues(alpha: .15),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(label, style: AppTypography.body14),
        ],
      ),
    );
  }

  Widget _assignmentCard(Map<String, dynamic> a) {
    final theme = Theme.of(context);
    final submission = a['submission'] as Map<String, dynamic>?;
    final marks = a['marks'];
    String status;
    if (submission == null) {
      status = 'Not submitted';
    } else if (marks == null) {
      status = 'Submitted • needs grading';
    } else {
      status = 'Graded: $marks';
    }
    final canGrade = submission != null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: theme.shadowColor.withValues(alpha: .15),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(LucideIcons.fileText, color: theme.colorScheme.secondary),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((a['title'] ?? '').toString(), style: AppTypography.h3),
                Text(status,
                    style: AppTypography.body14
                        .copyWith(color: theme.textTheme.bodyMedium?.color)),
              ],
            ),
          ),
          if (canGrade)
            TextButton(
              onPressed: () => _gradeAssignment(a),
              child: Text(marks == null ? 'Grade' : 'Edit'),
            ),
        ],
      ),
    );
  }

  Widget _quizCard(Map<String, dynamic> q) {
    final theme = Theme.of(context);
    final submission = q['submission'] as Map<String, dynamic>?;
    final status = submission == null
        ? 'Not attempted'
        : 'Score: ${submission['score']}/${submission['total']}';
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: theme.shadowColor.withValues(alpha: .15),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(LucideIcons.listChecks, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((q['title'] ?? '').toString(), style: AppTypography.h3),
                Text(status,
                    style: AppTypography.body14
                        .copyWith(color: theme.textTheme.bodyMedium?.color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyTile(Map<String, dynamic> s) {
    final theme = Theme.of(context);
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final rec = s['recurrence'];
    final dow = rec is Map ? rec['dayOfWeek'] : null;
    final day = (dow is int && dow >= 1 && dow <= 7) ? days[dow] : '';
    final subtitle =
        '${(s['status'] ?? '').toString()}${day.isNotEmpty ? ' • $day' : ''}';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: theme.shadowColor.withValues(alpha: .15),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(LucideIcons.clock, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((s['subject'] ?? 'Session').toString(),
                    style: AppTypography.h3),
                Text(subtitle,
                    style: AppTypography.body14
                        .copyWith(color: theme.textTheme.bodyMedium?.color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: theme.shadowColor.withValues(alpha: .15),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _empty(String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
      child: Center(
        child: Text(text,
            style: AppTypography.body16
                .copyWith(color: theme.textTheme.bodyMedium?.color)),
      ),
    );
  }
}
