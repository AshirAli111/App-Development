import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/user_service.dart';

import 'package:next_step_learning/core/constants/courses.dart';
import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/core/utils/image_utils.dart';

class TutorEditProfileScreen extends StatefulWidget {
  const TutorEditProfileScreen({super.key});

  @override
  State<TutorEditProfileScreen> createState() => _TutorEditProfileScreenState();
}

class _TutorEditProfileScreenState extends State<TutorEditProfileScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final customCourseCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  final rateCtrl = TextEditingController();
  final _picker = ImagePicker();
  bool _isLoading = true;
  bool _isSaving = false;

  /// Courses this tutor teaches (fixed list + any custom ones they added).
  final List<String> _subjects = [];

  /// Newly picked avatar (not yet saved).
  File? _pickedImage;

  /// Existing avatar value from the backend (URL or base64).
  String? _existingImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final auth = context.read<AuthProvider>();
    final userService = UserService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
    );

    final profile = await userService.getMyProfile();
    if (mounted && profile != null) {
      setState(() {
        nameCtrl.text = profile['fullName'] ?? '';
        emailCtrl.text = profile['email'] ?? '';
        final subjects =
            (profile['tutorProfile']?['subjects'] as List<dynamic>?) ?? [];
        _subjects
          ..clear()
          ..addAll(subjects.map((s) => s.toString()));
        bioCtrl.text = profile['tutorProfile']?['bio'] ?? '';
        rateCtrl.text =
            profile['tutorProfile']?['pricePerHourPKR']?.toString() ?? '';
        _existingImage = profile['profileImage'] as String?;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _saveProfile() async {
    final email = emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final auth = context.read<AuthProvider>();
    final userService = UserService(
      baseUrl: auth.baseUrl,
      token: auth.accessToken,
      userId: auth.userId,
    );

    final updates = <String, dynamic>{
      'fullName': nameCtrl.text.trim(),
      'email': email,
      'tutorProfile': {
        'subjects': _subjects,
        'bio': bioCtrl.text.trim(),
        'pricePerHourPKR': int.tryParse(rateCtrl.text.trim()) ?? 0,
      },
    };

    // Include the newly picked avatar (base64, max 2MB).
    if (_pickedImage != null) {
      final bytes = await _pickedImage!.readAsBytes();
      if (bytes.length > 2 * 1024 * 1024) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image too large (max 2MB)')),
          );
        }
        return;
      }
      updates['profileImage'] = base64Encode(bytes);
    }

    final result = await userService.updateProfile(updates);

    if (mounted) {
      setState(() => _isSaving = false);
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    customCourseCtrl.dispose();
    bioCtrl.dispose();
    rateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Edit Profile", style: theme.textTheme.titleLarge),
        backgroundColor: theme.cardColor,
        elevation: 0.4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor:
                              theme.colorScheme.primary.withValues(alpha: .12),
                          backgroundImage: _pickedImage != null
                              ? FileImage(_pickedImage!)
                              : profileImageProvider(_existingImage),
                          child: (_pickedImage == null &&
                                  profileImageProvider(_existingImage) == null)
                              ? Icon(Icons.person,
                                  size: 52, color: theme.colorScheme.primary)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _isSaving ? null : _pickImage,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: theme.colorScheme.primary,
                              child: const Icon(Icons.camera_alt,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  _field(context, "Full Name", nameCtrl),
                  const SizedBox(height: AppSpacing.s16),
                  _field(context, "Email", emailCtrl),
                  const SizedBox(height: AppSpacing.s16),
                  _coursesSection(context),
                  const SizedBox(height: AppSpacing.s16),
                  _field(context, "Rate (PKR / hour)", rateCtrl,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: AppSpacing.s16),
                  _field(context, "Bio", bioCtrl, maxLines: 3),
                  const SizedBox(height: AppSpacing.s32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isSaving ? null : _saveProfile,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text("Save Changes",
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _addCustomCourse() {
    final course = customCourseCtrl.text.trim();
    if (course.isEmpty) return;
    setState(() {
      if (!_subjects.any((s) => s.toLowerCase() == course.toLowerCase())) {
        _subjects.add(course);
      }
      customCourseCtrl.clear();
    });
  }

  Widget _coursesSection(BuildContext context) {
    final theme = Theme.of(context);
    // Fixed list first, then any custom courses the tutor already has.
    final allChips = <String>[
      ...kCourses,
      ..._subjects.where((s) => !kCourses.contains(s)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Courses I Teach", style: theme.textTheme.bodyLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allChips.map((course) {
            final selected = _subjects.contains(course);
            return FilterChip(
              label: Text(course),
              selected: selected,
              onSelected: _isSaving
                  ? null
                  : (val) {
                      setState(() {
                        if (val) {
                          _subjects.add(course);
                        } else {
                          _subjects.remove(course);
                        }
                      });
                    },
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: customCourseCtrl,
                enabled: !_isSaving,
                decoration: InputDecoration(
                  hintText: "Add a custom course",
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                ),
                onSubmitted: (_) => _addCustomCourse(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _isSaving ? null : _addCustomCourse,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _field(BuildContext context, String label, TextEditingController ctrl,
      {bool enabled = true, int maxLines = 1, TextInputType? keyboardType}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.cardColor,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}
