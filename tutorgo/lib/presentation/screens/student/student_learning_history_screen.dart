import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/session_service.dart';

import '../../../core/theme/spacing.dart';

class StudentLearningHistoryScreen extends StatefulWidget {
  const StudentLearningHistoryScreen({super.key});

  @override
  State<StudentLearningHistoryScreen> createState() =>
      _StudentLearningHistoryScreenState();
}

class _StudentLearningHistoryScreenState
    extends State<StudentLearningHistoryScreen> {
  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final auth = context.read<AuthProvider>();
    final sessionService = SessionService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
      role: auth.role,
    );

    final sessions = await sessionService.getMySessions();

    if (mounted) {
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Learning History",
            style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? Center(
                  child: Text("No sessions yet",
                      style: Theme.of(context).textTheme.bodyLarge),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  itemCount: _sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, i) {
                    final s = _sessions[i];
                    final subject = s['subject'] ?? 'Session';
                    final createdAt = s['createdAt'] as String?;
                    String dateStr = '';
                    if (createdAt != null) {
                      try {
                        final date = DateTime.parse(createdAt);
                        dateStr = DateFormat('MMM d, yyyy').format(date);
                      } catch (_) {}
                    }

                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .shadowColor
                                .withValues(alpha: .15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(subject,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                if (s['tutorName'] != null)
                                  Text(
                                    'with ${s['tutorName']}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(dateStr,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              Text(
                                s['status'] ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: s['status'] == 'active'
                                          ? Colors.green
                                          : null,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
