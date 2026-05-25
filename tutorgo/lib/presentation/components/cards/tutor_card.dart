import 'package:flutter/material.dart';
import '../../../core/utils/size_config.dart';
import '../misc/avatar.dart';
import '../misc/rating_stars.dart';
import '../../../core/theme/colors.dart';

class TutorCard extends StatelessWidget {
  final String name;
  final String subject;
  final double rating;
  final String? imageUrl;
  final VoidCallback onTap;

  const TutorCard({
    super.key,
    required this.name,
    required this.subject,
    required this.rating,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: SizeConfig.h(8),
          horizontal: SizeConfig.w(12),
        ),
        padding: EdgeInsets.all(SizeConfig.w(14)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            AppAvatar(size: 55, imageUrl: imageUrl),
            SizedBox(width: SizeConfig.w(14)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 4),
                RatingStars(rating: rating, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
