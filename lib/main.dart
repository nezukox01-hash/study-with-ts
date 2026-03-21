import 'package:flutter/material.dart';

void main() {
  runApp(const StudyWithTSApp());
}

class StudyWithTSApp extends StatelessWidget {
  const StudyWithTSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study with TS',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF071120),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class AppColors {
  static const Color bg = Color(0xFF071120);
  static const Color surface = Color(0xFF12243C);
  static const Color surface2 = Color(0xFF0D1B2E);
  static const Color border = Color(0xFF223854);
  static const Color text = Colors.white;
  static const Color muted = Colors.white70;
  static const Color gold = Color(0xFFFFB84D);
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    ReminderScreen(),
    DailyReportScreen(),
    PersonalNotesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        height: 72,
        backgroundColor: AppColors.surface2,
        indicatorColor: Colors.blue.withOpacity(0.20),
        selectedIndex: selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_active_rounded),
            label: 'Reminder',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_rounded),
            label: 'Daily Report',
          ),
          NavigationDestination(
            icon: Icon(Icons.sticky_note_2_rounded),
            label: 'Notes',
          ),
        ],
      ),
    );
  }
}

class AppPage extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF10284A),
            Color(0xFF071120),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const Spacer(),
                  ...?actions,
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Home',
      actions: const [
        Icon(Icons.notifications_none_rounded, color: Colors.white),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: premiumCardDecoration(),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Study with TS',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Stay focused and finish today strong.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.08,
            children: [
              HomeFeatureCard(
                title: 'Reminder',
                subtitle: 'Tasks and assistant',
                icon: Icons.notifications_active_rounded,
                color: const Color(0xFFFF7B7B),
                onTap: () => _openPage(context, const ReminderScreen()),
              ),
              HomeFeatureCard(
                title: 'Motivation',
                subtitle: 'Quotes and goals',
                icon: Icons.auto_awesome_rounded,
                color: const Color(0xFF7B61FF),
                onTap: () => _openPage(context, const MotivationScreen()),
              ),
              HomeFeatureCard(
                title: 'Timer',
                subtitle: 'Focus sessions',
                icon: Icons.timer_rounded,
                color: const Color(0xFF4A8BFF),
                onTap: () => _openPage(context, const TimerScreen()),
              ),
              HomeFeatureCard(
                title: 'Daily Tasks',
                subtitle: 'Your task list',
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF20B486),
                onTap: () => _openPage(context, const DailyTasksScreen()),
              ),
              HomeFeatureCard(
                title: 'Personal Notes',
                subtitle: 'Save by date',
                icon: Icons.sticky_note_2_rounded,
                color: const Color(0xFF5A8CFF),
                onTap: () => _openPage(context, const PersonalNotesScreen()),
              ),
              HomeFeatureCard(
                title: 'Daily Report',
                subtitle: 'Rate your day',
                icon: Icons.star_rounded,
                color: const Color(0xFFFFB84D),
                onTap: () => _openPage(context, const DailyReportScreen()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: premiumCardDecoration(),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summary',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 14),
                SummaryRow(
                  icon: Icons.menu_book_rounded,
                  label: 'Study Time',
                  value: '3h 15m',
                ),
                SizedBox(height: 12),
                SummaryRow(
                  icon: Icons.task_alt_rounded,
                  label: 'Tasks Completed',
                  value: '4 / 5',
                ),
                SizedBox(height: 12),
                SummaryRow(
                  icon: Icons.cloud_done_rounded,
                  label: 'Data Sync',
                  value: 'Enabled',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const HomeFeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          decoration: premiumCardDecoration(),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color.withOpacity(0.55),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Reminder',
      actions: const [
        Icon(Icons.notifications_none_rounded, color: Colors.white),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          ReminderMenuCard(
            title: 'To-Do Reminder',
            subtitle: 'Create reminders for tasks and deadlines.',
            icon: Icons.checklist_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TodoReminderScreen()),
              );
            },
          ),
          const SizedBox(height: 14),
          ReminderMenuCard(
            title: 'Assistant Reminder',
            subtitle: 'Check-in prompts and focus messages.',
            icon: Icons.smart_toy_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AssistantReminderScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          ReminderMenuCard(
            title: 'Session Reminder',
            subtitle: 'Morning, afternoon, and evening sessions.',
            icon: Icons.schedule_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SessionReminderScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ReminderMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const ReminderMenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: premiumCardDecoration(),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4A8BFF),
                        Color(0xFF7B61FF),
                      ],
                    ),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TodoReminderScreen extends StatelessWidget {
  const TodoReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DetailPage(
      title: 'To-Do Reminder',
      child: Column(
        children: [
          TaskTile(title: 'Finish Math Chapter', time: '10:30 AM'),
          SizedBox(height: 12),
          TaskTile(title: 'Read History Notes', time: '02:00 PM'),
          SizedBox(height: 12),
          TaskTile(title: 'Complete Science Quiz', time: '05:30 PM'),
        ],
      ),
    );
  }
}

