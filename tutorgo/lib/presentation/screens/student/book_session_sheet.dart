import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/session_service.dart';

import '../../../core/theme/spacing.dart';

/// Bottom sheet that lets a student book a recurring weekly session with a tutor.
/// Creates a real session via [SessionService.createSession] and pops with `true`
/// on success so the caller can show feedback.
class BookSessionSheet extends StatefulWidget {
  final String tutorId;
  final String tutorName;

  /// The course tapped in discovery (used as the default selection).
  final String subject;

  /// All courses this tutor teaches; the student picks one for the booking.
  final List<String> courses;
  final int pricePerSession;

  const BookSessionSheet({
    super.key,
    required this.tutorId,
    required this.tutorName,
    required this.subject,
    this.courses = const [],
    this.pricePerSession = 0,
  });

  @override
  State<BookSessionSheet> createState() => _BookSessionSheetState();
}

class _BookSessionSheetState extends State<BookSessionSheet> {
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
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
  ];

  String? _day;
  String? _startTime;
  String? _endTime;
  late String _course;
  bool _submitting = false;

  /// Course options: the tutor's courses, or the tapped subject as a fallback.
  List<String> get _courseOptions =>
      widget.courses.isNotEmpty ? widget.courses : [widget.subject];

  @override
  void initState() {
    super.initState();
    _course = _courseOptions.contains(widget.subject)
        ? widget.subject
        : _courseOptions.first;
  }

  bool get _isValid =>
      _day != null && _startTime != null && _endTime != null && !_submitting;

  Future<void> _confirm() async {
    if (!_isValid) return;

    // End time must be after start time.
    if (_times.indexOf(_endTime!) <= _times.indexOf(_startTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    setState(() => _submitting = true);

    final auth = context.read<AuthProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final sessionService = SessionService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
      role: auth.role,
    );

    final result = await sessionService.createSession({
      'studentId': auth.userId,
      'tutorId': widget.tutorId,
      'subject': _course,
      'recurrence': {
        'dayOfWeek': _days[_day],
        'startTime': _startTime,
        'endTime': _endTime,
        'startDate': DateTime.now().toIso8601String(),
      },
      'pricePerSessionPKR': widget.pricePerSession,
    });

    if (!mounted) return;

    if (result != null) {
      navigator.pop(true);
    } else {
      setState(() => _submitting = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not create booking. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// DRAG HANDLE
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

            Text(
              'Book a Session',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'with ${widget.tutorName}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            /// COURSE
            DropdownButtonFormField<String>(
              initialValue: _course,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Course'),
              items: _courseOptions
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: _submitting
                  ? null
                  : (val) => setState(() => _course = val ?? _course),
            ),
            const SizedBox(height: 14),

            /// DAY
            DropdownButtonFormField<String>(
              initialValue: _day,
              decoration: const InputDecoration(labelText: 'Day of week'),
              items: _days.keys
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: _submitting ? null : (val) => setState(() => _day = val),
            ),
            const SizedBox(height: 14),

            /// START / END TIME
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
                    onChanged: _submitting
                        ? null
                        : (val) => setState(() => _startTime = val),
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
                    onChanged: _submitting
                        ? null
                        : (val) => setState(() => _endTime = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (widget.pricePerSession > 0)
              Text(
                'Price: PKR ${widget.pricePerSession} / session',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 20),

            /// CONFIRM
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
                onPressed: _isValid ? _confirm : null,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Confirm Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
