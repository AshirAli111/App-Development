import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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

  // Dummy data
  final Map<String, List<Map<String, dynamic>>> schedule = {
    "Mon": [
      {
        "time": "09:00 AM",
        "subject": "Mathematics",
        "student": "Ayesha",
        "color": Colors.blue,
      },
      {
        "time": "02:00 PM",
        "subject": "Physics",
        "student": "Bilal",
        "color": Colors.orange,
      },
    ],
    "Tue": [
      {
        "time": "11:00 AM",
        "subject": "Chemistry",
        "student": "Zain",
        "color": Colors.deepPurple,
      },
    ],
    "Wed": [
      {
        "time": "01:00 PM",
        "subject": "Biology",
        "student": "Sara",
        "color": Colors.blue,
      },
      {
        "time": "04:00 PM",
        "subject": "English",
        "student": "Hamza",
        "color": Colors.green,
      },
    ],
    "Thu": [],
    "Fri": [
      {
        "time": "03:00 PM",
        "subject": "Computer Science",
        "student": "Ahmed",
        "color": Colors.pink,
      },
    ],
    "Sat": [],
    "Sun": [],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedDay = days[selectedDayIndex];
    final sessions = schedule[selectedDay] ?? [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text("Schedule", style: AppTypography.h2),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dayTabs(context),
          const SizedBox(height: AppSpacing.s20),

          /// SESSION LIST
          Expanded(
            child: sessions.isEmpty
                ? _emptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s20,
                    ),
                    itemCount: sessions.length,
                    itemBuilder: (context, i) {
                      final s = sessions[i];
                      return _sessionCard(
                        context,
                        time: s["time"],
                        subject: s["subject"],
                        student: s["student"],
                        color: s["color"],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // DAY TABS
  // ---------------------------------------------------------
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
                horizontal: 6,
                vertical: AppSpacing.s12,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s20,
                vertical: AppSpacing.s12,
              ),
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

  // ---------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------
  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.calendarX,
            size: 52,
            color: theme.iconTheme.color?.withValues(alpha: .6),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            "No sessions scheduled for today",
            style: AppTypography.body16.copyWith(
              color: theme.textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // SESSION CARD
  // ---------------------------------------------------------
  Widget _sessionCard(
    BuildContext context, {
    required String time,
    required String subject,
    required String student,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.tutorScheduleDetails,
          arguments: {
            "time": time,
            "subject": subject,
            "student": student,
            "color": color,
          },
        );
      },
      child: Container(
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
        child: Row(
          children: [
            /// Time Circle
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withValues(alpha: .18),
              child: Text(
                time,
                textAlign: TextAlign.center,
                style: AppTypography.body12.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.s16),

            /// Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: AppTypography.h3.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "With $student",
                    style: AppTypography.body14.copyWith(
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              LucideIcons.chevronRight,
              color: theme.iconTheme.color,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
