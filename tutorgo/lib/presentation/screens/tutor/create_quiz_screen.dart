import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/quiz_service.dart';
import 'package:next_step_learning/core/theme/spacing.dart';

/// A single MCQ being built (4 options, one correct).
class _QuizQ {
  final textCtrl = TextEditingController();
  final optionCtrls = List.generate(4, (_) => TextEditingController());
  int correctIndex = 0;

  void dispose() {
    textCtrl.dispose();
    for (final c in optionCtrls) {
      c.dispose();
    }
  }
}

/// Tutor builds an MCQ quiz for a specific student.
class CreateQuizScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const CreateQuizScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _titleCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final List<_QuizQ> _questions = [_QuizQ()];
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subjectCtrl.dispose();
    for (final q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      return _snack('Please enter a quiz title');
    }
    final questions = <Map<String, dynamic>>[];
    for (final q in _questions) {
      final text = q.textCtrl.text.trim();
      final options =
          q.optionCtrls.map((c) => c.text.trim()).toList();
      if (text.isEmpty || options.any((o) => o.isEmpty)) {
        return _snack('Every question needs text and all 4 options');
      }
      questions.add({
        'text': text,
        'options': options,
        'correctIndex': q.correctIndex,
      });
    }

    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    final navigator = Navigator.of(context);
    final service = QuizService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
      role: auth.role,
    );
    final result = await service.createQuiz(
      studentId: widget.studentId,
      title: _titleCtrl.text.trim(),
      subject: _subjectCtrl.text.trim(),
      questions: questions,
    );
    if (!mounted) return;
    if (result != null) {
      navigator.pop(true);
    } else {
      setState(() => _saving = false);
      _snack('Could not create quiz');
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('New Quiz', style: theme.textTheme.titleLarge),
        backgroundColor: theme.cardColor,
        elevation: 0.4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('For ${widget.studentName}',
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.s16),
            _field('Quiz Title', _titleCtrl),
            const SizedBox(height: AppSpacing.s12),
            _field('Subject', _subjectCtrl),
            const SizedBox(height: AppSpacing.s20),
            for (var i = 0; i < _questions.length; i++) _questionCard(i),
            const SizedBox(height: AppSpacing.s12),
            OutlinedButton.icon(
              onPressed: () => setState(() => _questions.add(_QuizQ())),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Add Question'),
            ),
            const SizedBox(height: AppSpacing.s24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Create Quiz',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _questionCard(int index) {
    final theme = Theme.of(context);
    final q = _questions[index];
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Question ${index + 1}',
                    style: theme.textTheme.titleMedium),
              ),
              if (_questions.length > 1)
                IconButton(
                  icon: Icon(LucideIcons.trash2,
                      size: 18, color: theme.colorScheme.error),
                  onPressed: () => setState(() {
                    _questions.removeAt(index).dispose();
                  }),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _plainField(q.textCtrl, 'Question text'),
          const SizedBox(height: 10),
          Text('Options (tap the circle to mark the correct one)',
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 6),
          RadioGroup<int>(
            groupValue: q.correctIndex,
            onChanged: (v) => setState(() => q.correctIndex = v ?? 0),
            child: Column(
              children: [
                for (var o = 0; o < 4; o++)
                  Row(
                    children: [
                      Radio<int>(value: o),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child:
                              _plainField(q.optionCtrls[o], 'Option ${o + 1}'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _plainField(TextEditingController ctrl, String hint) {
    final theme = Theme.of(context);
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 6),
        _plainField(ctrl, label),
      ],
    );
  }
}
