import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/user_service.dart';

import 'package:next_step_learning/core/theme/colors.dart';
import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/core/theme/typography.dart';
import 'package:next_step_learning/routes/app_routes.dart';

class TutorProfileSetup extends StatefulWidget {
  const TutorProfileSetup({super.key});

  @override
  State<TutorProfileSetup> createState() => _TutorProfileSetupState();
}

class _TutorProfileSetupState extends State<TutorProfileSetup> {
  File? profileImage;
  File? cnicFront;
  File? cnicBack;
  File? certificateFile;
  File? degreeFile;

  List<String> selectedSubjects = [];
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _qualificationController = TextEditingController();

  final picker = ImagePicker();

  final List<String> subjects = [
    "Mathematics",
    "Physics",
    "Chemistry",
    "Biology",
    "English",
    "Computer Science",
    "Programming",
    "Urdu",
    "Economics",
    "Accounting",
    "Machine Learning",
  ];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _emailController.text = auth.email;
    _nameController.text = auth.fullName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  Future<File?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  Future pickProfileImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() => profileImage = File(pickedFile.path));
    }
  }

  Future<String?> _fileToBase64(File? file) async {
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    // Reject files larger than 2MB
    if (bytes.length > 2 * 1024 * 1024) {
      throw Exception('File too large (max 2MB): ${file.path.split('/').last}');
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

      // Build documents map from picked files
      final documents = <String, dynamic>{};
      if (cnicFront != null) {
        documents['cnicFront'] = await _fileToBase64(cnicFront);
      }
      if (cnicBack != null) {
        documents['cnicBack'] = await _fileToBase64(cnicBack);
      }
      if (certificateFile != null) {
        documents['teachingCertificate'] = await _fileToBase64(certificateFile);
      }
      if (degreeFile != null) {
        documents['degree'] = await _fileToBase64(degreeFile);
      }

      final tutorProfile = <String, dynamic>{
        'subjects': selectedSubjects,
        'experienceYears':
            int.tryParse(_experienceController.text.trim()) ?? 0,
        'qualification': _qualificationController.text.trim(),
      };

      if (documents.isNotEmpty) {
        tutorProfile['documents'] = documents;
      }

      final profileData = <String, dynamic>{
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'tutorProfile': tutorProfile,
      };

      await userService.updateProfile(profileData);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.tutorNavbar, (_) => false);
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

  Widget buildUploadedCard(String label, File file) {
    final isImage =
        file.path.toLowerCase().endsWith(".png") ||
        file.path.toLowerCase().endsWith(".jpg") ||
        file.path.toLowerCase().endsWith(".jpeg");

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.s12),
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).cardColor
            : AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          isImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(file, height: 50, width: 50, fit: BoxFit.cover),
                )
              : const Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text(
              "$label Uploaded",
              style: AppTypography.body16.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.success),
        ],
      ),
    );
  }

  Widget uploadButton(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: .4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.upload_file_rounded, color: AppColors.textMedium),
          const SizedBox(width: AppSpacing.s12),
          Text(
            label,
            style: AppTypography.body16.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s20),

              Center(child: Text("Tutor Profile Setup", style: AppTypography.h1)),
              const SizedBox(height: AppSpacing.s8),
              Center(
                child: Text(
                  "Help students learn with your expertise",
                  style: AppTypography.body14,
                ),
              ),

              const SizedBox(height: AppSpacing.s32),

              // Profile Avatar
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          profileImage != null ? FileImage(profileImage!) : null,
                      backgroundColor: AppColors.border,
                      child: profileImage == null
                          ? const Icon(Icons.person_rounded,
                              size: 55, color: AppColors.textLight)
                          : null,
                    ),
                    TextButton(
                      onPressed: pickProfileImage,
                      child: Text(
                        "Upload Photo",
                        style: AppTypography.body16.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s32),

              // Input Fields
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: "Full Name"),
              ),
              const SizedBox(height: AppSpacing.s16),

              TextField(
                controller: _emailController,
                enabled: false,
                decoration: const InputDecoration(hintText: "Email"),
              ),
              const SizedBox(height: AppSpacing.s16),

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: "Phone Number"),
              ),
              const SizedBox(height: AppSpacing.s16),

              TextField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: "Experience (years)"),
              ),
              const SizedBox(height: AppSpacing.s16),

              TextField(
                controller: _qualificationController,
                decoration:
                    const InputDecoration(hintText: "Highest Qualification"),
              ),

              const SizedBox(height: AppSpacing.s32),

              // Documents
              Text("Upload Required Documents", style: AppTypography.h3),
              const SizedBox(height: AppSpacing.s16),

              GestureDetector(
                onTap: () async {
                  final file = await pickFile();
                  if (file != null) setState(() => cnicFront = file);
                },
                child: uploadButton("Upload CNIC Front"),
              ),
              if (cnicFront != null) buildUploadedCard("CNIC Front", cnicFront!),
              const SizedBox(height: AppSpacing.s16),

              GestureDetector(
                onTap: () async {
                  final file = await pickFile();
                  if (file != null) setState(() => cnicBack = file);
                },
                child: uploadButton("Upload CNIC Back"),
              ),
              if (cnicBack != null) buildUploadedCard("CNIC Back", cnicBack!),
              const SizedBox(height: AppSpacing.s16),

              GestureDetector(
                onTap: () async {
                  final file = await pickFile();
                  if (file != null) setState(() => certificateFile = file);
                },
                child: uploadButton("Upload Teaching Certificate"),
              ),
              if (certificateFile != null)
                buildUploadedCard("Certificate", certificateFile!),
              const SizedBox(height: AppSpacing.s16),

              GestureDetector(
                onTap: () async {
                  final file = await pickFile();
                  if (file != null) setState(() => degreeFile = file);
                },
                child: uploadButton("Upload Degree"),
              ),
              if (degreeFile != null) buildUploadedCard("Degree", degreeFile!),

              const SizedBox(height: AppSpacing.s32),

              // Subject Selection
              Text("Subjects you teach", style: AppTypography.h3),
              const SizedBox(height: AppSpacing.s16),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: subjects.map((subject) {
                  final selected = selectedSubjects.contains(subject);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selected
                            ? selectedSubjects.remove(subject)
                            : selectedSubjects.add(subject);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).cardColor
                                : AppColors.border,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        subject,
                        style: AppTypography.body14.copyWith(
                          color: selected
                              ? Colors.white
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.s32),

              // Continue Button
              GestureDetector(
                onTap: _isLoading ? null : _handleContinue,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: _isLoading
                        ? AppColors.primary.withValues(alpha: 0.6)
                        : AppColors.primary,
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
                        : Text(
                            "Continue",
                            style: AppTypography.h3.copyWith(color: Colors.white),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s32),
            ],
          ),
        ),
      ),
    );
  }
}
