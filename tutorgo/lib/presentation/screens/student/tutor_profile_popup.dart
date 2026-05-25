import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/spacing.dart';
import '../../screens/tutor/tutor_chat_conversation_screen.dart';

void showTutorProfilePopup(BuildContext context, Map data) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (_) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.45,
        maxChildSize: 0.90,
        builder: (_, controller) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.s20),
            child: ListView(
              controller: controller,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),

                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    child: Icon(
                      LucideIcons.user,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),

                Center(
                  child: Text(
                    data["name"],
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Center(
                  child: Text(
                    data["subject"],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      "${data["rating"]}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "• \$${data["price"]}/hr",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.s24),

                Text(
                  "About Tutor",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  "Experienced teacher with 4+ years helping students excel.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: AppSpacing.s24),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TutorChatConversation(
                          name: data["name"],
                          imageUrl: null,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Chat with Tutor"),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
