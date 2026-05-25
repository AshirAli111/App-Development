import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  /// Multiple selection enabled
  List<String> selectedCourses = [];

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

                /// TITLE
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

                /// PROFILE PHOTO
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
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                              )
                            : null,
                      ),
                      SizedBox(height: SizeConfig.h(10)),
                      TextButton(
                        onPressed: pickImage,
                        child: Text(
                          "Upload Photo",
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: SizeConfig.h(26)),

                /// INPUTS
                _input(context, "Full Name", 500),
                _input(
                  context,
                  "Email",
                  550,
                  keyboard: TextInputType.emailAddress,
                ),
                _input(
                  context,
                  "Phone Number",
                  580,
                  keyboard: TextInputType.phone,
                ),
                _input(context, "Age", 600, keyboard: TextInputType.number),
                _input(context, "Grade / Class", 650),
                _input(context, "Address (Optional)", 700),

                SizedBox(height: SizeConfig.h(30)),

                /// INTEREST SELECTION
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
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(height: SizeConfig.h(40)),

                /// CONTINUE BUTTON
                FadeIn(
                  delay: 820,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.studentNavbar);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: SizeConfig.h(15)),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
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

  // ------------------------------------------------------------
  // INPUT HELPER
  // ------------------------------------------------------------
  Widget _input(
    BuildContext context,
    String hint,
    int delay, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return FadeIn(
      delay: delay,
      child: Padding(
        padding: EdgeInsets.only(bottom: SizeConfig.h(20)),
        child: TextField(
          keyboardType: keyboard,
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
