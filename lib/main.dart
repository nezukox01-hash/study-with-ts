import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF071120),
        useMaterial3: true,
      ),
      home: const AppLoader(),
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
  static const Color blue = Color(0xFF4A8BFF);
  static const Color purple = Color(0xFF7B61FF);
  static const Color green = Color(0xFF20B486);
  static const Color red = Color(0xFFE55B6B);
}

class StorageKeys {
  static const String personalNotes = 'personal_notes';
  static const String studyNotes = 'study_notes';
  static const String reportRating = 'report_rating';
  static const String reportSummary = 'report_summary';
}

class AppNote {
  final String title;
  final String content;
  final String date;

  AppNote({
    required this.title,
    required this.content,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'date': date,
    };
  }

  factory AppNote.fromMap(Map<String, dynamic> map) {
    return AppNote(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: map['date'] ?? '',
    );
  }
}

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  bool isLoading = true;
  List<AppNote> personalNotes = [];
  List<AppNote> studyNotes = [];
  int dailyRating = 6;
  String dailySummary = '';

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
    final prefs = await SharedPreferences.getInstance();

    final personalRaw = prefs.getString(StorageKeys.personalNotes);
    final studyRaw = prefs.getString(StorageKeys.studyNotes);

    final List<AppNote> loadedPersonal = personalRaw == null
        ? [
            AppNote(
              title: 'Personal Note',
              content:
                  'Today I stayed more focused in the afternoon. I need to reduce phone distraction at night.',
              date: todayLabel(),
            ),
          ]
        : (jsonDecode(personalRaw) as List)
            .map((e) => AppNote.fromMap(Map<String, dynamic>.from(e)))
            .toList();

    final List<AppNote> loadedStudy = studyRaw == null
        ? [
            AppNote(
              title: 'History Notes',
              content:
                  'Chapter 3 needs revision. Focus on key events and dates before the next session.',
              date: todayLabel(),
            ),
          ]
        : (jsonDecode(studyRaw) as List)
            .map((e) => AppNote.fromMap(Map<String, dynamic>.from(e)))
            .toList();

    setState(() {
      personalNotes = loadedPersonal;
      studyNotes = loadedStudy;
      dailyRating = prefs.getInt(StorageKeys.reportRating) ?? 6;
      dailySummary = prefs.getString(StorageKeys.reportSummary) ??
          'Feeling good! Completed most of my tasks and made solid progress today.';
      isLoading = false;
    });
  }

  Future<void> savePersonalNotes(List<AppNote> notes) async {
    personalNotes = notes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      StorageKeys.personalNotes,
      jsonEncode(notes.map((e) => e.toMap()).toList()),
    );
    setState(() {});
  }

  Future<void> saveStudyNotes(List<AppNote> notes) async {
    studyNotes = notes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      StorageKeys.studyNotes,
      jsonEncode(notes.map((e) => e.toMap()).toList()),
    );
    setState(() {});
  }

  Future<void> saveDailyReport({
    required int rating,
    required String summary,
  }) async {
    dailyRating = rating;
    dailySummary = summary;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageKeys.reportRating, rating);
    await prefs.setString(StorageKeys.reportSummary, summary);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return MainScreen(
      personalNotes: personalNotes,
      studyNotes: studyNotes,
      dailyRating: dailyRating,
      dailySummary: dailySummary,
      onPersonalNotesChanged: savePersonalNotes,
      onStudyNotesChanged: saveStudyNotes,
      onDailyReportChanged: saveDailyReport,
    );
  }
}

class MainScreen extends StatefulWidget {
  final List<AppNote> personalNotes;
  final List<AppNote> studyNotes;
  final int dailyRating;
  final String dailySummary;
  final Future<void> Function(List<AppNote>) onPersonalNotesChanged;
  final Future<void> Function(List<AppNote>) onStudyNotesChanged;
  final Future<void> Function({required int rating, required String summary})
      onDailyReportChanged;

  const MainScreen({
    super.key,
    required this.personalNotes,
    required this.studyNotes,
    required this.dailyRating,
    required this.dailySummary,
    required this.onPersonalNotesChanged,
    required this.onStudyNotesChanged,
    required this.onDailyReportChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        personalNotes: widget.personalNotes,
        studyNotes: widget.studyNotes,
        dailyRating: widget.dailyRating,
      ),
      const ReminderScreen(),
      DailyReportScreen(
        initialRating: widget.dailyRating,
        initialSummary: widget.dailySummary,
        onSave: ({required int rating, required String summary}) async {
          await widget.onDailyReportChanged(rating: rating, summary: summary);
          setState(() {});
        },
      ),
      NotesMainScreen(
        personalNotes: widget.personalNotes,
        studyNotes: widget.studyNotes,
        onPersonalNotesChanged: (notes) async {
          await widget.onPersonalNotesChanged(notes);
          setState(() {});
        },
        onStudyNotesChanged: (notes) async {
          await widget.onStudyNotesChanged(notes);
          setState(() {});
        },
      ),
    ];

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
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
  final List<AppNote> personalNotes;
  final List<AppNote> studyNotes;
  final int dailyRating;

