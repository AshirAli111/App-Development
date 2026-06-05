import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:next_step_learning/core/theme/colors.dart';
import 'package:next_step_learning/core/theme/spacing.dart';
import 'package:next_step_learning/core/theme/typography.dart';

class TutorAudioCallScreen extends StatefulWidget {
  final String name;
  final String imageUrl;

  const TutorAudioCallScreen({
    super.key,
    required this.name,
    required this.imageUrl,
  });

  @override
  State<TutorAudioCallScreen> createState() => _TutorAudioCallScreenState();
}

class _TutorAudioCallScreenState extends State<TutorAudioCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width * 0.55;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1529), // Premium dark

      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s20,
          vertical: AppSpacing.s40,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ------------------ TOP TEXT ------------------
            Column(
              children: [
                const SizedBox(height: AppSpacing.s20),
                Text(
                  "Calling…",
                  style: AppTypography.h2.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  widget.name,
                  style: AppTypography.h1.copyWith(color: Colors.white),
                ),
              ],
            ),

            // ------------------ ANIMATED AVATAR ------------------
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, child) {
                return Container(
                  height: size + (_pulseController.value * 20),
                  width: size + (_pulseController.value * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    height: size,
                    width: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        width: 5,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(widget.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),

            // ------------------ CONTROLS ------------------
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _circleBtn(
                      icon: LucideIcons.micOff,
                      bg: Colors.white.withValues(alpha: 0.15),
                      iconColor: Colors.white,
                    ),
                    _circleBtn(
                      icon: LucideIcons.volume2,
                      bg: Colors.white.withValues(alpha: 0.15),
                      iconColor: Colors.white,
                    ),
                    _circleBtn(
                      icon: LucideIcons.bluetooth,
                      bg: Colors.white.withValues(alpha: 0.15),
                      iconColor: Colors.white,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.s40),

                // End Call
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(26),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.phoneOff,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------
  // 🎛 CONTROL BUTTON
  // -----------------------------------------------------
  Widget _circleBtn({
    required IconData icon,
    required Color bg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      child: Icon(icon, size: 26, color: iconColor),
    );
  }
}
