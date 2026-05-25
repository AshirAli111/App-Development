import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:next_step_learning/presentation/screens/aichat/ai_chat_screen.dart';

// Screens
import 'package:next_step_learning/presentation/screens/tutor/tutor_home_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/tutor_chats_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/tutor_schedule_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/tutor_students_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/tutor_profile_screen.dart';
import 'package:next_step_learning/routes/app_routes.dart';

class TutorNavbar extends StatefulWidget {
  const TutorNavbar({super.key});

  @override
  State<TutorNavbar> createState() => _TutorNavbarState();
}

class _TutorNavbarState extends State<TutorNavbar> {
  int currentIndex = 0;

  final icons = [
    LucideIcons.home,
    LucideIcons.messageCircle,
    LucideIcons.calendar,
    LucideIcons.users2,
    LucideIcons.user,
  ];

  final labels = ["Home", "Messages", "Schedule", "Students", "Profile"];

  final screens = [
    const TutorHomeScreen(),
    const TutorChatsScreen(),
    const TutorScheduleScreen(),
    TutorStudentsScreen(),
    const TutorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    double navHeight = MediaQuery.of(context).size.height * 0.11;

    return Scaffold(
      extendBody: true,
      body: screens[currentIndex],

      // ✅ FAB ONLY ON HOME TAB
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton.extended(
              heroTag: "ai_tutor_fab",
              tooltip: "Ask AI Assistant",
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.aiChatScreen,
                  arguments: AiRole.tutor, // 👈 DIFFERENT ROLE
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
                    // 🔵 Bubble highlight
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

                    // 🔘 Inactive icon
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: active ? 0 : 1,
                      child: Icon(
                        icons[index],
                        size: 26,
                        color: iconColor?.withValues(alpha: 0.6),
                      ),
                    ),

                    // 📌 Label
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
