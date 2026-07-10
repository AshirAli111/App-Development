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
                            return _sessionCard(
                              context,
                              session: sessions[i],
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
      {required Map<String, dynamic> session, required Color color}) {
    final theme = Theme.of(context);
    final time = _formatRecurrence(session['recurrence']);
    final subject = (session['subject'] ?? 'Session').toString();
    final student = (session['studentName'] ?? 'Student').toString();

    return Container(
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
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.tutorScheduleDetails,
                  arguments: {
                    "time": time,
                    "subject": subject,
                    "student": student,
                    "color": color,
                  });
            },
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
                      Text("With $student • $time",
                          style: AppTypography.body14.copyWith(
                              color: theme.textTheme.bodyMedium?.color)),
                    ],
                  ),
                ),
                Icon(LucideIcons.chevronRight,
                    color: theme.iconTheme.color, size: 22),
              ],
            ),
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _rescheduleSession(session),
                  icon: const Icon(LucideIcons.calendarClock, size: 18),
                  label: const Text("Reschedule"),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _cancelSession(session),
                  style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error),
                  icon: const Icon(LucideIcons.x, size: 18),
                  label: const Text("Cancel"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  SessionService _sessionServiceFor(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return SessionService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
      role: auth.role,
    );
  }

  Future<void> _cancelSession(Map<String, dynamic> session) async {
    final id = (session['_id'] ?? '').toString();
    if (id.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Cancel session?"),
        content: Text(
            "Cancel your ${session['subject'] ?? ''} session with ${session['studentName'] ?? 'this student'}? This removes all upcoming instances."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes, cancel"),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final ok = await _sessionServiceFor(context).cancelSession(id);
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(
        content: Text(ok ? "Session cancelled" : "Could not cancel session")));
    if (ok) _loadSessions();
  }

  Future<void> _rescheduleSession(Map<String, dynamic> session) async {
    final id = (session['_id'] ?? '').toString();
    if (id.isEmpty) return;
    final rec = (session['recurrence'] as Map?) ?? {};

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _RescheduleSheet(recurrence: rec),
    );

    if (result == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final startDate = (rec['startDate'] ?? DateTime.now().toIso8601String());
    final updated = await _sessionServiceFor(context).updateSession(id, {
      'recurrence': {
        'dayOfWeek': result['dayOfWeek'],
        'startTime': result['startTime'],
        'endTime': result['endTime'],
        'startDate': startDate is String
            ? startDate
            : DateTime.now().toIso8601String(),
      },
    });
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(
        content: Text(
            updated != null ? "Session rescheduled" : "Could not reschedule")));
    if (updated != null) {
      setState(() => selectedDayIndex = (result['dayOfWeek'] as int) - 1);
      _loadSessions();
    }
  }
}

/// Bottom sheet to pick a new day + time for a session. Pops with
/// {dayOfWeek, startTime, endTime} or null if cancelled.
class _RescheduleSheet extends StatefulWidget {
  final Map recurrence;
  const _RescheduleSheet({required this.recurrence});

  @override
  State<_RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<_RescheduleSheet> {
  static const _days = <String, int>{
    'Monday': 1,
    'Tuesday': 2,
    'Wednesday': 3,
    'Thursday': 4,
    'Friday': 5,
    'Saturday': 6,
    'Sunday': 7,
  };

  static const _times = <String>[
    '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00',
    '15:00', '16:00', '17:00', '18:00', '19:00', '20:00',
  ];

  String? _day;
  String? _startTime;
  String? _endTime;

  @override
  void initState() {
    super.initState();
    final dow = widget.recurrence['dayOfWeek'];
    _day = _days.entries
        .firstWhere((e) => e.value == dow, orElse: () => _days.entries.first)
        .key;
    final start = (widget.recurrence['startTime'] ?? '').toString();
    final end = (widget.recurrence['endTime'] ?? '').toString();
    _startTime = _times.contains(start) ? start : null;
    _endTime = _times.contains(end) ? end : null;
  }

  bool get _isValid => _day != null && _startTime != null && _endTime != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 5,
                width: 60,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Text("Reschedule Session", style: theme.textTheme.headlineMedium),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _day,
              decoration: const InputDecoration(labelText: 'Day of week'),
              items: _days.keys
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (val) => setState(() => _day = val),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _startTime,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Start'),
                    items: _times
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setState(() => _startTime = val),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _endTime,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'End'),
                    items: _times
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setState(() => _endTime = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isValid
                    ? () {
                        if (_times.indexOf(_endTime!) <=
                            _times.indexOf(_startTime!)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('End time must be after start time')),
                          );
                          return;
                        }
                        Navigator.pop(context, {
                          'dayOfWeek': _days[_day],
                          'startTime': _startTime,
                          'endTime': _endTime,
                        });
                      }
                    : null,
                child: const Text("Confirm"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
