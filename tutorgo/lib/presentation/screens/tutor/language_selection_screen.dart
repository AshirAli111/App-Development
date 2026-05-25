import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:next_step_learning/core/theme/spacing.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String selectedLanguage = "English";

  final List<Map<String, dynamic>> languages = [
    {"name": "English", "icon": LucideIcons.languages},
    {"name": "Urdu", "icon": LucideIcons.languages},
    {"name": "Hindi", "icon": LucideIcons.languages},
    {"name": "Arabic", "icon": LucideIcons.languages},
    {"name": "French", "icon": LucideIcons.languages},
    {"name": "Spanish", "icon": LucideIcons.languages},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text("Language", style: Theme.of(context).textTheme.titleLarge),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.s20),
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final lang = languages[index];
          final name = lang["name"];

          return _languageTile(
            context: context,
            name: name,
            icon: lang["icon"],
            selected: selectedLanguage == name,
            onTap: () {
              setState(() {
                selectedLanguage = name;
              });
            },
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------
  // 🌍 Language Option Tile
  // ---------------------------------------------------------
  Widget _languageTile({
    required BuildContext context,
    required String name,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s16),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s16,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? primary : Colors.transparent,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: .15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primary),
            ),

            const SizedBox(width: AppSpacing.s16),

            Expanded(
              child: Text(name, style: Theme.of(context).textTheme.titleMedium),
            ),

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? primary
                      : Theme.of(context).iconTheme.color!.withValues(alpha: .6),
                  width: 2,
                ),
                color: selected ? primary : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
