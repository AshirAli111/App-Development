import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/presentation/screens/aichat/ai_chat_screen.dart';
import 'package:next_step_learning/presentation/screens/student/student_dashboard.dart';
import 'package:next_step_learning/presentation/screens/student/student_messages_screen.dart';
import 'package:next_step_learning/presentation/screens/student/student_profile_screen.dart';
import 'package:next_step_learning/presentation/screens/student/tutor_discovery_screen.dart';
import 'package:next_step_learning/routes/app_routes.dart';

class StudentNavbar extends StatefulWidget {
  final int index;
  const StudentNavbar({super.key, this.index = 0});

  @override
  State<StudentNavbar> createState() => _StudentNavbarState();
}

class _StudentNavbarState extends State<StudentNavbar> {
  late int currentIndex;

  @override
  void initState() {
    currentIndex = widget.index;
    super.initState();
  }

  final icons = [
    LucideIcons.home,
    LucideIcons.messageCircle,
    LucideIcons.bookOpen,
    LucideIcons.user,
  ];

  final labels = ["Home", "Messages", "Courses", "Profile"];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    double navHeight = MediaQuery.of(context).size.height * 0.11;

    final screens = [
      const StudentDashboard(),
      StudentMessagesScreen(
        baseUrl: auth.baseUrl,
        token: auth.accessToken,
        userId: auth.userId,
      ),
      const TutorDiscoveryScreen(),
      const StudentProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: screens[currentIndex],
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton.extended(
              heroTag: "ai_student_fab",
              tooltip: "Ask AI Tutor",
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.aiChatScreen,
                  arguments: AiRole.student,
                );
              },
              icon: const Icon(LucideIcons.sparkles),
              label: const Text("AI Assistant"),
            )
          : null,
      bottomNavigationBar: _bubbleNavBar(context, navHeight),
    );
  }

  Widget _bubbleNavBar(BuildContext context, double navHeight) {
    final primary = Theme.of(context).colorScheme.primary;
    final iconColor = Theme.of(context).iconTheme.color;
    final shadowColor = Theme.of(context).shadowColor;

    return SafeArea(
      child: Container(
        height: navHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(icons.length, (index) {
            bool active = index == currentIndex;

            return GestureDetector(
              onTap: () => setState(() => currentIndex = index),
              child: SizedBox(
                width: 75,
                height: navHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 220),
                      top: active ? -(navHeight * 0.25) : navHeight * 0.30,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 220),
                        opacity: active ? 1 : 0,
                        child: Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primary.withValues(alpha: .35),
                                blurRadius: 22,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(icons[index], color: Colors.white),
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: active ? 0 : 1,
                      child: Icon(
                        icons[index],
                        size: 26,
                        color: iconColor?.withValues(alpha: 0.6),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: active ? 1 : 0,
                        child: Text(
                          labels[index],
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
