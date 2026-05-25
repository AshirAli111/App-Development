import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/core/theme/typography.dart';
import 'package:next_step_learning/routes/app_routes.dart';

class TutorStudentsScreen extends StatelessWidget {
  TutorStudentsScreen({super.key});

  final List<Map<String, dynamic>> students = [
    {
      "name": "Ayesha",
      "grade": "Grade 9",
      "progress": 0.82,
      "image": null,
      "lastSession": "Yesterday",
      "assignments": 2,
    },
    {
      "name": "Bilal",
      "grade": "Grade 10",
      "progress": 0.67,
      "image": null,
      "lastSession": "3 days ago",
      "assignments": 1,
    },
    {
      "name": "Sara",
      "grade": "Grade 11",
      "progress": 0.51,
      "image": null,
      "lastSession": "Today",
      "assignments": 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text("My Students", style: AppTypography.h2),
      ),

      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.s20),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final s = students[index];

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.tutorStudentDetails,
                arguments: s,
              );
            },

            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.s16),
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
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: .12),
                    backgroundImage: s["image"] != null
                        ? NetworkImage(s["image"])
                        : null,
                    child: s["image"] == null
                        ? Icon(
                            LucideIcons.user,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                  ),

                  const SizedBox(width: AppSpacing.s16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s["name"], style: AppTypography.h3),

                        Text(
                          s["grade"],
                          style: AppTypography.body14.copyWith(
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.s8),

                        LinearProgressIndicator(
                          value: s["progress"],
                          backgroundColor: theme.dividerColor.withValues(alpha: .3),
                          color: theme.colorScheme.primary,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        s["lastSession"],
                        style: AppTypography.body12.copyWith(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.s8),

                      if (s["assignments"] > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${s["assignments"]} tasks",
                            style: AppTypography.body12.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