class AssistantReminderScreen extends StatelessWidget {
  const AssistantReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DetailPage(
      title: 'Assistant Reminder',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoBox(
            title: 'Check-In Interval',
            value: 'Every 2 Hours',
          ),
          SizedBox(height: 14),
          InfoBox(
            title: 'Mode',
            value: 'Friendly',
          ),
          SizedBox(height: 14),
          LargeTextBox(
            title: 'Reminder Message',
            content: 'How is your study going? Stay focused!',
          ),
        ],
      ),
    );
  }
}

class SessionReminderScreen extends StatelessWidget {
  const SessionReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DetailPage(
      title: 'Session Reminder',
      child: Column(
        children: [
          TaskTile(title: 'Morning Session', time: '8:00 AM - 12:00 PM'),
          SizedBox(height: 12),
          TaskTile(title: 'Afternoon Session', time: '2:00 PM - 4:00 PM'),
          SizedBox(height: 12),
          TaskTile(title: 'Evening Session', time: '6:00 PM - 11:00 PM'),
        ],
      ),
    );
  }
}

class MotivationScreen extends StatelessWidget {
  const MotivationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DetailPage(
      title: 'Motivation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LargeTextBox(
            title: 'Today Quote',
            content:
                'Success is the sum of small efforts, repeated day in and day out.',
          ),
          SizedBox(height: 14),
          InfoBox(
            title: 'Today Goal',
            value: 'Study for 4 hours and complete 5 tasks',
          ),
        ],
      ),
    );
  }
}

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Timer',
      actions: const [
        Icon(Icons.tune_rounded, color: Colors.white),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: premiumCardDecoration(),
            child: Column(
              children: [
                Container(
                  height: 230,
                  width: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.blue.withOpacity(0.35),
                        const Color(0xFF163255),
                        const Color(0xFF0D1B2E),
                      ],
                    ),
                    border: Border.all(color: AppColors.border, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.22),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '25:00',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pomodoro Timer',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Start',
                        color: Color(0xFF4A8BFF),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Pause',
                        color: Color(0xFF1B3558),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Reset',
                        color: Color(0xFFE55B6B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DailyTasksScreen extends StatelessWidget {
  const DailyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DetailPage(
      title: 'Daily Tasks',
      child: Column(
        children: [
          TaskTile(title: 'Math Practice', time: 'Pending'),
          SizedBox(height: 12),
          TaskTile(title: 'Physics Chapter 2', time: 'Pending'),
          SizedBox(height: 12),
          TaskTile(title: 'English Essay', time: 'Done'),
        ],
      ),
    );
  }
}

class DailyReportScreen extends StatelessWidget {
  const DailyReportScreen({super.key});

  Widget star(bool filled) {
    return Icon(
      Icons.star_rounded,
      color: filled ? AppColors.gold : Colors.white24,
      size: 28,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Daily Report',
      actions: const [
        Icon(Icons.edit_note_rounded, color: Colors.white),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: premiumCardDecoration(),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Stats',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 14),
                SummaryRow(
                  icon: Icons.menu_book_rounded,
                  label: 'Study Time',
                  value: '3 hrs 15 mins',
                ),
                SizedBox(height: 12),
                SummaryRow(
                  icon: Icons.task_alt_rounded,
                  label: 'Tasks Completed',
                  value: '4 / 5',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: premiumCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rate Your Day',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    star(true),
                    star(true),
                    star(true),
                    star(true),
                    star(true),
                    star(true),
                    star(false),
                    star(false),
                    star(false),
                    star(false),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: premiumCardDecoration(),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Summary',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Feeling good! Completed most of my tasks. Need to review a bit more on history, but made great progress today.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PersonalNotesScreen extends StatelessWidget {
  const PersonalNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Personal Notes',
      actions: const [
        Icon(Icons.add_rounded, color: Colors.white),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: const [
          NoteCard(
            date: 'April 12, 2026',
            title: 'Personal Note',
            content:
                'Today I stayed more focused in the afternoon. I need to reduce phone distraction at night.',
          ),
          SizedBox(height: 14),
          NoteCard(
            date: 'April 12, 2026',
            title: 'Study Note',
            content:
                'History chapter 3 needs revision. Math formulas from algebra should be reviewed again.',
          ),
        ],
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final String date;
  final String title;
  final String content;

  const NoteCard({
    super.key,
    required this.date,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: premiumCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String title;
  final Widget child;

  const DetailPage({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF10284A),
            Color(0xFF071120),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 20, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [child],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final String title;
  final String time;

  const TaskTile({
    super.key,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: premiumCardDecoration(),
      child: Row(
        children: [
          const Icon(Icons.check_rounded, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  final String title;
  final String value;

  const InfoBox({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: premiumCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class LargeTextBox extends StatelessWidget {
  final String title;
  final String content;

  const LargeTextBox({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: premiumCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const SummaryRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.lightBlueAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 15,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class AppButton extends StatelessWidget {
  final String label;
  final Color color;

  const AppButton({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

BoxDecoration premiumCardDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(26),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF162B47),
        Color(0xFF0D1B2E),
      ],
    ),
    border: Border.all(color: AppColors.border),
    boxShadow: const [
      BoxShadow(
        color: Colors.black54,
        blurRadius: 24,
        offset: Offset(0, 14),
      ),
    ],
  );
}
