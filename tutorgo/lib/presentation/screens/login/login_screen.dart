import 'package:flutter/material.dart';

import '../../../core/utils/size_config.dart';
import '../../components/animations/fade_in.dart';
import '../../../routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: SizeConfig.h(40)),

              /// ⭐ APP LOGO
              FadeIn(
                delay: 150,
                child: Column(
                  children: [
                    Container(
                      height: SizeConfig.h(110),
                      width: SizeConfig.h(180),
                      padding: EdgeInsets.all(SizeConfig.h(0)),
                      child: Image.asset(
                        "assets/images/logo.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: SizeConfig.h(14)),
                  ],
                ),
              ),

              SizedBox(height: SizeConfig.h(30)),

              /// ⭐ EMAIL INPUT
              FadeIn(
                delay: 300,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: SizeConfig.w(30)),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(
                        Icons.email_rounded,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: SizeConfig.h(20)),

              /// ⭐ PASSWORD INPUT
              FadeIn(
                delay: 400,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: SizeConfig.w(30)),
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(
                        Icons.lock_rounded,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: SizeConfig.h(10)),

              /// ⭐ FORGOT PASSWORD
              FadeIn(
                delay: 450,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(right: SizeConfig.w(30)),
                    child: Text(
                      "Forgot Password?",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: SizeConfig.h(30)),

              /// ⭐ LOGIN BUTTON
              FadeIn(
                delay: 550,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.roleSelection);
                  },
                  child: Container(
                    width: SizeConfig.w(300),
                    padding: EdgeInsets.symmetric(vertical: SizeConfig.h(14)),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        "Login",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: SizeConfig.h(30)),

              /// ⭐ DIVIDER
              FadeIn(
                delay: 600,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.w(30),
                        ),
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    Text(
                      "  OR  ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        margin: EdgeInsets.symmetric(
                          horizontal: SizeConfig.w(30),
                        ),
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: SizeConfig.h(30)),

              /// ⭐ GOOGLE LOGIN BUTTON
              FadeIn(
                delay: 700,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: SizeConfig.w(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        "https://cdn-icons-png.flaticon.com/512/300/300221.png",
                        height: 22,
                        width: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Continue with Google",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: SizeConfig.h(20)),

              /// ⭐ FACEBOOK LOGIN BUTTON
              FadeIn(
                delay: 800,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: SizeConfig.w(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.facebook_rounded,
                        size: 22,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Continue with Facebook",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: SizeConfig.h(40)),
            ],
          ),
        ),
      ),
    );
  }
}
