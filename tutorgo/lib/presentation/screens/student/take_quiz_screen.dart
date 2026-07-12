import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/quiz_service.dart';
import 'package:next_step_learning/core/theme/spacing.dart';

/// Student takes an MCQ quiz. Returns true (via pop) after a successful submit.
class TakeQuizScreen extends StatefulWidget {
  final Map<String, dynamic> quiz;
  const TakeQuizScreen({super.key, required this.quiz});

  @override
  State<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  late final List<int?> _answers;
  bool _submitting = false;

  List<dynamic> get _questions =>
      (widget.quiz['questions'] as List?) ?? const [];

  @override
  void initState() {
    super.initState();
    _answers = List<int?>.filled(_questions.length, null);
  }

  Future<void> _submit() async {
    if (_answers.any((a) => a == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer every question')),
      );
      return;
    }
    setState(() => _submitting = true);
    final auth = context.read<AuthProvider>();
    final navigator = Navigator.of(context);
    final service = QuizService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
      role: auth.role,
    );
    final result = await service.submitQuiz(
      (widget.quiz['_id'] ?? '').toString(),
      _answers.map((a) => a!).toList(),
    );
    if (!mounted) return;
    if (result != null) {
      final sub = result['submission'] as Map<String, dynamic>;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Quiz submitted'),
          content: Text('You scored ${sub['score']} / ${sub['total']}.'),
          actions: [
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK')),
          ],
        ),
      );
      navigator.pop(true);
    } else {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit quiz')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text((widget.quiz['title'] ?? 'Quiz').toString(),
            style: theme.textTheme.titleLarge),
        backgroundColor: theme.cardColor,
        elevation: 0.4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _questions.length; i++) _questionCard(i),
            const SizedBox(height: AppSpacing.s16),
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
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Submit',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _questionCard(int i) {
    final theme = Theme.of(context);
    final q = _questions[i] as Map<String, dynamic>;
    final options = List<String>.from(q['options'] ?? const []);
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
          Text('${i + 1}. ${q['text']}', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          RadioGroup<int>(
            groupValue: _answers[i],
            onChanged: (v) => setState(() => _answers[i] = v),
            child: Column(
              children: [
                for (var o = 0; o < options.length; o++)
                  RadioListTile<int>(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: o,
                    title: Text(options[o]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