  const HomeScreen({
    super.key,
    required this.personalNotes,
    required this.studyNotes,
    required this.dailyRating,
  });

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Study with TS',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay focused and finish today strong.',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt_rounded, color: AppColors.gold),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Today rating: $dailyRating/10 · Personal notes: ${personalNotes.length} · Study notes: ${studyNotes.length}',
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
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
            childAspectRatio: 1.02,
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
                subtitle: 'Working timer',
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
                title: 'Notes',
                subtitle: 'Personal and study',
                icon: Icons.sticky_note_2_rounded,
                color: const Color(0xFF5A8CFF),
                onTap: () => _openPage(
                  context,
                  NotesMainScreen(
                    personalNotes: personalNotes,
                    studyNotes: studyNotes,
                    onPersonalNotesChanged: (_) async {},
                    onStudyNotesChanged: (_) async {},
                  ),
                ),
              ),
              HomeFeatureCard(
                title: 'Daily Report',
                subtitle: 'Tap stars and save',
                icon: Icons.star_rounded,
                color: const Color(0xFFFFB84D),
                onTap: () => _openPage(
                  context,
                  DailyReportScreen(
                    initialRating: dailyRating,
                    initialSummary: '',
                    onSave: ({required int rating, required String summary}) async {},
                  ),
                ),
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
                    decoration: TextDecoration.none,
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
                  label: 'Data Saved',
                  value: 'Local',
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
                const SizedBox(height: 14),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        height: 1.2,
                        decoration: TextDecoration.none,
                      ),
                    ),
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
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                          decoration: TextDecoration.none,
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
          ReminderEntryCard(title: 'Finish Math Chapter', value: '10:30 AM'),
          SizedBox(height: 12),
          ReminderEntryCard(title: 'Read History Notes', value: '02:00 PM'),
          SizedBox(height: 12),
          ReminderEntryCard(title: 'Complete Science Quiz', value: '05:30 PM'),
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
          InfoBox(title: 'Check-In Interval', value: 'Every 2 Hours'),
          SizedBox(height: 14),
          InfoBox(title: 'Mode', value: 'Friendly'),
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
          ReminderEntryCard(title: 'Morning Session', value: '8:00 AM - 12:00 PM'),
          SizedBox(height: 12),
          ReminderEntryCard(title: 'Afternoon Session', value: '2:00 PM - 4:00 PM'),
          SizedBox(height: 12),
          ReminderEntryCard(title: 'Evening Session', value: '6:00 PM - 11:00 PM'),
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

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  static const int initialSeconds = 25 * 60;
  int remainingSeconds = initialSeconds;
  Timer? timer;
  bool isRunning = false;

  void startTimer() {
    if (isRunning) return;
    setState(() {
      isRunning = true;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds <= 1) {
        t.cancel();
        setState(() {
          remainingSeconds = 0;
          isRunning = false;
        });
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      remainingSeconds = initialSeconds;
      isRunning = false;
    });
  }

  String get timeLabel {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

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
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              timeLabel,
                              maxLines: 1,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Pomodoro Timer',
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Start',
                        color: AppColors.blue,
                        onTap: startTimer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Pause',
                        color: const Color(0xFF1B3558),
                        onTap: pauseTimer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Reset',
                        color: AppColors.red,
                        onTap: resetTimer,
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
          ReminderEntryCard(title: 'Math Practice', value: 'Pending'),
          SizedBox(height: 12),
          ReminderEntryCard(title: 'Physics Chapter 2', value: 'Pending'),
          SizedBox(height: 12),
          ReminderEntryCard(title: 'English Essay', value: 'Done'),
        ],
      ),
    );
  }
}

class DailyReportScreen extends StatefulWidget {
  final int initialRating;
  final String initialSummary;
  final Future<void> Function({required int rating, required String summary})
      onSave;

  const DailyReportScreen({
    super.key,
    required this.initialRating,
    required this.initialSummary,
    required this.onSave,
  });

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  late int rating;
  late TextEditingController summaryController;

  @override
  void initState() {
    super.initState();
    rating = widget.initialRating;
    summaryController = TextEditingController(text: widget.initialSummary);
  }

