import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final double size;
  final String? imageUrl;

  const AppAvatar({super.key, this.size = 50, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? NetworkImage(imageUrl!)
          : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Icon(Icons.person, size: size * 0.5, color: Colors.grey)
          : null,
    );
  }
}
