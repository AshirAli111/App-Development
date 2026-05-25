import 'package:flutter/material.dart';

import 'package:next_step_learning/core/theme/spacing.dart';

class TutorEditProfileScreen extends StatefulWidget {
  const TutorEditProfileScreen({super.key});

  @override
  State<TutorEditProfileScreen> createState() => _TutorEditProfileScreenState();
}

class _TutorEditProfileScreenState extends State<TutorEditProfileScreen> {
  final TextEditingController nameCtrl = TextEditingController(
    text: "Ali Khan",
  );
  final TextEditingController emailCtrl = TextEditingController(
    text: "ali.khan@example.com",
  );
  final TextEditingController subjectCtrl = TextEditingController(
    text: "Mathematics, Physics",
  );
  final TextEditingController bioCtrl = TextEditingController(
    text: "Experienced tutor with 5+ years of teaching.",
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text("Edit Profile", style: theme.textTheme.titleLarge),
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s20,
            vertical: AppSpacing.s24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatarSection(context),
              const SizedBox(height: AppSpacing.s24),

              _label(context, "Full Name"),
              _input(context, nameCtrl),
              const SizedBox(height: AppSpacing.s20),

              _label(context, "Email Address"),
              _input(context, emailCtrl),
              const SizedBox(height: AppSpacing.s20),

              _label(context, "Subjects You Teach"),
              _input(context, subjectCtrl),
              const SizedBox(height: AppSpacing.s20),

              _label(context, "Short Bio"),
              _input(context, bioCtrl, maxLines: 3),
              const SizedBox(height: AppSpacing.s32),

              _saveButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // 🟦 Avatar + Edit Button
  // -----------------------------------------------------------
  Widget _avatarSection(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: .12),
            child: Icon(
              Icons.person_rounded,
              size: 60,
              color: theme.colorScheme.primary,
            ),
          ),

          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // 🔖 Form Label
  // -----------------------------------------------------------
  Widget _label(BuildContext context, String text) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  // -----------------------------------------------------------
  // 📝 Input Field
  // -----------------------------------------------------------
  Widget _input(
    BuildContext context,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // 🔵 SAVE BUTTON
  // -----------------------------------------------------------
  Widget _saveButton(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            "Save Changes",
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
