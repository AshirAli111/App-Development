import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/user_service.dart';

import '../../../core/utils/size_config.dart';
import '../../components/animations/fade_in.dart';
import '../../../routes/app_routes.dart';

class StudentProfileSetup extends StatefulWidget {
  const StudentProfileSetup({super.key});

  @override
  State<StudentProfileSetup> createState() => _StudentProfileSetupState();
}

class _StudentProfileSetupState extends State<StudentProfileSetup> {
  File? profileImage;
  List<String> selectedCourses = [];
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _gradeController = TextEditingController();
  final _addressController = TextEditingController();

  final List<String> courses = [
    "Mathematics",
    "Science",
    "English",
    "Computer",
    "Physics",
    "Chemistry",
    "Biology",
    "Programming",
    "History",
  ];

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Pre-fill email and name from auth
    final auth = context.read<AuthProvider>();
    _emailController.text = auth.email;
    _nameController.text = auth.fullName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _gradeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  /// Encodes the picked profile image to base64 (max 2MB), or null if none.
  Future<String?> _profileImageToBase64() async {
    final file = profileImage;
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    if (bytes.length > 2 * 1024 * 1024) {
      throw Exception('Image too large (max 2MB)');
    }
    return base64Encode(bytes);
  }

  Future<void> _handleContinue() async {
    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      final userService = UserService(
        baseUrl: auth.baseUrl,
        token: auth.accessToken,
        userId: auth.userId,
      );

      final profileData = <String, dynamic>{
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'studentProfile': {
          'grade': _gradeController.text.trim(),
          'interests': selectedCourses,
          'age': int.tryParse(_ageController.text.trim()),
          'address': _addressController.text.trim(),
        },
      };

      // Persist the picked avatar (base64-encoded) so it shows in chats etc.
      final encodedImage = await _profileImageToBase64();
      if (encodedImage != null) {
        profileData['profileImage'] = encodedImage;
      }

      await userService.updateProfile(profileData);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.studentNavbar, (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: SizeConfig.h(20)),

                FadeIn(
                  delay: 200,
                  child: Text(
                    "Student Profile Setup",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),

                SizedBox(height: SizeConfig.h(6)),
                FadeIn(
                  delay: 300,
                  child: Text(
                    "Let's set up your learning profile",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),

                SizedBox(height: SizeConfig.h(30)),

                // Profile Photo
                FadeIn(
                  delay: 400,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: SizeConfig.h(55),
                        backgroundColor: Theme.of(context).dividerColor,
                        backgroundImage: profileImage != null
                            ? FileImage(profileImage!)
                            : null,
                        child: profileImage == null
                            ? Icon(
                                Icons.person_rounded,
                                size: 55,
                                color:
                                    Theme.of(context).textTheme.bodySmall?.color,
                              )
                            : null,
                      ),
                      SizedBox(height: SizeConfig.h(10)),
                      TextButton(
                        onPressed: pickImage,
                        child: Text(
                          "Upload Photo",
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: SizeConfig.h(26)),

                _input(context, "Full Name", 500, controller: _nameController),
                _input(context, "Email", 550,
                    controller: _emailController,
                    keyboard: TextInputType.emailAddress,
                    enabled: false),
                _input(context, "Phone Number", 580,
                    controller: _phoneController,
                    keyboard: TextInputType.phone),
                _input(context, "Age", 600,
                    controller: _ageController,
                    keyboard: TextInputType.number),
                _input(context, "Grade / Class", 650,
                    controller: _gradeController),
                _input(context, "Address (Optional)", 700,
                    controller: _addressController),

                SizedBox(height: SizeConfig.h(30)),

                // Interest Selection
                FadeIn(
                  delay: 740,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Select your interests",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),

                SizedBox(height: SizeConfig.h(14)),

                FadeIn(
                  delay: 780,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: courses.map((course) {
                      bool selected = selectedCourses.contains(course);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selected
                                ? selectedCourses.remove(course)
                                : selectedCourses.add(course);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Text(
                            course,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(height: SizeConfig.h(40)),

                // Continue Button
                FadeIn(
                  delay: 820,
                  child: GestureDetector(
                    onTap: _isLoading ? null : _handleContinue,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: SizeConfig.h(15)),
                      decoration: BoxDecoration(
                        color: _isLoading
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.6)
                            : Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Continue",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: SizeConfig.h(30)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
    BuildContext context,
    String hint,
    int delay, {
    TextEditingController? controller,
    TextInputType keyboard = TextInputType.text,
    bool enabled = true,
  }) {
    return FadeIn(
      delay: delay,
      child: Padding(
        padding: EdgeInsets.only(bottom: SizeConfig.h(20)),
        child: TextField(
          controller: controller,
          keyboardType: keyboard,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Theme.of(context).cardColor,
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
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
