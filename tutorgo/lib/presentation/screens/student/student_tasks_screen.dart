import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/assignment_service.dart';
import 'package:next_step_learning/data/services/quiz_service.dart';
import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/presentation/screens/student/take_quiz_screen.dart';

/// Student view of assigned quizzes and assignments.
class StudentTasksScreen extends StatefulWidget {
  const StudentTasksScreen({super.key});

  @override
  State<StudentTasksScreen> createState() => _StudentTasksScreenState();
}

class _StudentTasksScreenState extends State<StudentTasksScreen> {
  List<Map<String, dynamic>> _quizzes = [];
  List<Map<String, dynamic>> _assignments = [];
  bool _loading = true;

  AuthProvider get _auth => context.read<AuthProvider>();

  AssignmentService get _assignmentService => AssignmentService(
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
    final quizService = QuizService(
      baseUrl: _auth.baseUrl,
      token: _auth.accessToken,
      userId: _auth.userId,
      role: _auth.role,
    );
    final results = await Future.wait([
      quizService.getQuizzes(),
      _assignmentService.getAssignments(),
    ]);
    if (!mounted) return;
    setState(() {
      _quizzes = results[0];
      _assignments = results[1];
      _loading = false;
    });
  }

  Future<void> _takeQuiz(Map<String, dynamic> quiz) async {
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TakeQuizScreen(quiz: quiz)),
    );
    if (done == true) _load();
  }

  Future<void> _uploadAssignment(Map<String, dynamic> a) async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await FilePicker.platform.pickFiles(withData: true);
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Could not read the file')));
      return;
    }
    if (bytes.length > 3 * 1024 * 1024) {
      messenger.showSnackBar(
          const SnackBar(content: Text('File too large (max 3MB)')));
      return;
    }
    final result = await _assignmentService.submitAssignment(
      (a['_id'] ?? '').toString(),
      base64Encode(bytes),
      file.name,
    );
    if (!mounted) return;
    if (result != null) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Assignment submitted')));
      _load();
    } else {
      messenger.showSnackBar(
          const SnackBar(content: Text('Could not submit assignment')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Quizzes & Assignments',
            style: theme.textTheme.titleLarge),
        backgroundColor: theme.cardColor,
        elevation: 0.4,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.s16),
                children: [
                  Text('Quizzes', style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.s12),
                  if (_quizzes.isEmpty)
                    _empty('No quizzes yet')
                  else
                    ..._quizzes.map(_quizCard),
                  const SizedBox(height: AppSpacing.s24),
                  Text('Assignments', style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.s12),
                  if (_assignments.isEmpty)
                    _empty('No assignments yet')
                  else
                    ..._assignments.map(_assignmentCard),
                ],
              ),
            ),
    );
  }

  Widget _quizCard(Map<String, dynamic> q) {
    final theme = Theme.of(context);
    final submission = q['submission'] as Map<String, dynamic>?;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.listChecks, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((q['title'] ?? 'Quiz').toString(),
                    style: theme.textTheme.titleMedium),
                Text(
                  submission == null
                      ? 'From ${q['tutorName'] ?? 'tutor'}'
                      : 'Score: ${submission['score']}/${submission['total']}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (submission == null)
            ElevatedButton(
              onPressed: () => _takeQuiz(q),
              child: const Text('Take'),
            )
          else
            Icon(LucideIcons.checkCircle2, color: Colors.green),
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
      status = 'Submitted • awaiting grade';
    } else {
      status = 'Marks: $marks';
    }
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.fileText, color: theme.colorScheme.secondary),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((a['title'] ?? 'Assignment').toString(),
                        style: theme.textTheme.titleMedium),
                    Text(status, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (submission == null)
                ElevatedButton(
                  onPressed: () => _uploadAssignment(a),
                  child: const Text('Upload'),
                ),
            ],
          ),
          if ((a['description'] ?? '').toString().trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text((a['description']).toString(),
                style: theme.textTheme.bodyMedium),
          ],
          if ((a['feedback'] ?? '').toString().trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Feedback: ${a['feedback']}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  Widget _empty(String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
      child: Center(
          child: Text(text, style: theme.textTheme.bodyMedium)),
    );
  }
}
