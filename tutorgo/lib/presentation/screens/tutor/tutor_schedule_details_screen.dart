import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/core/theme/typography.dart';
import 'package:next_step_learning/routes/app_routes.dart';

class TutorScheduleDetailsScreen extends StatelessWidget {
  final String subject;
  final String student;
  final String time;
  final Color color;

  const TutorScheduleDetailsScreen({
    super.key,
    required this.subject,
    required this.student,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text("Session Details", style: AppTypography.h2),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(context),
            const SizedBox(height: AppSpacing.s24),

            _infoCard(
              context,
              icon: LucideIcons.user,
              title: "Student",
              value: student,
            ),
            _infoCard(
              context,
              icon: LucideIcons.clock,
              title: "Time",
              value: time,
            ),
            _infoCard(
              context,
              icon: LucideIcons.mapPin,
              title: "Mode",
              value: "Online Class",
            ),
            _infoCard(
              context,
              icon: LucideIcons.bookOpen,
              title: "Topic",
              value: subject,
            ),

            const SizedBox(height: AppSpacing.s32),
            _notesCard(context),

            const SizedBox(height: AppSpacing.s32),
            _actionButtons(context),

            const SizedBox(height: AppSpacing.s40),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // HEADER CARD
  // ---------------------------------------------------------
  Widget _headerCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: const Icon(LucideIcons.bookOpen, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: AppTypography.h2.copyWith(color: color)),
                const SizedBox(height: 4),
                Text(
                  "With $student",
                  style: AppTypography.body16.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // INFO CARD
  // ---------------------------------------------------------
  Widget _infoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
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
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Text(
              "$title: $value",
              style: AppTypography.body16.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // NOTES CARD
  // ---------------------------------------------------------
  Widget _notesCard(BuildContext context) {
    final theme = Theme.of(context);
    final warning = theme.colorScheme.tertiary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: warning.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warning.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Notes", style: AppTypography.h3.copyWith(color: warning)),
          const SizedBox(height: AppSpacing.s8),
          Text(
            "Prepare chapter 4 exercises for this class. Share PDF summary at the end.",
            style: AppTypography.body14.copyWith(color: warning, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // ACTION BUTTONS
  // ---------------------------------------------------------
  Widget _actionButtons(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.tutorVideoCall);
            },
            icon: const Icon(Icons.play_circle, color: Colors.white),
            label: Text(
              "Start Online Class",
              style: AppTypography.body16.copyWith(color: Colors.white),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.s16),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.dividerColor),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Reschedule",
                  style: AppTypography.body16.copyWith(
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.s16),

            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.colorScheme.error),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Cancel",
                  style: AppTypography.body16.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
