import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';

class RequestBottomSheet extends StatefulWidget {
  const RequestBottomSheet({super.key});

  @override
  State<RequestBottomSheet> createState() => _RequestBottomSheetState();
}

class _RequestBottomSheetState extends State<RequestBottomSheet> {
  String? course;
  String? day;
  String? time;

  final courses = ["Math", "Physics", "Biology", "English"];
  final days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
  final times = ["2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM"];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// DRAG HANDLE
            Center(
              child: Container(
                height: 5,
                width: 60,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            /// TITLE
            Text(
              "Send Session Request",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),

            /// COURSE
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Course"),
              items: courses
                  .map(
                    (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => course = val),
            ),

            const SizedBox(height: 14),

            /// DAY
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Day"),
              items: days
                  .map(
                    (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => day = val),
            ),

            const SizedBox(height: 14),

            /// TIME
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Time"),
              items: times
                  .map(
                    (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => time = val),
            ),

            const SizedBox(height: 22),

            /// SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (course != null && day != null && time != null) {
                    Navigator.pop(context, {
                      "course": course,
                      "day": day,
                      "time": time,
                    });
                  }
                },
                child: Text(
                  "Send Request",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
