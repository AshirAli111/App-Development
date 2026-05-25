import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:next_step_learning/presentation/screens/student/tutor_profile_popup.dart';

import '../../../core/theme/spacing.dart';

class TutorDiscoveryScreen extends StatelessWidget {
  const TutorDiscoveryScreen({super.key});

  /// 🔹 Dummy Data (API ready)
  static final Map<String, List<Map<String, dynamic>>> tutorsBySubject = {
    "Mathematics": [
      {
        "name": "Ali Khan",
        "subject": "Mathematics",
        "rating": 4.9,
        "price": 12,
        "image": "https://i.pravatar.cc/150?img=12",
      },
      {
        "name": "Sara Noor",
        "subject": "Mathematics",
        "rating": 4.8,
        "price": 14,
        "image": "https://i.pravatar.cc/150?img=47",
      },
      {
        "name": "Bilal Ahmed",
        "subject": "Mathematics",
        "rating": 4.7,
        "price": 10,
        "image": "https://i.pravatar.cc/150?img=33",
      },
    ],

    "Physics": [
      {
        "name": "Ayesha Malik",
        "subject": "Physics",
        "rating": 4.9,
        "price": 15,
        "image": "https://i.pravatar.cc/150?img=48",
      },
      {
        "name": "Hamza Raza",
        "subject": "Physics",
        "rating": 4.6,
        "price": 11,
        "image": "https://i.pravatar.cc/150?img=21",
      },
      {
        "name": "Zain Abbas",
        "subject": "Physics",
        "rating": 4.5,
        "price": 13,
        "image": "https://i.pravatar.cc/150?img=18",
      },
    ],

    "Computer Science": [
      {
        "name": "Ahmed Raza",
        "subject": "Computer Science",
        "rating": 5.0,
        "price": 18,
        "image": "https://i.pravatar.cc/150?img=5",
      },
      {
        "name": "Noor Fatima",
        "subject": "Computer Science",
        "rating": 4.8,
        "price": 16,
        "image": "https://i.pravatar.cc/150?img=49",
      },
      {
        "name": "Usman Tariq",
        "subject": "Computer Science",
        "rating": 4.6,
        "price": 14,
        "image": "https://i.pravatar.cc/150?img=26",
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Find Tutors"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s20),
        children: tutorsBySubject.entries.map((entry) {
          return _subjectSection(
            context,
            subject: entry.key,
            tutors: entry.value,
          );
        }).toList(),
      ),
    );
  }

  // ------------------------------------------------------------------
  // SUBJECT SECTION
  // ------------------------------------------------------------------
  Widget _subjectSection(
    BuildContext context, {
    required String subject,
    required List<Map<String, dynamic>> tutors,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(subject, style: theme.textTheme.titleLarge),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/student_view_all_tutors',
                  arguments: {"subject": subject, "tutors": tutors},
                );
              },
              child: Text(
                "View All",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.s12),

        // Horizontal Tutors
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tutors.length > 3 ? 3 : tutors.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s12),
            itemBuilder: (_, i) {
              final tutor = tutors[i];
              return GestureDetector(
                onTap: () => showTutorProfilePopup(context, tutor),
                child: _TutorCard(tutor: tutor),
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.s32),
      ],
    );
  }
}

// ====================================================================
// TUTOR CARD (PRODUCTION READY)
// ====================================================================
class _TutorCard extends StatelessWidget {
  final Map<String, dynamic> tutor;
  const _TutorCard({required this.tutor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Center(
            child: CircleAvatar(
              radius: 33,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: .12),
              backgroundImage: tutor["image"] != null
                  ? NetworkImage(tutor["image"])
                  : null,
              child: tutor["image"] == null
                  ? Icon(LucideIcons.user, color: theme.colorScheme.primary)
                  : null,
            ),
          ),

          const SizedBox(height: AppSpacing.s12),

          // Name
          Center(
            child: Text(
              tutor["name"],
              style: theme.textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 4),

          // Subject
          Center(
            child: Text(tutor["subject"], style: theme.textTheme.bodySmall),
          ),

          const Spacer(),

          // Rating + Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          tutor["rating"].toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                "\$${tutor["price"]}/hr",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
