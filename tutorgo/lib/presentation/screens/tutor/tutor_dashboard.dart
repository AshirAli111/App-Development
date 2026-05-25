import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TutorDashboard extends StatelessWidget {
  const TutorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// -----------------------------------------------------
              /// HEADER SECTION
              /// -----------------------------------------------------
              _buildHeader(context),

              const SizedBox(height: 20),

              /// -----------------------------------------------------
              /// STATS SECTION
              /// -----------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statCard(
                      icon: LucideIcons.users2,
                      title: "Students",
                      value: "32",
                      color: Colors.blue,
                    ),
                    _statCard(
                      icon: LucideIcons.calendarClock,
                      title: "Today",
                      value: "5 Classes",
                      color: Colors.green,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statCard(
                      icon: LucideIcons.dollarSign,
                      title: "Earnings",
                      value: "\$280",
                      color: Colors.orange,
                    ),
                    _statCard(
                      icon: LucideIcons.star,
                      title: "Rating",
                      value: "4.9",
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// -----------------------------------------------------
              /// TODAY'S CLASSES TIMELINE
              /// -----------------------------------------------------
              _sectionTitle("Today's Schedule", LucideIcons.calendar),

              const SizedBox(height: 12),

              _classTile(
                subject: "Mathematics",
                time: "4:00 PM",
                student: "Ayesha Khan",
                color: Colors.blue,
              ),

              _classTile(
                subject: "Physics",
                time: "6:00 PM",
                student: "Bilal Ahmed",
                color: Colors.orange,
              ),

              _classTile(
                subject: "Programming",
                time: "8:00 PM",
                student: "Sara Malik",
                color: Colors.green,
              ),

              const SizedBox(height: 25),

              /// -----------------------------------------------------
              /// ACTIVE STUDENTS
              /// -----------------------------------------------------
              _sectionTitle("Active Students", LucideIcons.users),

              _studentsRow(),

              const SizedBox(height: 30),

              /// -----------------------------------------------------
              /// ACTION BUTTONS
              /// -----------------------------------------------------
              _sectionTitle("Quick Actions", LucideIcons.bold),

              const SizedBox(height: 12),

              _quickActions(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// -----------------------------------------------------
  /// HEADER WIDGET
  /// -----------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 35),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff4B6FFF), Color(0xff6C8CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(32),
          bottomLeft: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_rounded, size: 34, color: Colors.white),
          ),
          const SizedBox(width: 14),

          /// ✅ IMPORTANT FIX
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Hello Ali 👋",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                Text(
                  "Welcome Back!",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          const Icon(LucideIcons.bell, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  /// -----------------------------------------------------
  /// STAT CARD
  /// -----------------------------------------------------
  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xff1C1C1C),
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  /// -----------------------------------------------------
  /// SECTION TITLE
  /// -----------------------------------------------------
  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Color(0xff1C1C1C),
            ),
          ),
        ],
      ),
    );
  }

  /// -----------------------------------------------------
  /// CLASS TILE
  /// -----------------------------------------------------
  Widget _classTile({
    required String subject,
    required String student,
    required String time,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(LucideIcons.bookOpen, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "With $student",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  /// -----------------------------------------------------
  /// ACTIVE STUDENTS CAROUSEL
  /// -----------------------------------------------------
  Widget _studentsRow() {
    final students = ["Ayesha", "Bilal", "Sara", "Ahmed", "Maria"];
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, right: 20),
        itemCount: students.length,
        itemBuilder: (_, i) {
          return Container(
            margin: const EdgeInsets.only(right: 18),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: Icon(LucideIcons.user, size: 26),
                ),
                const SizedBox(height: 6),
                Text(
                  students[i],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// -----------------------------------------------------
  /// QUICK ACTIONS ROW
  /// -----------------------------------------------------
  Widget _quickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _actionButton(
            label: "Start Class",
            icon: LucideIcons.playCircle,
            color: Colors.blue,
          ),
          _actionButton(
            label: "Add Course",
            icon: LucideIcons.plusCircle,
            color: Colors.green,
          ),
          _actionButton(
            label: "Messages",
            icon: LucideIcons.messageCircle,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 27,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }
}
