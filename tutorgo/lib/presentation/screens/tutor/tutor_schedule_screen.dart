import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/session_service.dart';
import 'package:next_step_learning/routes/app_routes.dart';

import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/core/theme/typography.dart';

class TutorScheduleScreen extends StatefulWidget {
  const TutorScheduleScreen({super.key});

  @override
  State<TutorScheduleScreen> createState() => _TutorScheduleScreenState();
}

class _TutorScheduleScreenState extends State<TutorScheduleScreen> {
  int selectedDayIndex = DateTime.now().weekday - 1;
  final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;

  final _dayColors = [
    Colors.blue,
    Colors.orange,
    Colors.deepPurple,
    Colors.green,
    Colors.pink,
    Colors.teal,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
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

  List<Map<String, dynamic>> _getSessionsForDay(int dayIndex) {
    // recurrence.dayOfWeek is 1=Mon .. 7=Sun; dayIndex is 0=Mon .. 6=Sun.
    final targetDayOfWeek = dayIndex + 1;
    return _sessions.where((s) {
      final rec = s['recurrence'];
      if (rec is! Map) return false;
      return rec['dayOfWeek'] == targetDayOfWeek;
    }).toList();
  }

  /// Formats a recurrence map into a "HH:mm–HH:mm" time label.
  String _formatRecurrence(dynamic rec) {
    if (rec is! Map) return '';
    final start = (rec['startTime'] ?? '').toString();
    final end = (rec['endTime'] ?? '').toString();
    return end.isNotEmpty ? '$start–$end' : start;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessions = _getSessionsForDay(selectedDayIndex);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text("Schedule", style: AppTypography.h2),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dayTabs(context),
                const SizedBox(height: AppSpacing.s20),
                Expanded(
                  child: sessions.isEmpty
                      ? _emptyState(context)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s20),
                          itemCount: sessions.length,
                          itemBuilder: (context, i) {
                            final s = sessions[i];
                            return _sessionCard(
                              context,
                              time: _formatRecurrence(s['recurrence']),
                              subject: s['subject'] ?? 'Session',
                              student: s['studentName'] ?? 'Student',
                              color: _dayColors[i % _dayColors.length],
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _dayTabs(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        itemCount: days.length,
        itemBuilder: (context, index) {
          bool active = index == selectedDayIndex;

          return GestureDetector(
            onTap: () => setState(() => selectedDayIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: AppSpacing.s12),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s20, vertical: AppSpacing.s12),
              decoration: BoxDecoration(
                color: active ? theme.colorScheme.primary : theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: active
                        ? theme.colorScheme.primary.withValues(alpha: .3)
                        : theme.shadowColor.withValues(alpha: .12),
                    blurRadius: active ? 14 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  days[index],
                  style: AppTypography.body16.copyWith(
                    color: active
                        ? Colors.white
                        : theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.calendarX, size: 52,
              color: theme.iconTheme.color?.withValues(alpha: .6)),
          const SizedBox(height: AppSpacing.s16),
          Text(
            "No sessions scheduled for this day",
            style: AppTypography.body16.copyWith(
              color: theme.textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sessionCard(BuildContext context,
      {required String time,
      required String subject,
      required String student,
      required Color color}) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.tutorScheduleDetails, arguments: {
          "time": time,
          "subject": subject,
          "student": student,
          "color": color,
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s16),
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: .12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withValues(alpha: .18),
              child: Icon(LucideIcons.bookOpen, color: color, size: 22),
            ),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject,
                      style: AppTypography.h3.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.bodyMedium?.color,
                      )),
                  const SizedBox(height: 2),
                  Text("With $student",
                      style: AppTypography.body14.copyWith(
                          color: theme.textTheme.bodyMedium?.color)),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: theme.iconTheme.color, size: 22),
          ],
        ),
      ),
    );
  }
}
