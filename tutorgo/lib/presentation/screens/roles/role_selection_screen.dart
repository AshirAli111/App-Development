import 'package:flutter/material.dart';

import '../../../core/utils/size_config.dart';
import '../../components/animations/fade_in.dart';
import '../../../routes/app_routes.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            /// -------- TOP SPACE (flexible) --------
            const Spacer(),

            /// TITLE
            FadeIn(
              delay: 200,
              child: Text(
                "Choose Your Role",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),

            SizedBox(height: SizeConfig.h(10)),

            FadeIn(
              delay: 350,
              child: Text(
                "Select how you want to use NextStepLearning",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            SizedBox(height: SizeConfig.h(30)),

            /// -------- CENTER CARDS WRAPPER --------
            FadeIn(
              delay: 400,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(24)),
                child: Column(
                  children: [
                    /// STUDENT CARD
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.studentSetup);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.h(26),
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).shadowColor.withValues(alpha: 0.15),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/images/student.png",
                              height: SizeConfig.h(120),
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: SizeConfig.h(18)),
                            Text(
                              "I am a Student",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: SizeConfig.h(30)),

                    /// TUTOR CARD
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.tutorSetup);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.h(26),
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).shadowColor.withValues(alpha: 0.15),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/images/teacher.png",
                              height: SizeConfig.h(120),
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: SizeConfig.h(18)),
                            Text(
                              "I am a Tutor",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// -------- BOTTOM SPACE (flexible) --------
            const Spacer(),

            FadeIn(
              delay: 700,
              child: Padding(
                padding: EdgeInsets.only(bottom: SizeConfig.h(20)),
                child: Text(
                  "Your choice helps us personalize your experience",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
