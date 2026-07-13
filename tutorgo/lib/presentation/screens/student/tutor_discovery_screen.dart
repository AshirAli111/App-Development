import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/user_service.dart';
import 'package:next_step_learning/core/utils/image_utils.dart';
import 'package:next_step_learning/presentation/screens/student/tutor_profile_popup.dart';

import '../../../core/theme/spacing.dart';

// Special filter sentinels for the course chip row.
const _kFilterMyCourses = '__my__';
const _kFilterAll = '__all__';

class TutorDiscoveryScreen extends StatefulWidget {
  const TutorDiscoveryScreen({super.key});

  @override
  State<TutorDiscoveryScreen> createState() => _TutorDiscoveryScreenState();
}

class _TutorDiscoveryScreenState extends State<TutorDiscoveryScreen> {
  List<Map<String, dynamic>> _tutors = [];
  List<String> _studentCourses = [];
  String _filter = _kFilterAll;
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
    final profile = await userService.getMyProfile();
    final courses = List<String>.from(
        (profile?['studentProfile']?['selectedCourses'] as List?) ?? []);

    if (mounted) {
      setState(() {
        _tutors = tutors;
        _studentCourses = courses;
        // Default to the student's own courses when they have any.
        _filter = courses.isNotEmpty ? _kFilterMyCourses : _kFilterAll;
        _isLoading = false;
      });
    }
  }

  /// Which subject sections to show, given the active filter.
  bool _sectionVisible(String subject) {
    if (_filter == _kFilterAll) return true;
    if (_filter == _kFilterMyCourses) return _studentCourses.contains(subject);
    return subject == _filter;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Group tutors by subject
    final tutorsBySubject = <String, List<Map<String, dynamic>>>{};
    for (final tutor in _tutors) {
      final subjects = tutor['tutorProfile']?['subjects'] as List<dynamic>? ?? [];
      final courses = subjects.map((s) => s.toString()).toList();
      final name = tutor['fullName'] ?? 'Tutor';
      final id = tutor['id'] ?? '';

      Map<String, dynamic> cardFor(String subject) => {
            'id': id,
            'name': name,
            'subject': subject,
            'courses': courses,
            'rating': tutor['tutorProfile']?['rating'] ?? 0.0,
            'price': tutor['tutorProfile']?['pricePerHourPKR'] ?? 0,
            'image': tutor['profileImage'],
            'experience': tutor['tutorProfile']?['experienceYears'] ?? 0,
            'qualification': tutor['tutorProfile']?['qualification'] ?? '',
            'bio': tutor['tutorProfile']?['bio'] ?? '',
          };

      for (final subject in courses) {
        tutorsBySubject.putIfAbsent(subject, () => []);
        tutorsBySubject[subject]!.add(cardFor(subject));
      }

      // If no subjects, still show the tutor under "General"
      if (courses.isEmpty) {
        tutorsBySubject.putIfAbsent('General', () => []);
        tutorsBySubject['General']!.add(cardFor('General'));
      }
    }

    final visibleSections = tutorsBySubject.entries
        .where((e) => _sectionVisible(e.key))
        .toList();

    // Filter chips: student's courses first, then any other course a tutor
    // teaches (so custom courses are filterable & bookable).
    final chipCourses = <String>[
      ..._studentCourses,
      ...tutorsBySubject.keys
          .where((k) => k != 'General' && !_studentCourses.contains(k)),
    ];

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
              : Column(
                  children: [
                    _filterChips(context, chipCourses),
                    Expanded(
                      child: visibleSections.isEmpty
                          ? Center(
                              child: Text(
                                "No tutors for the selected course yet",
                                style: theme.textTheme.bodyLarge,
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.all(AppSpacing.s20),
                              children: visibleSections.map((entry) {
                                return _subjectSection(
                                  context,
                                  subject: entry.key,
                                  tutors: entry.value,
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _filterChips(BuildContext context, List<String> courses) {
    final chips = <MapEntry<String, String>>[
      if (_studentCourses.isNotEmpty)
        const MapEntry(_kFilterMyCourses, 'My Courses'),
      const MapEntry(_kFilterAll, 'All Courses'),
      for (final c in courses) MapEntry(c, c),
    ];

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final entry = chips[i];
          final selected = _filter == entry.key;
          return Center(
            child: ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (_) => setState(() => _filter = entry.key),
            ),
          );
        },
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
                  mainAxisSize: MainAxisSize.min,
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
              if (tutor["price"] != null && tutor["price"] != 0) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    "PKR ${tutor["price"]}/hr",
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
