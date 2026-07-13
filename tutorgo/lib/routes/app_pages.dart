import 'package:flutter/material.dart';
import 'package:next_step_learning/presentation/screens/aichat/ai_chat_screen.dart';
import 'package:next_step_learning/presentation/screens/splash/splash_screen.dart';
import 'package:next_step_learning/presentation/screens/login/forgot_password_screen.dart';
import 'package:next_step_learning/presentation/screens/login/register_screen.dart';
import 'package:next_step_learning/presentation/screens/student/student_chats_conversation_screen.dart';
import 'package:next_step_learning/presentation/screens/student/student_dashboard.dart';
import 'package:next_step_learning/presentation/screens/student/student_delete_account_screen.dart';
import 'package:next_step_learning/presentation/screens/student/student_edit_profile_screen.dart';
import 'package:next_step_learning/presentation/screens/student/student_help_center_screen.dart';
import 'package:next_step_learning/presentation/screens/student/student_language_screen.dart';
import 'package:next_step_learning/presentation/screens/student/student_learning_history_screen.dart';
import 'package:next_step_learning/presentation/screens/student/student_notifications_screen.dart';
import 'package:next_step_learning/presentation/screens/student/student_payment_methods_screen.dart';
import 'package:next_step_learning/presentation/screens/payment/payment_screen.dart';
import 'package:next_step_learning/presentation/screens/student/student_privacy_screen.dart';
import 'package:next_step_learning/presentation/screens/student/student_profile_screen.dart';
import 'package:next_step_learning/presentation/screens/student/student_support_screen.dart';
import 'package:next_step_learning/presentation/screens/student/student_tutors_screen.dart';
import 'package:next_step_learning/presentation/screens/student/view_all_tutors_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/help_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/language_selection_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/notifications_settings_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/payment_methods_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/payout_settings_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/privacy_settings_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/tutor_contact_support_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/tutor_edit_profile_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/tutor_student_detail_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/tutor_students_screen.dart';
import 'app_routes.dart';

// Screens
import 'package:next_step_learning/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:next_step_learning/presentation/screens/login/login_screen.dart';
import 'package:next_step_learning/presentation/screens/roles/role_selection_screen.dart';
import 'package:next_step_learning/presentation/screens/student/student_profile_setup.dart';
import 'package:next_step_learning/presentation/screens/tutor/tutor_profile_setup.dart';
import 'package:next_step_learning/presentation/screens/tutor/tutor_chats_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/tutor_chat_conversation_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/tutor_video_call_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/tutor_voice_call_screen.dart';
import 'package:next_step_learning/presentation/screens/tutor/tutor_schedule_details_screen.dart';
import 'package:next_step_learning/presentation/widgets/student_navbar.dart';
import 'package:next_step_learning/presentation/widgets/tutor_navbar.dart';

class AppPages {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.splash:
        return _page(const SplashScreen());

      case AppRoutes.onboarding:
        return _page(const OnboardingScreen());

      case AppRoutes.login:
        return _page(const LoginScreen());

      case AppRoutes.register:
        return _page(const RegisterScreen());

      case AppRoutes.forgotPassword:
        return _page(const ForgotPasswordScreen());

      case AppRoutes.roleSelection:
        return _page(const RoleSelectionScreen());

      case AppRoutes.studentSetup:
        final data = args as Map?;
        return _page(StudentProfileSetup(
          fullName: data?['fullName'] as String?,
          email: data?['email'] as String?,
          password: data?['password'] as String?,
        ));

      case AppRoutes.tutorSetup:
        final data = args as Map?;
        return _page(TutorProfileSetup(
          fullName: data?['fullName'] as String?,
          email: data?['email'] as String?,
          password: data?['password'] as String?,
        ));

      // NAVBAR ROUTES
      case AppRoutes.studentNavbar:
        return _page(const StudentNavbar());

      case AppRoutes.tutorNavbar:
        return _page(const TutorNavbar());
      case AppRoutes.studentDashboard:
        return _page(const StudentDashboard());

      // CHAT LIST
      case AppRoutes.tutorChats:
        return _page(const TutorChatsScreen());
      case AppRoutes.tutorStudents:
        return _page(TutorStudentsScreen());
      case AppRoutes.editProfile:
        return _page(TutorEditProfileScreen());

      case AppRoutes.paymentMethods:
        return _page(PaymentMethodsScreen());

      case AppRoutes.payoutSettings:
        return _page(PayoutSettingsScreen());

      case AppRoutes.notifications:
        return _page(NotificationsSettingsScreen());

