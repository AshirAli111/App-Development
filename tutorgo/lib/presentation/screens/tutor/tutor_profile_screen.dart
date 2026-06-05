import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/core/theme/theme_manager.dart';
import 'package:next_step_learning/routes/app_routes.dart';

class TutorProfileScreen extends StatelessWidget {
  const TutorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s24),
              _profileHeader(context),
              const SizedBox(height: AppSpacing.s24),
              _statsRow(context),
              const SizedBox(height: AppSpacing.s32),

              _sectionTitle(context, "Account"),
              _menuTile(
                context,
                "Edit Profile",
                LucideIcons.userCog,
                AppRoutes.editProfile,
              ),
              _menuTile(
                context,
                "Payment Methods",
                LucideIcons.creditCard,
                AppRoutes.paymentMethods,
              ),
              _menuTile(
                context,
                "Payout Settings",
                LucideIcons.wallet,
                AppRoutes.payoutSettings,
              ),

              const SizedBox(height: AppSpacing.s32),

              _sectionTitle(context, "Preferences"),
              _menuTile(
                context,
                "Notifications",
                LucideIcons.bell,
                AppRoutes.notifications,
              ),
              _menuTile(
                context,
                "Privacy Settings",
                LucideIcons.shield,
                AppRoutes.privacySettings,
              ),
              _menuTile(
                context,
                "Language",
                LucideIcons.languages,
                AppRoutes.languageSettings,
              ),

              /// 🌙 DARK MODE TOGGLE
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s20,
                ),
                title: Text(
                  "Dark Mode",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                value: context.watch<ThemeProvider>().isDark,
                onChanged: (value) {
                  context.read<ThemeProvider>().toggleTheme(value);
                },
              ),

              const SizedBox(height: AppSpacing.s32),

              _sectionTitle(context, "Support"),
              _menuTile(
                context,
                "Help Center",
                LucideIcons.helpCircle,
                AppRoutes.helpCenter,
              ),
              _menuTile(
                context,
                "Contact Support",
                Icons.headset_mic,
                AppRoutes.contactSupport,
              ),

              const SizedBox(height: AppSpacing.s32),

              _logoutButton(context),
              const SizedBox(height: AppSpacing.s40),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // 🔵 PROFILE HEADER
  // -----------------------------------------------------------
  Widget _profileHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: AppSpacing.s12,
        bottom: AppSpacing.s24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: .12),
                child: Icon(
                  Icons.person_rounded,
                  size: 58,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text("Ali Khan", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.s4),
          Text(
            "Mathematics • Physics Tutor",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // 📊 Stats row
  // -----------------------------------------------------------
  Widget _statsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statCard(context, "120", "Sessions"),
          _statCard(context, "18", "Students"),
          _statCard(context, "4.9", "Rating"),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, String number, String label) {
    return Container(
      width: 105,
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

  // -----------------------------------------------------------
  // 📌 Section Title
  // -----------------------------------------------------------
  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.s20,
        bottom: AppSpacing.s8,
      ),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  // -----------------------------------------------------------
  // 📋 Menu Tile with Navigation
  // -----------------------------------------------------------
  Widget _menuTile(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s8,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s16,
        ),
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
              child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // 🔴 Logout Button
  // -----------------------------------------------------------
  Widget _logoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {},
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
