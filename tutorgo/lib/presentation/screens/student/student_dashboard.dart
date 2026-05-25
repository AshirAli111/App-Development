import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../routes/app_routes.dart';
import '../aichat/ai_chat_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);

    // ✅ only colors dynamic
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

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context, textPrimary, textSecondary),
              const SizedBox(height: AppSpacing.s20),

              _dailyGoal(context),
              const SizedBox(height: AppSpacing.s28),

              Text(
                "Continue Learning",
                style: AppTypography.h3.copyWith(color: textPrimary),
              ),
              const SizedBox(height: AppSpacing.s12),
              _courseProgressCards(
                context,
                card,
                border,
                textPrimary,
                textSecondary,
              ),

              const SizedBox(height: AppSpacing.s28),
              Text(
                "Flashcards of the Day",
                style: AppTypography.h3.copyWith(color: textPrimary),
              ),
              const SizedBox(height: AppSpacing.s12),
              _flashcards(context, card, border, textPrimary, textSecondary),

              const SizedBox(height: AppSpacing.s28),
              Text(
                "Upcoming Class",
                style: AppTypography.h3.copyWith(color: textPrimary),
              ),
              const SizedBox(height: AppSpacing.s12),
              _upcomingClass(context, card, border, textPrimary, textSecondary),

              const SizedBox(height: AppSpacing.s28),
              Text(
                "Your Tutors",
                style: AppTypography.h3.copyWith(color: textPrimary),
              ),
              const SizedBox(height: AppSpacing.s12),
              _yourTutors(context, textPrimary),

              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "ai_student_fab",
        tooltip: "Ask AI Tutor",
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.aiChatScreen,
            arguments: AiRole.student,
          );
        },
        icon: const Icon(LucideIcons.sparkles),
        label: const Text("AI Tutor"),
      ),
    );
  }

  // ----------------------------------------------------------
  // HEADER
  // ----------------------------------------------------------
  Widget _header(BuildContext context, Color textPrimary, Color textSecondary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi, Student 👋",
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
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.12),
          child: Icon(
            LucideIcons.user,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // DAILY GOAL (same as original)
  // ----------------------------------------------------------
  Widget _dailyGoal(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary, // ✅ theme primary
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Daily Goal",
            style: AppTypography.h3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            "Study 45 minutes today",
            style: AppTypography.body14.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.38,
            color: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            minHeight: 5,
            borderRadius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 6),
          Text(
            "38% completed",
            style: AppTypography.body12.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // COURSE PROGRESS CARDS
  // ----------------------------------------------------------
  Widget _courseProgressCards(
    BuildContext context,
    Color card,
    Color border,
    Color textPrimary,
    Color textSecondary,
  ) {
    final items = [
      {"title": "Algebra Basics", "progress": 0.70},
      {"title": "Intro to Physics", "progress": 0.45},
    ];

    return Column(
      children: items.map((c) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.12),
                child: Icon(
                  LucideIcons.bookOpen,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c["title"].toString(),
                      style: AppTypography.h3.copyWith(color: textPrimary),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: c["progress"] as double,
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.primary,
                      backgroundColor: border,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${((c["progress"] as double) * 100).toInt()}%",
                style: AppTypography.body14.copyWith(color: textSecondary),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ----------------------------------------------------------
  // FLASHCARDS
  // ----------------------------------------------------------
  Widget _flashcards(
    BuildContext context,
    Color card,
    Color border,
    Color textPrimary,
    Color textSecondary,
  ) {
    final cards = [
      {"term": "Photosynthesis", "meaning": "Process plants use to make food"},
      {"term": "Gravity", "meaning": "Force that pulls objects downward"},
      {"term": "Equation", "meaning": "Statement showing equality"},
    ];

    return SizedBox(
      height: 115,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: cards.length,
        itemBuilder: (_, i) {
          return Container(
            width: 165,
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cards[i]["term"]!,
                  style: AppTypography.h3.copyWith(color: textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  cards[i]["meaning"]!,
                  style: AppTypography.body12.copyWith(color: textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------
  // UPCOMING CLASS
  // ----------------------------------------------------------
  Widget _upcomingClass(
    BuildContext context,
    Color card,
    Color border,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.18),
            child: Icon(
              LucideIcons.video,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Math Live Session",
                style: AppTypography.h3.copyWith(color: textPrimary),
              ),
              Text(
                "Today • 4:30 PM",
                style: AppTypography.body14.copyWith(color: textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // YOUR TUTORS
  // ----------------------------------------------------------
  Widget _yourTutors(BuildContext context, Color textPrimary) {
    final tutors = ["Ayesha", "Bilal", "Sara"];

    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: tutors.length,
        itemBuilder: (_, i) {
          return Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.12),
                child: Icon(
                  LucideIcons.user,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                tutors[i],
                style: AppTypography.body12.copyWith(color: textPrimary),
              ),
            ],
          );
        },
      ),
    );
  }
}
