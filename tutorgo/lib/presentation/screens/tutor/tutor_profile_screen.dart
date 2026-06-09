import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/core/theme/theme_manager.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/user_service.dart';
import 'package:next_step_learning/data/services/session_service.dart';
import 'package:next_step_learning/routes/app_routes.dart';

class TutorProfileScreen extends StatefulWidget {
  const TutorProfileScreen({super.key});

  @override
  State<TutorProfileScreen> createState() => _TutorProfileScreenState();
}

class _TutorProfileScreenState extends State<TutorProfileScreen> {
  Map<String, dynamic>? _profile;
  int _sessionCount = 0;
  int _studentCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
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

    final studentIds = <String>{};
    for (final s in sessions) {
      final sid = s['studentId'] as String? ?? '';
      if (sid.isNotEmpty) studentIds.add(sid);
    }

    if (mounted) {
      setState(() {
        _profile = profile;
        _sessionCount = sessions.length;
        _studentCount = studentIds.length;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fullName = _profile?['fullName'] ?? auth.fullName;
    final subjects = (_profile?['tutorProfile']?['subjects'] as List<dynamic>?)
            ?.join(' • ') ??
        'Tutor';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.s24),
                    _profileHeader(context, fullName, subjects),
                    const SizedBox(height: AppSpacing.s24),
                    _statsRow(context),
                    const SizedBox(height: AppSpacing.s32),

                    _sectionTitle(context, "Account"),
                    _menuTile(context, "Edit Profile", LucideIcons.userCog,
                        AppRoutes.editProfile),
                    _menuTile(context, "Payment Methods", LucideIcons.creditCard,
                        AppRoutes.paymentMethods),
                    _menuTile(context, "Payout Settings", LucideIcons.wallet,
                        AppRoutes.payoutSettings),

                    const SizedBox(height: AppSpacing.s32),

                    _sectionTitle(context, "Preferences"),
                    _menuTile(context, "Notifications", LucideIcons.bell,
                        AppRoutes.notifications),
                    _menuTile(context, "Privacy Settings", LucideIcons.shield,
                        AppRoutes.privacySettings),
                    _menuTile(context, "Language", LucideIcons.languages,
                        AppRoutes.languageSettings),

                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s20),
                      title: Text("Dark Mode",
                          style: Theme.of(context).textTheme.bodyLarge),
                      value: context.watch<ThemeProvider>().isDark,
                      onChanged: (value) {
                        context.read<ThemeProvider>().toggleTheme(value);
                      },
                    ),

                    const SizedBox(height: AppSpacing.s32),

                    _sectionTitle(context, "Support"),
                    _menuTile(context, "Help Center", LucideIcons.helpCircle,
                        AppRoutes.helpCenter),
                    _menuTile(context, "Contact Support", Icons.headset_mic,
                        AppRoutes.contactSupport),

                    const SizedBox(height: AppSpacing.s32),
                    _logoutButton(context),
                    const SizedBox(height: AppSpacing.s40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _profileHeader(BuildContext context, String name, String subjects) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: AppSpacing.s12, bottom: AppSpacing.s24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: .12),
            child: Icon(Icons.person_rounded, size: 58,
                color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.s4),
          Text("$subjects Tutor", style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _statsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statCard(context, _sessionCount.toString(), "Sessions"),
          _statCard(context, _studentCount.toString(), "Students"),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, String number, String label) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: .2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(number, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.s4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.s20, bottom: AppSpacing.s8),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _menuTile(BuildContext context, String title, IconData icon, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16, vertical: AppSpacing.s16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: .15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
                child: Text(title, style: Theme.of(context).textTheme.bodyLarge)),
            Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color),
          ],
        ),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return GestureDetector(
      onTap: _handleLogout,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            "Logout",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ),
      ),
    );
  }
}
