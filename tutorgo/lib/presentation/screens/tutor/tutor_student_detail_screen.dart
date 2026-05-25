import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/core/theme/typography.dart';

class TutorStudentDetailScreen extends StatelessWidget {
  final String name;
  final String grade;
  final double progress;
  final String? image;
  final int assignments;
  final String lastSession;

  const TutorStudentDetailScreen({
    super.key,
    required this.name,
    required this.grade,
    required this.progress,
    required this.assignments,
    required this.lastSession,
    this.image,
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
        title: Text(name, style: AppTypography.h2),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------ PROFILE CARD ------------------
            Container(
              padding: const EdgeInsets.all(AppSpacing.s20),
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
                    radius: 35,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: .12),
                    backgroundImage: image != null
                        ? NetworkImage(image!)
                        : null,
                    child: image == null
                        ? Icon(
                            LucideIcons.user,
                            size: 32,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                  ),

                  const SizedBox(width: AppSpacing.s16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppTypography.h2),
                        Text(
                          grade,
                          style: AppTypography.body14.copyWith(
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s12),

                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: theme.dividerColor.withValues(alpha: .3),
                          color: theme.colorScheme.primary,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s32),

            // ------------------ QUICK ACTIONS ------------------
            Text("Quick Actions", style: AppTypography.h3),
            const SizedBox(height: AppSpacing.s16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _quickAction(context, LucideIcons.messageCircle, "Message"),
                _quickAction(context, LucideIcons.phone, "Call"),
                _quickAction(context, LucideIcons.video, "Video"),
                _quickAction(context, LucideIcons.stickyNote, "Add Note"),
              ],
            ),

            const SizedBox(height: AppSpacing.s32),

            // ------------------ ASSIGNMENTS ------------------
            Text("Assignments", style: AppTypography.h3),
            const SizedBox(height: AppSpacing.s16),

            assignments == 0
                ? _emptyState(context, "No assignments given yet")
                : Column(
                    children: [
                      _assignmentCard(
                        context,
                        "Algebra Practice Test",
                        "Due: Tomorrow",
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      if (assignments > 1)
                        _assignmentCard(
                          context,
                          "Physics Worksheet",
                          "Due: Monday",
                        ),
                    ],
                  ),

            const SizedBox(height: AppSpacing.s32),

            // ------------------ SESSION HISTORY ------------------
            Text("Session History", style: AppTypography.h3),
            const SizedBox(height: AppSpacing.s16),

            _historyTile(context, "Math – Algebra", "Completed • Yesterday"),
            _historyTile(
              context,
              "Physics – Chapter 4",
              "Completed • 4 days ago",
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // QUICK ACTION BUTTON
  // ---------------------------------------------------
  Widget _quickAction(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: .15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(label, style: AppTypography.body14),
      ],
    );
  }

  // ---------------------------------------------------
  // ASSIGNMENT CARD
  // ---------------------------------------------------
  Widget _assignmentCard(BuildContext context, String title, String subtitle) {
    final theme = Theme.of(context);

    return Container(
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
          Icon(LucideIcons.bookOpen, color: theme.colorScheme.secondary),
          const SizedBox(width: AppSpacing.s12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.h3),
                Text(
                  subtitle,
                  style: AppTypography.body14.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // SESSION HISTORY TILE
  // ---------------------------------------------------
  Widget _historyTile(BuildContext context, String title, String subtitle) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
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
          Icon(LucideIcons.clock, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.s12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.h3),
                Text(
                  subtitle,
                  style: AppTypography.body14.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // EMPTY TEXT STATE
  // ---------------------------------------------------
  Widget _emptyState(BuildContext context, String text) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
      child: Center(
        child: Text(
          text,
          style: AppTypography.body16.copyWith(
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}
