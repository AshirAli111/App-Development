import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/session_service.dart';

import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/core/theme/typography.dart';
import 'package:next_step_learning/core/utils/image_utils.dart';
import 'package:next_step_learning/routes/app_routes.dart';

class TutorStudentsScreen extends StatefulWidget {
  const TutorStudentsScreen({super.key});

  @override
  State<TutorStudentsScreen> createState() => _TutorStudentsScreenState();
}

class _TutorStudentsScreenState extends State<TutorStudentsScreen> {
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final auth = context.read<AuthProvider>();
    final sessionService = SessionService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
      role: auth.role,
    );

    final sessions = await sessionService.getMySessions();

    // Derive unique students from sessions
    final studentMap = <String, Map<String, dynamic>>{};
    for (final s in sessions) {
      final studentId = s['studentId'] as String? ?? '';
      final studentName = s['studentName'] as String? ?? 'Student';
      if (studentId.isNotEmpty && !studentMap.containsKey(studentId)) {
        studentMap[studentId] = {
          'id': studentId,
          'name': studentName,
          'subject': s['subject'] ?? '',
          'status': s['status'] ?? '',
          'image': s['studentImage'],
        };
      }
    }

    if (mounted) {
      setState(() {
        _students = studentMap.values.toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text("My Students", style: AppTypography.h2),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.users2, size: 48,
                          color: theme.iconTheme.color?.withValues(alpha: .6)),
                      const SizedBox(height: 16),
                      Text("No students yet",
                          style: AppTypography.body16),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s20, vertical: AppSpacing.s12),
                  itemCount: _students.length,
                  itemBuilder: (_, i) {
                    final student = _students[i];
                    return _studentCard(context, student);
                  },
                ),
    );
  }

  Widget _studentCard(BuildContext context, Map<String, dynamic> student) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.tutorStudentDetails,
          arguments: {
            "studentId": student['id'],
            "name": student['name'],
            "grade": student['subject'],
            "image": student['image'],
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
            Builder(
              builder: (context) {
                final avatar = profileImageProvider(student['image']);
                return CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: .12),
                  backgroundImage: avatar,
                  child: avatar == null
                      ? Icon(LucideIcons.user,
                          color: theme.colorScheme.primary)
                      : null,
                );
              },
            ),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student['name'] ?? '',
                      style: theme.textTheme.titleMedium),
                  Text(student['subject'] ?? '',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight,
                color: theme.iconTheme.color, size: 22),
          ],
        ),
      ),
    );
  }
}
