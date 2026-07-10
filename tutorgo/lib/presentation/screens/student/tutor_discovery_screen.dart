import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/user_service.dart';
import 'package:next_step_learning/core/utils/image_utils.dart';
import 'package:next_step_learning/presentation/screens/student/tutor_profile_popup.dart';

import '../../../core/theme/spacing.dart';

class TutorDiscoveryScreen extends StatefulWidget {
  const TutorDiscoveryScreen({super.key});

  @override
  State<TutorDiscoveryScreen> createState() => _TutorDiscoveryScreenState();
}

class _TutorDiscoveryScreenState extends State<TutorDiscoveryScreen> {
  List<Map<String, dynamic>> _tutors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTutors();
  }

  Future<void> _loadTutors() async {
    final auth = context.read<AuthProvider>();
    final userService = UserService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
    );

    final tutors = await userService.getTutors(limit: 50);

    if (mounted) {
      setState(() {
        _tutors = tutors;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Group tutors by subject
    final tutorsBySubject = <String, List<Map<String, dynamic>>>{};
    for (final tutor in _tutors) {
      final subjects = tutor['tutorProfile']?['subjects'] as List<dynamic>? ?? [];
      final name = tutor['fullName'] ?? 'Tutor';
      final id = tutor['id'] ?? '';

      for (final subject in subjects) {
        tutorsBySubject.putIfAbsent(subject.toString(), () => []);
        tutorsBySubject[subject.toString()]!.add({
          'id': id,
          'name': name,
          'subject': subject.toString(),
          'rating': tutor['tutorProfile']?['rating'] ?? 0.0,
          'price': tutor['tutorProfile']?['pricePerHourPKR'] ?? 0,
          'image': tutor['profileImage'],
          'experience': tutor['tutorProfile']?['experienceYears'] ?? 0,
          'qualification': tutor['tutorProfile']?['qualification'] ?? '',
          'bio': tutor['tutorProfile']?['bio'] ?? '',
        });
      }

      // If no subjects, still show the tutor
      if (subjects.isEmpty) {
        tutorsBySubject.putIfAbsent('General', () => []);
        tutorsBySubject['General']!.add({
          'id': id,
          'name': name,
          'subject': 'General',
          'rating': tutor['tutorProfile']?['rating'] ?? 0.0,
          'price': tutor['tutorProfile']?['pricePerHourPKR'] ?? 0,
          'image': tutor['profileImage'],
          'experience': tutor['tutorProfile']?['experienceYears'] ?? 0,
          'qualification': tutor['tutorProfile']?['qualification'] ?? '',
          'bio': tutor['tutorProfile']?['bio'] ?? '',
        });
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Find Tutors"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tutors.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.users2, size: 48,
                          color: theme.textTheme.bodySmall?.color),
                      const SizedBox(height: 16),
                      Text("No tutors available yet",
                          style: theme.textTheme.bodyLarge),
                    ],
                  ),
                )
              : ListView(
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

  Widget _subjectSection(
    BuildContext context, {
    required String subject,
    required List<Map<String, dynamic>> tutors,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        SizedBox(
          height: 200,
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
          Center(
            child: CircleAvatar(
              radius: 33,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: .12),
              backgroundImage: profileImageProvider(tutor["image"]),
              child: profileImageProvider(tutor["image"]) == null
                  ? Icon(LucideIcons.user, color: theme.colorScheme.primary)
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Center(
            child: Text(
              tutor["name"] ?? '',
              style: theme.textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              tutor["subject"] ?? '',
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      (tutor["rating"] ?? 0.0).toString(),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (tutor["price"] != null && tutor["price"] != 0)
                Text(
                  "PKR ${tutor["price"]}/hr",
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
