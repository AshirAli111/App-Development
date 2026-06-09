import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/session_service.dart';
import 'package:next_step_learning/data/services/notification_service.dart';
import 'package:next_step_learning/data/services/payment_service.dart';

import 'package:next_step_learning/core/theme/spacing.dart';

class TutorHomeScreen extends StatefulWidget {
  const TutorHomeScreen({super.key});

  @override
  State<TutorHomeScreen> createState() => _TutorHomeScreenState();
}

class _TutorHomeScreenState extends State<TutorHomeScreen> {
  bool _isLoading = true;
  String _fullName = '';
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _notifications = [];
  Map<String, dynamic>? _paymentSummary;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    _fullName = auth.fullName;

    final sessionService = SessionService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
      role: auth.role,
    );
    final notificationService = NotificationService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
    );
    final paymentService = PaymentService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
      role: auth.role,
    );

    final sessions = await sessionService.getMySessions();
    final notifications = await notificationService.getNotifications();
    final summary = await paymentService.getPaymentSummary();

    if (mounted) {
      setState(() {
        _sessions = sessions;
        _notifications = notifications;
        _paymentSummary = summary;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Derive stats
    final activeSessions =
        _sessions.where((s) => s['status'] == 'active').length;
    final studentNames = <String>{};
    for (final s in _sessions) {
      final name = s['studentName'] as String? ?? '';
      if (name.isNotEmpty) studentNames.add(name);
    }
    final totalEarnings = _paymentSummary?['completedPKR'] ?? 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(context),
                      const SizedBox(height: AppSpacing.s24),
                      _highlightCards(
                          context, activeSessions, studentNames.length, totalEarnings),
                      const SizedBox(height: AppSpacing.s32),

                      if (studentNames.isNotEmpty) ...[
                        _sectionTitle(context, "My Students", LucideIcons.users),
                        const SizedBox(height: AppSpacing.s16),
                        _studentsGrid(context, studentNames.toList()),
                        const SizedBox(height: AppSpacing.s32),
                      ],

                      if (_notifications.isNotEmpty) ...[
                        _sectionTitle(
                            context, "Notifications", LucideIcons.bell),
                        const SizedBox(height: AppSpacing.s16),
                        _notificationsList(context),
                      ],

                      if (_sessions.isEmpty && _notifications.isEmpty)
                        _emptyState(context),

                      const SizedBox(height: AppSpacing.s40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurface),
          const SizedBox(width: AppSpacing.s8),
          Text(title, style: theme.textTheme.headlineMedium),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final theme = Theme.of(context);
    final firstName =
        _fullName.isNotEmpty ? _fullName.split(' ').first : 'Tutor';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20, AppSpacing.s32, AppSpacing.s20, AppSpacing.s40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: .85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: .25),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: AppSpacing.s12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hello $firstName",
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
              const SizedBox(height: AppSpacing.s4),
              Text("Welcome Back!",
                  style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _highlightCards(
      BuildContext context, int sessions, int students, int earnings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Row(
        children: [
          _highlightCard(context,
              icon: LucideIcons.calendarClock,
              title: "Sessions",
              value: "$sessions Active",
              subtitle: "$students Students",
              color: Colors.green),
          const SizedBox(width: AppSpacing.s16),
          _highlightCard(context,
              icon: LucideIcons.wallet,
              title: "Earnings",
              value: "PKR $earnings",
              subtitle: "Completed",
              color: Colors.purple),
        ],
      ),
    );
  }

  Widget _highlightCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String value,
      required String subtitle,
      required Color color}) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: .15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: color.withValues(alpha: .15),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(value, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s4),
            Text(title,
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            Text(subtitle, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _studentsGrid(BuildContext context, List<String> students) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: GridView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: students.length > 4 ? 4 : students.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 100,
          crossAxisSpacing: AppSpacing.s16,
          mainAxisSpacing: AppSpacing.s16,
        ),
        itemBuilder: (_, i) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: .15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: .12),
                  child: Icon(LucideIcons.user, size: 18,
                      color: theme.colorScheme.primary),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(students[i].split(' ').first,
                    style: theme.textTheme.titleMedium),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _notificationsList(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: _notifications.take(5).map((n) {
        return Container(
          margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s20, vertical: AppSpacing.s8),
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: .15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: .15),
                child: Icon(LucideIcons.bell, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n['title'] ?? '', style: theme.textTheme.titleMedium),
                    Text(n['message'] ?? '', style: theme.textTheme.bodySmall,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(LucideIcons.calendarClock, size: 48,
                color: theme.textTheme.bodySmall?.color),
            const SizedBox(height: 16),
            Text("No sessions yet",
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text("Sessions will appear here when students book you",
                style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
