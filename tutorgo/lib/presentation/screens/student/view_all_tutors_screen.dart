import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:next_step_learning/presentation/screens/student/tutor_profile_popup.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/utils/image_utils.dart';

class ViewAllTutorsScreen extends StatefulWidget {
  final String subject;
  final List<Map<String, dynamic>> tutors;

  const ViewAllTutorsScreen({
    super.key,
    required this.subject,
    required this.tutors,
  });

  @override
  State<ViewAllTutorsScreen> createState() => _ViewAllTutorsScreenState();
}

class _ViewAllTutorsScreenState extends State<ViewAllTutorsScreen> {
  String searchQuery = "";
  double minRating = 0;
  double maxPrice = 50;

  List<Map<String, dynamic>> get filteredTutors {
    return widget.tutors.where((tutor) {
      final nameMatch = tutor["name"].toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      final ratingMatch = tutor["rating"] >= minRating;
      final priceMatch = tutor["price"] <= maxPrice;

      return nameMatch && ratingMatch && priceMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.subject),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.filter),
            onPressed: () => _openFilterPanel(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s16,
              AppSpacing.s20,
              AppSpacing.s8,
            ),
            child: TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: InputDecoration(
                hintText: "Search tutor...",
                prefixIcon: const Icon(LucideIcons.search),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🧩 GRID LIST
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.s20),
              itemCount: filteredTutors.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 220,
                crossAxisSpacing: AppSpacing.s16,
                mainAxisSpacing: AppSpacing.s16,
              ),
              itemBuilder: (_, i) {
                final tutor = filteredTutors[i];
                return _TutorGridCard(tutor: tutor);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // FILTER PANEL
  // ------------------------------------------------------------------
  void _openFilterPanel(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final double appBarHeight = kToolbarHeight + media.padding.top;

    // State for sliders within the dialog
    double tempMinRating = minRating;
    double tempMaxPrice = maxPrice;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: .35),
      barrierLabel: "Filters",
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(top: appBarHeight + 12, bottom: 24),
                child: Material(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(26),
                  ),
                  child: SizedBox(
                    width: media.size.width * 0.60,
                    height: media.size.height * 0.78,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ───────── HEADER ─────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Filters",
                                style: theme.textTheme.titleLarge,
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const Divider(height: AppSpacing.s32),

                          // ⭐ RATING SLIDER
                          Text(
                            "Minimum Rating: ${tempMinRating.toStringAsFixed(1)} ⭐",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: theme.colorScheme.primary,
                              inactiveTrackColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.2),
                              thumbColor: theme.colorScheme.primary,
                              overlayColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.2),
                              valueIndicatorColor: theme.colorScheme.primary,
                              showValueIndicator: ShowValueIndicator.onDrag,
                            ),
                            child: Slider(
                              value: tempMinRating,
                              min: 1,
                              max: 5,
                              divisions: 8,
                              label: "${tempMinRating.toStringAsFixed(1)} ⭐",
                              onChanged: (value) {
                                setState(() {
                                  tempMinRating = value;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("1 ⭐", style: TextStyle(fontSize: 12)),
                                Text("5 ⭐", style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.s20),

                          // 💲 PRICE SLIDER
                          Text(
                            "Max Hourly Price: \$${tempMaxPrice.toInt()} / hr",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: theme.colorScheme.primary,
                              inactiveTrackColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.2),
                              thumbColor: theme.colorScheme.primary,
                              overlayColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.2),
                              valueIndicatorColor: theme.colorScheme.primary,
                              showValueIndicator: ShowValueIndicator.onDrag,
                            ),
                            child: Slider(
                              value: tempMaxPrice,
                              min: 5,
                              max: 100,
                              divisions: 19,
                              label: "\$${tempMaxPrice.toInt()} / hr",
                              onChanged: (value) {
                                setState(() {
                                  tempMaxPrice = value;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("\$5", style: TextStyle(fontSize: 12)),
                                Text("\$100", style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Buttons Row
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      tempMinRating = 1.0;
                                      tempMaxPrice = 100.0;
                                    });
                                  },
                                  child: const Text("Reset"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () {
                                    // Apply the temporary values to actual state
                                    setState(() {
                                      minRating = tempMinRating;
                                      maxPrice = tempMaxPrice;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Apply Filters"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }
}

// ====================================================================
// GRID CARD WIDGET
// ====================================================================
class _TutorGridCard extends StatelessWidget {
  final Map<String, dynamic> tutor;
  const _TutorGridCard({required this.tutor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => showTutorProfilePopup(context, tutor),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.12,
                ),
                backgroundImage: profileImageProvider(tutor["image"]),
                child: profileImageProvider(tutor["image"]) == null
                    ? Icon(
                        LucideIcons.user,
                        color: theme.colorScheme.primary,
                        size: 32,
                      )
                    : null,
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                tutor["name"],
                style: theme.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Text(tutor["subject"], style: theme.textTheme.bodySmall),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        tutor["rating"].toString(),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Text(
                    "PKR ${tutor["price"]}/hr",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
