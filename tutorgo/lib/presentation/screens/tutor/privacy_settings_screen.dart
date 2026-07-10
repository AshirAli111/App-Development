import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:next_step_learning/core/theme/spacing.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool showOnlineStatus = true;
  bool showLastSeen = true;
  bool allowMessages = true;
  bool allowProfileView = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text("Privacy Settings", style: theme.textTheme.titleLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s20,
          vertical: AppSpacing.s20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, "Visibility"),
            _toggleTile(
              context: context,
              icon: LucideIcons.eye,
              title: "Online Status",
              subtitle: "Allow students to see when you're online",
              value: showOnlineStatus,
              onChanged: (v) => setState(() => showOnlineStatus = v),
            ),
            _toggleTile(
              context: context,
              icon: LucideIcons.clock,
              title: "Last Seen",
              subtitle: "Allow students to see your last active time",
              value: showLastSeen,
              onChanged: (v) => setState(() => showLastSeen = v),
            ),

            const SizedBox(height: AppSpacing.s24),

            _sectionTitle(context, "Interactions"),
            _toggleTile(
              context: context,
              icon: LucideIcons.messageCircle,
              title: "Allow Messages",
              subtitle: "Students can message you anytime",
              value: allowMessages,
              onChanged: (v) => setState(() => allowMessages = v),
            ),
            _toggleTile(
              context: context,
              icon: LucideIcons.user,
              title: "Profile Visibility",
              subtitle: "Students can view your profile details",
              value: allowProfileView,
              onChanged: (v) => setState(() => allowProfileView = v),
            ),

            const SizedBox(height: AppSpacing.s24),

            _sectionTitle(context, "Blocked Students"),
            _blockedTile(context),

            const SizedBox(height: AppSpacing.s40),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // 📌 Section Title
  // ---------------------------------------------------------
  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  // ---------------------------------------------------------
  // 🔘 Toggle Tile
  // ---------------------------------------------------------
  Widget _toggleTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primary),
          ),

          const SizedBox(width: AppSpacing.s16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s4),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),

          Switch(value: value, onChanged: onChanged, activeThumbColor: primary),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 🚫 Blocked Users Tile
  // ---------------------------------------------------------
  Widget _blockedTile(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s16),
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
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
            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(LucideIcons.userX, color: theme.colorScheme.error),
            ),

            const SizedBox(width: AppSpacing.s16),

            Expanded(
              child: Text(
                "Blocked Students",
                style: theme.textTheme.titleMedium,
              ),
            ),

            Icon(Icons.chevron_right, color: theme.iconTheme.color),
          ],
        ),
      ),
    );
  }
}
