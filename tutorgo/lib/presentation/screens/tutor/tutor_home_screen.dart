import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

// THEME
import 'package:next_step_learning/core/theme/spacing.dart';

class TutorHomeScreen extends StatefulWidget {
  const TutorHomeScreen({super.key});

  @override
  State<TutorHomeScreen> createState() => _TutorHomeScreenState();
}

class _TutorHomeScreenState extends State<TutorHomeScreen> {
  /// ACTION ITEMS
  List<Map<String, dynamic>> actionItems = [
    {"text": "Prepare quiz for Ayesha", "done": false},
    {"text": "Check Bilal’s homework", "done": false},
  ];

  void _addActionItem() {
    TextEditingController controller = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text("Add Action Item", style: theme.textTheme.headlineMedium),
          content: TextField(
            controller: controller,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: "Write a task...",
              hintStyle: theme.textTheme.bodySmall,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: theme.textTheme.bodyMedium),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    actionItems.add({
                      "text": controller.text.trim(),
                      "done": false,
                    });
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  /// REMINDERS LIST
  final List<Map<String, dynamic>> reminders = [
    {
      "title": "Collect Maths Assignment",
      "date": "Tomorrow",
      "icon": LucideIcons.fileCheck,
    },
    {
      "title": "Physics Midterm Next Week",
      "date": "7 days left",
      "icon": LucideIcons.flaskRound,
    },
    {
      "title": "Parent Meeting for Bilal",
      "date": "Friday",
      "icon": LucideIcons.users,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),

                const SizedBox(height: AppSpacing.s24),
                _highlightCards(context),

                const SizedBox(height: AppSpacing.s32),
                _sectionTitle(context, "My Students", LucideIcons.users),
                const SizedBox(height: AppSpacing.s16),
                _studentsGrid(context),

                const SizedBox(height: AppSpacing.s32),
                _sectionTitle(context, "Reminders", LucideIcons.bell),
                const SizedBox(height: AppSpacing.s16),
                _remindersList(context),

                const SizedBox(height: AppSpacing.s32),
                _sectionTitle(context, "Action Items", LucideIcons.listChecks),
                const SizedBox(height: AppSpacing.s16),
                _actionItemsWidget(context),

                const SizedBox(height: AppSpacing.s40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // SECTION TITLE
  // -------------------------------------------------------------------------
  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurface),
          const SizedBox(width: AppSpacing.s8),
          Text(title, style: theme.textTheme.headlineMedium),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // HEADER (gradient stays same – looks good in dark too)
  // -------------------------------------------------------------------------
  Widget _header(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s32,
        AppSpacing.s20,
        AppSpacing.s40,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: .85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: .25),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello Ali 👋",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                "Welcome Back!",
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .25),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.bell, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // HIGHLIGHT CARDS
  // -------------------------------------------------------------------------
  Widget _highlightCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Row(
        children: [
          _highlightCard(
            context,
            icon: LucideIcons.brainCircuit,
            title: "Teaching Insights",
            value: "92%",
            subtitle: "Performance Score",
            color: Colors.purple,
          ),
          const SizedBox(width: AppSpacing.s16),
          _highlightCard(
            context,
            icon: LucideIcons.calendarClock,
            title: "Today",
            value: "3 Sessions",
            subtitle: "2 Completed",
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _highlightCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: .15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: color.withValues(alpha: .15),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(value, style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.s4),
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(subtitle, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // STUDENTS GRID
  // -------------------------------------------------------------------------
  Widget _studentsGrid(BuildContext context) {
    final theme = Theme.of(context);

    final students = [
      {"name": "Ayesha", "grade": "Grade 9", "progress": 0.82},
      {"name": "Bilal", "grade": "Grade 10", "progress": 0.67},
      {"name": "Sara", "grade": "Grade 11", "progress": 0.51},
      {"name": "Ahmed", "grade": "Grade 8", "progress": 0.74},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: GridView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: students.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 150,
          crossAxisSpacing: AppSpacing.s16,
          mainAxisSpacing: AppSpacing.s16,
        ),
        itemBuilder: (_, i) {
          final s = students[i];
          return Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: .15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: .12),
                  child: Icon(
                    LucideIcons.user,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                Text(s["name"] as String, style: theme.textTheme.titleMedium),
                Text(s["grade"] as String, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.s8),
                LinearProgressIndicator(
                  value: s["progress"] as double,
                  backgroundColor: theme.dividerColor,
                  color: theme.colorScheme.primary,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(40),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // REMINDERS
  // -------------------------------------------------------------------------
  Widget _remindersList(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: reminders.map((r) {
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s20,
            vertical: AppSpacing.s8,
          ),
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: .15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: .15),
                child: Icon(
                  r["icon"],
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r["title"], style: theme.textTheme.titleMedium),
                    Text(r["date"], style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // -------------------------------------------------------------------------
  // ACTION ITEMS
  // -------------------------------------------------------------------------
  Widget _actionItemsWidget(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: .15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Action Items", style: theme.textTheme.titleMedium),
                GestureDetector(
                  onTap: _addActionItem,
                  child: Icon(
                    LucideIcons.plusCircle,
                    size: 26,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.s16),

            Column(
              children: actionItems.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            item["done"] = !item["done"];
                          });
                        },
                        child: Icon(
                          item["done"]
                              ? LucideIcons.checkCircle2
                              : LucideIcons.circle,
                          color: item["done"]
                              ? theme.colorScheme.secondary
                              : theme.iconTheme.color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Text(
                          item["text"],
                          style: theme.textTheme.bodyLarge?.copyWith(
                            decoration: item["done"]
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            actionItems.remove(item);
                          });
                        },
                        child: Icon(
                          LucideIcons.trash2,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
