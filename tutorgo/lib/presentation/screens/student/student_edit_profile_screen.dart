import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/user_service.dart';

import '../../../core/constants/courses.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/image_utils.dart';

class StudentEditProfileScreen extends StatefulWidget {
  const StudentEditProfileScreen({super.key});

  @override
  State<StudentEditProfileScreen> createState() =>
      _StudentEditProfileScreenState();
}

class _StudentEditProfileScreenState extends State<StudentEditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _picker = ImagePicker();
  bool _isLoading = true;
  bool _isSaving = false;

  /// Newly picked avatar (not yet saved).
  File? _pickedImage;

  /// Existing avatar value from the backend (URL or base64).
  String? _existingImage;

  /// Courses the student is interested in (picked from the fixed list).
  final List<String> _selectedCourses = [];

  /// Courses offered to the student: the fixed list + any custom courses that
  /// tutors currently teach (kept while at least one tutor offers them).
  List<String> _availableCourses = List.of(kCourses);

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
    final tutors = await userService.getTutors(limit: 100);

    // Collect every course tutors currently teach (includes custom ones).
    final tutorCourses = <String>{};
    for (final t in tutors) {
      final subjects = (t['tutorProfile']?['subjects'] as List?) ?? [];
      tutorCourses.addAll(subjects.map((s) => s.toString()));
    }

    if (mounted && profile != null) {
      final selected = List<String>.from(
          (profile['studentProfile']?['selectedCourses'] as List?) ?? []);
      setState(() {
        _nameController.text = profile['fullName'] ?? '';
        _emailController.text = profile['email'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
        _existingImage = profile['profileImage'] as String?;
        _selectedCourses
          ..clear()
          ..addAll(selected);
        // Fixed list + tutor (custom) courses + anything already selected.
        _availableCourses = <String>[
          ...kCourses,
          ...tutorCourses.where((c) => !kCourses.contains(c)),
          ...selected.where(
              (c) => !kCourses.contains(c) && !tutorCourses.contains(c)),
        ];
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
    final email = _emailController.text.trim();
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
      'fullName': _nameController.text.trim(),
      'email': email,
      'phone': _phoneController.text.trim(),
      'studentProfile': {
        'selectedCourses': _selectedCourses,
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Edit Profile",
            style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: .12),
                          backgroundImage: _pickedImage != null
                              ? FileImage(_pickedImage!)
                              : profileImageProvider(_existingImage),
                          child: (_pickedImage == null &&
                                  profileImageProvider(_existingImage) == null)
                              ? Icon(Icons.person,
                                  size: 52,
                                  color: Theme.of(context).colorScheme.primary)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _isSaving ? null : _pickImage,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: const Icon(Icons.camera_alt,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  _inputField(context, "Full Name", _nameController),
                  const SizedBox(height: AppSpacing.s16),
                  _inputField(context, "Email", _emailController),
                  const SizedBox(height: AppSpacing.s16),
                  _inputField(context, "Phone Number", _phoneController),
                  const SizedBox(height: AppSpacing.s24),
                  Text("My Courses",
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableCourses.map((course) {
                      final selected = _selectedCourses.contains(course);
                      return FilterChip(
                        label: Text(course),
                        selected: selected,
                        onSelected: _isSaving
                            ? null
                            : (val) {
                                setState(() {
                                  if (val) {
                                    _selectedCourses.add(course);
                                  } else {
                                    _selectedCourses.remove(course);
                                  }
                                });
                              },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.s32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _inputField(BuildContext context, String label,
      TextEditingController controller,
      {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}