      case AppRoutes.privacySettings:
        return _page(PrivacySettingsScreen());

      case AppRoutes.languageSettings:
        return _page(const LanguageSelectionScreen());

      case AppRoutes.helpCenter:
        return _page(HelpCenterScreen());

      case AppRoutes.contactSupport:
        return _page(ContactSupportScreen());

      //Student CHAT
      case AppRoutes.studentChat:
        final data = args as Map?;
        return _page(
          StudentChatConversation(
            name: data?["name"] ?? "Unknown",
            imageUrl: data?["imageUrl"],
            chatId: data?["chatId"] ?? '',
            baseUrl: data?["baseUrl"] ?? 'http://localhost:8080',
            token: data?["token"] ?? '',
            userId: data?["userId"] ?? '',
          ),
        );
      case AppRoutes.studentProfile:
        return _page(const StudentProfileScreen());

      case AppRoutes.studentEditProfile:
        return _page(const StudentEditProfileScreen());

      case AppRoutes.studentNotifications:
        return _page(const StudentNotificationsScreen());

      case AppRoutes.studentPrivacy:
        return _page(const StudentPrivacyScreen());

      case AppRoutes.studentLanguage:
        return _page(const StudentLanguageScreen());

      case AppRoutes.studentTutors:
        return _page(const StudentTutorsScreen());

      case AppRoutes.studentHistory:
        return _page(const StudentLearningHistoryScreen());

      case AppRoutes.studentHelpCenter:
        return _page(const StudentHelpCenterScreen());

      case AppRoutes.studentSupport:
        return _page(const StudentSupportScreen());

      case AppRoutes.studentPayments:
        return _page(const StudentPaymentMethodsScreen());

      case AppRoutes.paymentCheckout:
        final data = args as Map<String, dynamic>;
        return _page(PaymentScreen(
          studentId: data['studentId'],
          tutorId: data['tutorId'],
          amountPKR: data['amountPKR'],
          sessionInstanceId: data['sessionInstanceId'],
          baseUrl: data['baseUrl'] ?? 'http://localhost:8080',
          token: data['token'] ?? '',
        ));
      case AppRoutes.aiChatScreen:
        final role = settings.arguments as AiRole;
        return _page(AiChatScreen(role: role));

      case AppRoutes.studentDeleteAccount:
        return _page(const StudentDeleteAccountScreen());
      case AppRoutes.studentViewAllTutors:
        final args = settings.arguments as Map<String, dynamic>;

        return _page(
          ViewAllTutorsScreen(
            subject: args["subject"],
            tutors: List<Map<String, dynamic>>.from(args["tutors"]),
          ),
        );

      // CHAT CONVERSATION
      case AppRoutes.tutorChatConversation:
        final data = args as Map?;
        return _page(
          TutorChatConversation(
            name: data?["name"] ?? "Unknown",
            imageUrl: data?["imageUrl"],
            chatId: data?["chatId"] ?? '',
            baseUrl: data?["baseUrl"] ?? 'http://localhost:8080',
            token: data?["token"] ?? '',
            userId: data?["userId"] ?? '',
          ),
        );

      // VIDEO CALL
      case AppRoutes.tutorVideoCall:
        final data = args as Map?;
        return _page(
          TutorVideoCallScreen(
            name: data?["name"] ?? "Student",
            imageUrl: data?["imageUrl"],
          ),
        );

      // AUDIO CALL
      case AppRoutes.tutorVoiceCall:
        final data = args as Map?;
        return _page(
          TutorAudioCallScreen(
            name: data?["name"] ?? "Student",
            imageUrl: data?["imageUrl"],
          ),
        );

      // SCHEDULE DETAILS
      case AppRoutes.tutorScheduleDetails:
        final data = args as Map?;
        return _page(
          TutorScheduleDetailsScreen(
            subject: data?["subject"] ?? "",
            student: data?["student"] ?? "",
            time: data?["time"] ?? "",
            color: data?["color"] ?? Colors.blue,
          ),
        );
      case AppRoutes.tutorStudentDetails:
        final data = args as Map<String, dynamic>;
        return _page(
          TutorStudentDetailScreen(
            name: data["name"],
            grade: data["grade"],
            progress: data["progress"],
            assignments: data["assignments"],
            lastSession: data["lastSession"],
            image: data["image"],
          ),
        );

      // UNKNOWN ROUTE
      default:
        return _page(
          Scaffold(
            body: Center(child: Text("Route Not Found: ${settings.name}")),
          ),
        );
    }
  }

  static MaterialPageRoute _page(Widget child) =>
      MaterialPageRoute(builder: (_) => child);
}
