import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:next_step_learning/core/theme/theme_manager.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/size_config.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      lazy: false,
      child: const TutorGo(),
    ),
  );
}

class TutorGo extends StatelessWidget {
  const TutorGo({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'TutorGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme, // (even if same for now)
      themeMode: themeProvider.themeMode,
      initialRoute: AppRoutes.onboarding,
      onGenerateRoute: AppPages.onGenerateRoute,
      builder: (context, child) {
        if (child != null) {
          SizeConfig.init(context);
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
