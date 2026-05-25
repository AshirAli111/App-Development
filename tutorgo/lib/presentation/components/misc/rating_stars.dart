import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;

  const RatingStars({super.key, required this.rating, this.size = 18});

  @override
  Widget build(BuildContext context) {
    final filled = rating.floor();
    final half = (rating - filled) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < filled) {
          return Icon(LucideIcons.star, color: Colors.amber, size: size);
        } else if (i == filled && half) {
          return Icon(LucideIcons.starHalf, color: Colors.amber, size: size);
        } else {
          return Icon(
            LucideIcons.star,
            color: Colors.grey.shade300,
            size: size,
          );
        }
      }),
    );
  }
}
