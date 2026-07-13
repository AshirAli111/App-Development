import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/session_service.dart';
import 'package:next_step_learning/data/services/user_service.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/image_utils.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;

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

    final profile = await userService.getMyProfile();
    final sessions = await sessionService.getMySessions();

    if (mounted) {
      setState(() {
        _profile = profile;
        _sessions = sessions;
        _isLoading = false;
      });
    }
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
      // The AI Tutor FAB is provided by StudentNavbar (the shell) to avoid a
      // duplicate Hero tag when this dashboard is embedded as a tab.
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