  @override
  void dispose() {
    summaryController.dispose();
    super.dispose();
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
                    decoration: TextDecoration.none,
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
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(10, (index) {
                    final starNumber = index + 1;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          rating = starNumber;
                        });
                      },
                      child: Icon(
                        Icons.star_rounded,
                        color: starNumber <= rating
                            ? AppColors.gold
                            : Colors.white24,
                        size: 28,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Text(
                  'Selected rating: $rating/10',
                  style: const TextStyle(
                    color: AppColors.muted,
                    decoration: TextDecoration.none,
                  ),
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
                  'Daily Summary',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: summaryController,
                  maxLines: 6,
                  style: const TextStyle(
                    color: AppColors.text,
                    decoration: TextDecoration.none,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write how your day went...',
                    hintStyle: const TextStyle(color: AppColors.muted),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: AppColors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                AppButton(
                  label: 'Save Report',
                  color: AppColors.blue,
                  onTap: () async {
                    await widget.onSave(
                      rating: rating,
                      summary: summaryController.text.trim(),
                    );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Daily report saved')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotesMainScreen extends StatelessWidget {
  final List<AppNote> personalNotes;
  final List<AppNote> studyNotes;
  final Future<void> Function(List<AppNote>) onPersonalNotesChanged;
  final Future<void> Function(List<AppNote>) onStudyNotesChanged;

  const NotesMainScreen({
    super.key,
    required this.personalNotes,
    required this.studyNotes,
    required this.onPersonalNotesChanged,
    required this.onStudyNotesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Notes',
      actions: const [
        Icon(Icons.add_rounded, color: Colors.white),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          ReminderMenuCard(
            title: 'Personal Notes',
            subtitle: 'Daily personal notes saved by date.',
            icon: Icons.person_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotesListScreen(
                    title: 'Personal Notes',
                    notes: personalNotes,
                    defaultNoteTitle: 'Personal Note',
                    emptyMessage: 'No personal notes yet.',
                    onSave: onPersonalNotesChanged,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          ReminderMenuCard(
            title: 'Study Notes',
            subtitle: 'Subject and topic notes saved by date.',
            icon: Icons.menu_book_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotesListScreen(
                    title: 'Study Notes',
                    notes: studyNotes,
                    defaultNoteTitle: 'Study Note',
                    emptyMessage: 'No study notes yet.',
                    onSave: onStudyNotesChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class NotesListScreen extends StatefulWidget {
  final String title;
  final List<AppNote> notes;
  final String defaultNoteTitle;
  final String emptyMessage;
  final Future<void> Function(List<AppNote>) onSave;

  const NotesListScreen({
    super.key,
    required this.title,
    required this.notes,
    required this.defaultNoteTitle,
    required this.emptyMessage,
    required this.onSave,
  });

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  late List<AppNote> notes;

  @override
  void initState() {
    super.initState();
    notes = List.from(widget.notes);
  }

  Future<void> addNoteDialog() async {
    final titleController = TextEditingController(text: widget.defaultNoteTitle);
    final contentController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.surface2,
          title: Text(
            'Add ${widget.title}',
            style: const TextStyle(color: AppColors.text),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: AppColors.muted),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    labelStyle: TextStyle(color: AppColors.muted),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final newNote = AppNote(
        title: titleController.text.trim().isEmpty
            ? widget.defaultNoteTitle
            : titleController.text.trim(),
        content: contentController.text.trim(),
        date: todayLabel(),
      );

      setState(() {
        notes.insert(0, newNote);
      });

      await widget.onSave(notes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note saved')),
      );
    }
  }

  Future<void> deleteNote(int index) async {
    final updated = List<AppNote>.from(notes)..removeAt(index);
    setState(() {
      notes = updated;
    });
    await widget.onSave(notes);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: widget.title,
      actions: [
        IconButton(
          onPressed: addNoteDialog,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ],
      child: notes.isEmpty
          ? Center(
              child: Text(
                widget.emptyMessage,
                style: const TextStyle(
                  color: AppColors.muted,
                  decoration: TextDecoration.none,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              itemCount: notes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, index) {
                final note = notes[index];
                return Stack(
                  children: [
                    NoteCard(
                      date: note.date,
                      title: note.title,
                      content: note.content,
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        onPressed: () => deleteNote(index),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                );
              },
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
      child: Padding(
        padding: const EdgeInsets.only(right: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content.isEmpty ? 'No content' : content,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 15,
                height: 1.5,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
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
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        decoration: TextDecoration.none,
                      ),
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

class ReminderEntryCard extends StatelessWidget {
  final String title;
  final String value;

  const ReminderEntryCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: premiumCardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.35,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
              ),
            ),
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
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 15,
              decoration: TextDecoration.none,
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
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 15,
              height: 1.5,
              decoration: TextDecoration.none,
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
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

class AppButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const AppButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
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
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
          ),
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

String todayLabel() {
  final now = DateTime.now();
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[now.month - 1]} ${now.day}, ${now.year}';
}
