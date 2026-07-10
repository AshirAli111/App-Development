import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/session_service.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/utils/image_utils.dart';

class StudentTutorsScreen extends StatefulWidget {
  const StudentTutorsScreen({super.key});

  @override
  State<StudentTutorsScreen> createState() => _StudentTutorsScreenState();
}

class _StudentTutorsScreenState extends State<StudentTutorsScreen> {
  List<Map<String, dynamic>> _tutors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTutors();
  }

  Future<void> _loadTutors() async {
    final auth = context.read<AuthProvider>();
    final sessionService = SessionService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
      role: auth.role,
    );

    final sessions = await sessionService.getMySessions();

    // Only the tutors this student has actually booked (unique by tutorId).
    final tutorMap = <String, Map<String, dynamic>>{};
    for (final s in sessions) {
      final tutorId = s['tutorId'] as String? ?? '';
      final tutorName = s['tutorName'] as String? ?? 'Tutor';
      if (tutorId.isNotEmpty && !tutorMap.containsKey(tutorId)) {
        tutorMap[tutorId] = {
          'name': tutorName,
          'subject': s['subject'] ?? '',
          'image': s['tutorImage'],
        };
      }
    }

    if (mounted) {
      setState(() {
        _tutors = tutorMap.values.toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("My Tutors", style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tutors.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.users2, size: 48,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              ?.withValues(alpha: .6)),
                      const SizedBox(height: 16),
                      Text("No tutors booked yet",
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  itemCount: _tutors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, i) {
                    final t = _tutors[i];
                    final avatar = profileImageProvider(t['image']);

                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .shadowColor
                                .withValues(alpha: .15),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.14),
                            backgroundImage: avatar,
                            child: avatar == null
                                ? Icon(
                                    LucideIcons.user,
                                    color: Theme.of(context).colorScheme.primary,
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.s16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (t["name"] ?? '').toString(),
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  (t["subject"] ?? '').toString(),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
