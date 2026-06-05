import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:next_step_learning/core/theme/colors.dart';
import 'package:next_step_learning/core/theme/spacing.dart';

class TutorVideoCallScreen extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const TutorVideoCallScreen({super.key, required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // 🔒 Video screens stay dark in both modes (intentional)
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          // 🔹 Fake main video background
          Container(color: Colors.black87),

          // 🔹 Small floating preview (self camera)
          Positioned(
            right: AppSpacing.s20,
            top: AppSpacing.s40,
            child: Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withValues(alpha: .35)),
              ),
              child: imageUrl == null
                  ? Icon(
                      LucideIcons.user,
                      color: Colors.white.withValues(alpha: .6),
                      size: 40,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(imageUrl!, fit: BoxFit.cover),
                    ),
            ),
          ),

          // 🔹 Student name (top center)
          Positioned(
            top: AppSpacing.s40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                name,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .75),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // 🔹 Bottom controls
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _controlButton(icon: LucideIcons.micOff, color: Colors.white),
                  const SizedBox(width: AppSpacing.s24),
                  _controlButton(
                    icon: LucideIcons.videoOff,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppSpacing.s24),
                  _controlButton(
                    icon: LucideIcons.phoneOff,
                    color: AppColors.error,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // 🎛 Call Control Button
  // -----------------------------------------------------------
  Widget _controlButton({required IconData icon, required Color color}) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: color.withValues(alpha: .18),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
