import 'package:flutter/material.dart';

import '../../../core/utils/size_config.dart';
import '../../components/buttons/app_primary_button.dart';
import '../../components/animations/fade_in.dart';
import '../../../routes/app_routes.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: SizeConfig.h(40)),

            /// ⭐ TOP ANIMATION
            FadeIn(
              delay: 200,
              child: SizedBox(
                height: 260,
                child: Image.network(
                  'https://media2.giphy.com/media/v1.Y2lkPTc5MGI3NjExY2MwMmsxajQ2YXBuc2Q0bHNuNHJzM2hsYmpkdmhmNWcyMGRzc3RvMSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/wgny8qK94awjCx7j30/giphy.gif',
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),

            SizedBox(height: SizeConfig.h(20)),

            /// ⭐ TITLE
            FadeIn(
              delay: 400,
              child: Text(
                "Learn Smarter with TutorGo",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            SizedBox(height: SizeConfig.h(12)),

            /// ⭐ SUBTITLE
            FadeIn(
              delay: 600,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(26)),
                child: Text(
                  "Find the best tutors, book sessions easily, "
                  "and get AI-verified learning anytime, anywhere.",
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ),
            ),

            const Spacer(),

            /// ⭐ BOTTOM BUTTON
            FadeIn(
              delay: 800,
              child: Padding(
                padding: EdgeInsets.only(bottom: SizeConfig.h(40)),
                child: AppPrimaryButton(
                  text: "Get Started",
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
