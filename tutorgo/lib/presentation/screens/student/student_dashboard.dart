import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/assignment_service.dart';
import 'package:next_step_learning/data/services/quiz_service.dart';
import 'package:next_step_learning/data/services/session_service.dart';
import 'package:next_step_learning/data/services/user_service.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/image_utils.dart';
import '../../../routes/app_routes.dart';
import '../aichat/ai_chat_screen.dart';
import 'take_quiz_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _quizzes = [];
  List<Map<String, dynamic>> _assignments = [];
  bool _isLoading = true;

  AuthProvider get _auth => context.read<AuthProvider>();
  AssignmentService get _assignmentService => AssignmentService(
      baseUrl: _auth.baseUrl,
      token: _auth.accessToken,
      userId: _auth.userId,
      role: _auth.role);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final userService = UserService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
    );
    final sessionService = SessionService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
      role: auth.role,
    );
    final quizService = QuizService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
      role: auth.role,
    );

    final profile = await userService.getMyProfile();
    final sessions = await sessionService.getMySessions();
    final quizzes = await quizService.getQuizzes();
    final assignments = await _assignmentService.getAssignments();

    if (mounted) {
      setState(() {
        _profile = profile;
        _sessions = sessions;
        _quizzes = quizzes;
        _assignments = assignments;
        _isLoading = false;
      });
    }
  }

  Future<void> _takeQuiz(Map<String, dynamic> quiz) async {
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TakeQuizScreen(quiz: quiz)),
    );
    if (done == true) _loadData();
  }

  Future<void> _uploadAssignment(Map<String, dynamic> a) async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await FilePicker.platform.pickFiles(withData: true);
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;
    if (bytes.length > 3 * 1024 * 1024) {
      messenger.showSnackBar(
          const SnackBar(content: Text('File too large (max 3MB)')));
      return;
    }
    final result = await _assignmentService.submitAssignment(
        (a['_id'] ?? '').toString(), base64Encode(bytes), file.name);
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(
        content: Text(result != null
            ? 'Assignment submitted'
            : 'Could not submit assignment')));
    if (result != null) _loadData();
  }

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    final auth = context.watch<AuthProvider>();

    final bg = dark
        ? Theme.of(context).scaffoldBackgroundColor
        : AppColors.background;
    final card = dark ? Theme.of(context).cardColor : Colors.white;
    final border = dark ? Theme.of(context).dividerColor : AppColors.border;
    final textPrimary = dark
        ? Theme.of(context).colorScheme.onSurface
        : AppColors.textDark;
    final textSecondary = dark
        ? Theme.of(context).colorScheme.onSurface.withValues(alpha: .70)
        : AppColors.textLight;

    final userName = _profile?['fullName'] ?? auth.fullName;
    final firstName =
        userName.isNotEmpty ? userName.split(' ').first : 'Student';

    // Derive stats from sessions
    final totalSessions = _sessions.length;
    final activeSessions =
        _sessions.where((s) => s['status'] == 'active').toList();

    // Extract unique tutors (name + avatar) from sessions
    final tutorsMap = <String, Map<String, dynamic>>{};
    for (final s in _sessions) {
      final tutorName = s['tutorName'] as String? ?? '';
      final tutorId = s['tutorId'] as String? ?? tutorName;
      if (tutorName.isNotEmpty && !tutorsMap.containsKey(tutorId)) {
        tutorsMap[tutorId] = {'name': tutorName, 'image': s['tutorImage']};
      }
    }
    final tutors = tutorsMap.values.toList();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(context, firstName, textPrimary, textSecondary,
                        _profile?['profileImage'] as String?),
                    const SizedBox(height: AppSpacing.s20),
                    _statsRow(context, totalSessions, tutors.length),
                    const SizedBox(height: AppSpacing.s28),

                    if (activeSessions.isNotEmpty) ...[
                      Text(
                        "Active Sessions",
                        style: AppTypography.h3.copyWith(color: textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _sessionsList(
                          context, activeSessions, card, border, textPrimary, textSecondary),
                      const SizedBox(height: AppSpacing.s28),
                    ],

                    if (_quizzes.isNotEmpty || _assignments.isNotEmpty) ...[
                      Text(
                        "Quizzes & Assignments",
                        style: AppTypography.h3.copyWith(color: textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      ..._quizzes.map((q) =>
                          _quizCard(context, q, card, border, textPrimary,
                              textSecondary)),
                      ..._assignments.map((a) =>
                          _assignmentCard(context, a, card, border, textPrimary,
                              textSecondary)),
                      const SizedBox(height: AppSpacing.s28),
                    ],

                    if (tutors.isNotEmpty) ...[
                      Text(
                        "Your Tutors",
                        style: AppTypography.h3.copyWith(color: textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _yourTutors(context, tutors, textPrimary),
                    ],

                    if (_sessions.isEmpty)
                      _emptyState(context, textSecondary),

                    const SizedBox(height: 90),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "ai_student_fab",
        tooltip: "Ask AI Tutor",
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.aiChatScreen,
            arguments: AiRole.student,
          );
        },
        icon: const Icon(LucideIcons.sparkles),
        label: const Text("AI Tutor"),
      ),
    );
  }

  Widget _header(BuildContext context, String name, Color textPrimary,
      Color textSecondary, String? image) {
    final avatar = profileImageProvider(image);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi, $name",
              style: AppTypography.h2.copyWith(color: textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              "Ready for another productive day?",
              style: AppTypography.body14.copyWith(color: textSecondary),
            ),
          ],
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
          backgroundImage: avatar,
          child: avatar == null
              ? Icon(
                  LucideIcons.user,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
        ),
      ],
    );
  }

  Widget _statsRow(BuildContext context, int sessions, int tutors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("Sessions", sessions.toString()),
          _statItem("Tutors", tutors.toString()),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: AppTypography.h2.copyWith(color: Colors.white)),
        const SizedBox(height: 4),
        Text(label,
            style: AppTypography.body12.copyWith(color: Colors.white70)),
      ],
    );
  }

  Widget _sessionsList(
    BuildContext context,
    List<Map<String, dynamic>> sessions,
    Color card,
    Color border,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      children: sessions.take(3).map((s) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                child: Icon(LucideIcons.bookOpen,
                    color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s['subject'] ?? 'Session',
                      style: AppTypography.h3.copyWith(color: textPrimary),
                    ),
                    Text(
                      'with ${s['tutorName'] ?? 'Tutor'}',
                      style: AppTypography.body12.copyWith(color: textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                _formatRecurrence(s['recurrence']),
                style: AppTypography.body12.copyWith(color: textSecondary),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Formats a session recurrence map (e.g. {dayOfWeek, startTime, endTime})
  /// into a short readable label like "Mon 14:00–15:00".
  String _formatRecurrence(dynamic rec) {
    if (rec is! Map) return '';
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dow = rec['dayOfWeek'];
    final day = (dow is int && dow >= 1 && dow <= 7) ? days[dow] : '';
    final start = (rec['startTime'] ?? '').toString();
    final end = (rec['endTime'] ?? '').toString();
    final time = end.isNotEmpty ? '$start–$end' : start;
    return '$day $time'.trim();
  }

  Widget _quizCard(BuildContext context, Map<String, dynamic> q, Color card,
      Color border, Color textPrimary, Color textSecondary) {
    final theme = Theme.of(context);
    final submission = q['submission'] as Map<String, dynamic>?;
    final subject = (q['subject'] ?? '').toString();
    final tutor = (q['tutorName'] ?? 'Tutor').toString();
    final done = submission != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: .12),
            child: Icon(LucideIcons.listChecks,
                color: theme.colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((q['title'] ?? 'Quiz').toString(),
                    style: AppTypography.h3.copyWith(color: textPrimary)),
                Text(
                  '${subject.isNotEmpty ? '$subject • ' : ''}Quiz by $tutor',
                  style:
                      AppTypography.body12.copyWith(color: textSecondary),
                ),
              ],
            ),
          ),
          if (done)
            Text('${submission['score']}/${submission['total']}',
                style: AppTypography.h3
                    .copyWith(color: theme.colorScheme.primary))
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _takeQuiz(q),
              child: const Text('Take'),
            ),
        ],
      ),
    );
  }

  Widget _assignmentCard(BuildContext context, Map<String, dynamic> a,
      Color card, Color border, Color textPrimary, Color textSecondary) {
    final theme = Theme.of(context);
    final submission = a['submission'] as Map<String, dynamic>?;
    final marks = a['marks'];
    final subject = (a['subject'] ?? '').toString();
    final tutor = (a['tutorName'] ?? 'Tutor').toString();

    String trailingLabel;
    Widget? action;
    if (submission == null) {
      trailingLabel = '';
      action = ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        onPressed: () => _uploadAssignment(a),
        child: const Text('Upload'),
      );
    } else if (marks == null) {
      trailingLabel = 'Submitted';
    } else {
      trailingLabel = 'Marks: $marks';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor:
                theme.colorScheme.secondary.withValues(alpha: .15),
            child:
                Icon(LucideIcons.fileText, color: theme.colorScheme.secondary),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((a['title'] ?? 'Assignment').toString(),
                    style: AppTypography.h3.copyWith(color: textPrimary)),
                Text(
                  '${subject.isNotEmpty ? '$subject • ' : ''}Assignment by $tutor',
                  style:
                      AppTypography.body12.copyWith(color: textSecondary),
                ),
              ],
            ),
          ),
          if (action != null)
            action
          else
            Text(trailingLabel,
                style: AppTypography.body14.copyWith(color: textPrimary)),
        ],
      ),
    );
  }

  Widget _yourTutors(BuildContext context,
      List<Map<String, dynamic>> tutors, Color textPrimary) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: tutors.length,
        itemBuilder: (_, i) {
          final name = (tutors[i]['name'] ?? 'Tutor').toString();
          final avatar = profileImageProvider(tutors[i]['image']);
          return Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                backgroundImage: avatar,
                child: avatar == null
                    ? Icon(LucideIcons.user,
                        color: Theme.of(context).colorScheme.primary)
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                name.split(' ').first,
                style: AppTypography.body12.copyWith(color: textPrimary),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _emptyState(BuildContext context, Color textSecondary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(LucideIcons.bookOpen, size: 48, color: textSecondary),
            const SizedBox(height: 16),
            Text(
              "No sessions yet",
              style: AppTypography.h3.copyWith(color: textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              "Find a tutor to start learning!",
              style: AppTypography.body14.copyWith(color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
