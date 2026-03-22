import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

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
  static const Color orange = Color(0xFFFF7B7B);
  static const Color noteBlue = Color(0xFF5A8CFF);
}

class StorageKeys {
  static const String personalNotes = 'personal_notes';
  static const String studyNotes = 'study_notes';
  static const String reportHistory = 'report_history';
  static const String timerCompletedSessions = 'timer_completed_sessions';
  static const String timerTotalStudyMinutes = 'timer_total_study_minutes';
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

  Map<String, dynamic> toMap() => {
        'title': title,
        'content': content,
        'date': date,
      };

  factory AppNote.fromMap(Map<String, dynamic> map) {
    return AppNote(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: map['date'] ?? '',
    );
  }
}

class DailyReportEntry {
  final String date;
  final int rating;
  final String summary;
  final int studyMinutes;
  final int completedTasks;
  final int focusSessions;

  DailyReportEntry({
    required this.date,
    required this.rating,
    required this.summary,
    required this.studyMinutes,
    required this.completedTasks,
    required this.focusSessions,
  });

  Map<String, dynamic> toMap() => {
        'date': date,
        'rating': rating,
        'summary': summary,
        'studyMinutes': studyMinutes,
        'completedTasks': completedTasks,
        'focusSessions': focusSessions,
      };

  factory DailyReportEntry.fromMap(Map<String, dynamic> map) {
    return DailyReportEntry(
      date: map['date'] ?? '',
      rating: map['rating'] ?? 0,
      summary: map['summary'] ?? '',
      studyMinutes: map['studyMinutes'] ?? 0,
      completedTasks: map['completedTasks'] ?? 0,
      focusSessions: map['focusSessions'] ?? 0,
    );
  }
}

class TimerStats {
  final int completedFocusSessions;
  final int totalStudyMinutes;

  const TimerStats({
    required this.completedFocusSessions,
    required this.totalStudyMinutes,
  });

  TimerStats copyWith({
    int? completedFocusSessions,
    int? totalStudyMinutes,
  }) {
    return TimerStats(
      completedFocusSessions:
          completedFocusSessions ?? this.completedFocusSessions,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
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
  List<DailyReportEntry> reportHistory = [];
  TimerStats timerStats = const TimerStats(
    completedFocusSessions: 0,
    totalStudyMinutes: 0,
  );

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
    final prefs = await SharedPreferences.getInstance();

    final personalRaw = prefs.getString(StorageKeys.personalNotes);
    final studyRaw = prefs.getString(StorageKeys.studyNotes);
    final reportRaw = prefs.getString(StorageKeys.reportHistory);

    final loadedPersonal = personalRaw == null
        ? <AppNote>[
            AppNote(
              title: 'Personal Note',
              content: 'Today I need to stay away from distractions.',
              date: todayLabel(),
            ),
          ]
        : (jsonDecode(personalRaw) as List)
            .map((e) => AppNote.fromMap(Map<String, dynamic>.from(e)))
            .toList();

    final loadedStudy = studyRaw == null
        ? <AppNote>[
            AppNote(
              title: 'Study Note',
              content: 'Revise chapter 3 and math formulas.',
              date: todayLabel(),
            ),
          ]
        : (jsonDecode(studyRaw) as List)
            .map((e) => AppNote.fromMap(Map<String, dynamic>.from(e)))
            .toList();

    final loadedReports = reportRaw == null
        ? <DailyReportEntry>[
            DailyReportEntry(
              date: todayLabel(),
              rating: 6,
              summary: 'Good progress today.',
              studyMinutes: 0,
              completedTasks: 4,
              focusSessions: 0,
            ),
          ]
        : (jsonDecode(reportRaw) as List)
            .map((e) =>
                DailyReportEntry.fromMap(Map<String, dynamic>.from(e)))
            .toList();

    final completedSessions =
        prefs.getInt(StorageKeys.timerCompletedSessions) ?? 0;
    final totalStudyMinutes =
        prefs.getInt(StorageKeys.timerTotalStudyMinutes) ?? 0;

    setState(() {
      personalNotes = loadedPersonal;
      studyNotes = loadedStudy;
      reportHistory = loadedReports;
      timerStats = TimerStats(
        completedFocusSessions: completedSessions,
        totalStudyMinutes: totalStudyMinutes,
      );
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

  Future<void> saveReportHistory(List<DailyReportEntry> reports) async {
    reportHistory = reports;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      StorageKeys.reportHistory,
      jsonEncode(reports.map((e) => e.toMap()).toList()),
    );
    setState(() {});
  }

  Future<void> saveTimerStats(TimerStats stats) async {
    timerStats = stats;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      StorageKeys.timerCompletedSessions,
      stats.completedFocusSessions,
    );
    await prefs.setInt(
      StorageKeys.timerTotalStudyMinutes,
      stats.totalStudyMinutes,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MainShell(
      personalNotes: personalNotes,
      studyNotes: studyNotes,
      reportHistory: reportHistory,
      timerStats: timerStats,
      onPersonalNotesChanged: savePersonalNotes,
      onStudyNotesChanged: saveStudyNotes,
      onReportHistoryChanged: saveReportHistory,
      onTimerStatsChanged: saveTimerStats,
    );
  }
}

class MainShell extends StatefulWidget {
  final List<AppNote> personalNotes;
  final List<AppNote> studyNotes;
  final List<DailyReportEntry> reportHistory;
  final TimerStats timerStats;
  final Future<void> Function(List<AppNote>) onPersonalNotesChanged;
  final Future<void> Function(List<AppNote>) onStudyNotesChanged;
  final Future<void> Function(List<DailyReportEntry>) onReportHistoryChanged;
  final Future<void> Function(TimerStats) onTimerStatsChanged;

  const MainShell({
    super.key,
    required this.personalNotes,
    required this.studyNotes,
    required this.reportHistory,
    required this.timerStats,
    required this.onPersonalNotesChanged,
    required this.onStudyNotesChanged,
    required this.onReportHistoryChanged,
    required this.onTimerStatsChanged,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    final latestReport =
        widget.reportHistory.isNotEmpty ? widget.reportHistory.first : null;

    final pages = [
      TimerScreen(
        initialStats: widget.timerStats,
        onStatsChanged: (stats) async {
          await widget.onTimerStatsChanged(stats);
          setState(() {});
        },
      ),
      StatsPage(
        reportHistory: widget.reportHistory,
        timerStats: widget.timerStats,
      ),
      HomeScreen(
        personalNotes: widget.personalNotes,
        studyNotes: widget.studyNotes,
        latestReport: latestReport,
        timerStats: widget.timerStats,
        reportHistory: widget.reportHistory,
        onPersonalNotesChanged: widget.onPersonalNotesChanged,
        onStudyNotesChanged: widget.onStudyNotesChanged,
        onReportHistoryChanged: widget.onReportHistoryChanged,
        onTimerStatsChanged: widget.onTimerStatsChanged,
      ),
      DailyReportScreen(
        reportHistory: widget.reportHistory,
        timerStats: widget.timerStats,
        onSaveHistory: (reports) async {
          await widget.onReportHistoryChanged(reports);
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
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: selectedIndex,
        onSelect: (index) => setState(() => selectedIndex = index),
      ),
    );
  }
}

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: 12,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 18,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  NavItem(
                    icon: Icons.timer_rounded,
                    label: 'Timer',
                    selected: selectedIndex == 0,
                    onTap: () => onSelect(0),
                  ),
                  NavItem(
                    icon: Icons.analytics_rounded,
                    label: 'Stats',
                    selected: selectedIndex == 1,
                    onTap: () => onSelect(1),
                  ),
                  const SizedBox(width: 70),
                  NavItem(
                    icon: Icons.star_rounded,
                    label: 'Daily Report',
                    selected: selectedIndex == 3,
                    onTap: () => onSelect(3),
                  ),
                  NavItem(
                    icon: Icons.sticky_note_2_rounded,
                    label: 'Notes',
                    selected: selectedIndex == 4,
                    onTap: () => onSelect(4),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -6,
            child: GestureDetector(
              onTap: () => onSelect(2),
              child: Container(
                height: 68,
                width: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF34D8FF),
                      Color(0xFF2E7DFF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF34D8FF).withOpacity(0.55),
                      blurRadius: 22,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: const Icon(Icons.home_rounded,
                    color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : Colors.white54;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
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
  final DailyReportEntry? latestReport;
  final TimerStats timerStats;
  final List<DailyReportEntry> reportHistory;
  final Future<void> Function(List<AppNote>) onPersonalNotesChanged;
  final Future<void> Function(List<AppNote>) onStudyNotesChanged;
  final Future<void> Function(List<DailyReportEntry>) onReportHistoryChanged;
  final Future<void> Function(TimerStats) onTimerStatsChanged;

  const HomeScreen({
    super.key,
    required this.personalNotes,
    required this.studyNotes,
    required this.latestReport,
    required this.timerStats,
    required this.reportHistory,
    required this.onPersonalNotesChanged,
    required this.onStudyNotesChanged,
    required this.onReportHistoryChanged,
    required this.onTimerStatsChanged,
  });

  void open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final todayRating = latestReport?.rating ?? 0;
    final todaySummary = latestReport?.summary ?? 'No summary yet.';
    return AppPage(
      title: 'Home',
      actions: const [
        Icon(Icons.notifications_none_rounded, color: Colors.white),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.02,
            children: [
              HomeFeatureCard(
                title: 'Timer',
                subtitle: '25 / 5 focus',
                icon: Icons.timer_rounded,
                color: AppColors.blue,
                onTap: () => open(
                  context,
                  TimerScreen(
                    initialStats: timerStats,
                    onStatsChanged: onTimerStatsChanged,
                  ),
                ),
              ),
              HomeFeatureCard(
                title: 'Reminder',
                subtitle: 'Tasks and assistant',
                icon: Icons.notifications_active_rounded,
                color: AppColors.orange,
                onTap: () => open(context, const ReminderScreen()),
              ),
              HomeFeatureCard(
                title: 'Daily Tasks',
                subtitle: 'Your task list',
                icon: Icons.check_circle_rounded,
                color: AppColors.green,
                onTap: () => open(context, const DailyTasksScreen()),
              ),
              HomeFeatureCard(
                title: 'Motivation',
                subtitle: 'Quotes and goals',
                icon: Icons.auto_awesome_rounded,
                color: AppColors.purple,
                onTap: () => open(context, const MotivationScreen()),
              ),
              HomeFeatureCard(
                title: 'Daily Report',
                subtitle: 'Save and review',
                icon: Icons.star_rounded,
                color: AppColors.gold,
                onTap: () => open(
                  context,
                  DailyReportScreen(
                    reportHistory: reportHistory,
                    timerStats: timerStats,
                    onSaveHistory: onReportHistoryChanged,
                  ),
                ),
              ),
              HomeFeatureCard(
                title: 'Notes',
                subtitle: 'Personal and study',
                icon: Icons.sticky_note_2_rounded,
                color: AppColors.noteBlue,
                onTap: () => open(
                  context,
                  NotesMainScreen(
                    personalNotes: personalNotes,
                    studyNotes: studyNotes,
                    onPersonalNotesChanged: onPersonalNotesChanged,
                    onStudyNotesChanged: onStudyNotesChanged,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: premiumCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today Summary',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 14),
                SummaryRow(
                  icon: Icons.star_rounded,
                  label: 'Today Rating',
                  value: '$todayRating/10',
                ),
                const SizedBox(height: 12),
                SummaryRow(
                  icon: Icons.repeat_rounded,
                  label: 'Focus Sessions',
                  value: '${timerStats.completedFocusSessions}',
                ),
                const SizedBox(height: 12),
                SummaryRow(
                  icon: Icons.timer_rounded,
                  label: 'Total Study Time',
                  value: formatMinutes(timerStats.totalStudyMinutes),
                ),
                const SizedBox(height: 12),
                SummaryRow(
                  icon: Icons.notes_rounded,
                  label: 'Personal Notes',
                  value: '${personalNotes.length}',
                ),
                const SizedBox(height: 12),
                SummaryRow(
                  icon: Icons.menu_book_rounded,
                  label: 'Study Notes',
                  value: '${studyNotes.length}',
                ),
                const SizedBox(height: 16),
                Text(
                  todaySummary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    height: 1.4,
                    decoration: TextDecoration.none,
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
                      colors: [color, color.withOpacity(0.55)],
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
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: const [
          ReminderMenuCardStatic(
            title: 'To-Do Reminder',
            subtitle: 'Create reminders for tasks and deadlines.',
            icon: Icons.checklist_rounded,
          ),
          SizedBox(height: 14),
          ReminderMenuCardStatic(
            title: 'Assistant Reminder',
            subtitle: 'Check-in prompts and focus messages.',
            icon: Icons.smart_toy_rounded,
          ),
          SizedBox(height: 14),
          ReminderMenuCardStatic(
            title: 'Session Reminder',
            subtitle: 'Morning, afternoon, and evening sessions.',
            icon: Icons.schedule_rounded,
          ),
        ],
      ),
    );
  }
}

class ReminderMenuCardStatic extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const ReminderMenuCardStatic({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: premiumCardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [AppColors.blue, AppColors.purple],
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
        ],
      ),
    );
  }
}

class MotivationScreen extends StatelessWidget {
  const MotivationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Motivation',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: const [
          LargeTextBox(
            title: 'Today Quote',
            content:
                'Success is the sum of small efforts, repeated day in and day out.',
          ),
          SizedBox(height: 14),
          InfoBox(
            title: 'Today Goal',
            value: 'Study for 4 hours and complete your important tasks.',
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
    return AppPage(
      title: 'Daily Tasks',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: const [
          ReminderEntryCard(title: 'Math Practice', value: 'Pending'),
          SizedBox(height: 12),
          ReminderEntryCard(title: 'Physics Chapter 2', value: 'Pending'),
          SizedBox(height: 12),
          ReminderEntryCard(title: 'English Essay', value: 'Done'),
          SizedBox(height: 12),
          ReminderEntryCard(title: 'History Revision', value: 'Done'),
        ],
      ),
    );
  }
}

class TimerScreen extends StatefulWidget {
  final TimerStats initialStats;
  final Future<void> Function(TimerStats) onStatsChanged;

  const TimerScreen({
    super.key,
    required this.initialStats,
    required this.onStatsChanged,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  static const int focusSeconds = 25 * 60;
  static const int breakSeconds = 5 * 60;

  late int remainingSeconds;
  bool isBreakMode = false;
  bool isRunning = false;
  Timer? timer;

  late int completedFocusSessions;
  late int totalStudyMinutes;

  @override
  void initState() {
    super.initState();
    remainingSeconds = focusSeconds;
    completedFocusSessions = widget.initialStats.completedFocusSessions;
    totalStudyMinutes = widget.initialStats.totalStudyMinutes;
  }

  int get totalCurrentModeSeconds => isBreakMode ? breakSeconds : focusSeconds;
  double get progress => remainingSeconds / totalCurrentModeSeconds;
  Color get ringColor => isBreakMode ? AppColors.red : AppColors.green;
  String get modeLabel => isBreakMode ? 'Break Timer' : 'Pomodoro Timer';

  String get timeLabel {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> persistStats() async {
    await widget.onStatsChanged(
      TimerStats(
        completedFocusSessions: completedFocusSessions,
        totalStudyMinutes: totalStudyMinutes,
      ),
    );
  }

  void startTimer() {
    if (isRunning) return;
    setState(() => isRunning = true);

    timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (remainingSeconds <= 1) {
        t.cancel();

        if (!isBreakMode) {
          completedFocusSessions += 1;
          totalStudyMinutes += 25;
          await persistStats();
          setState(() {
            isBreakMode = true;
            remainingSeconds = breakSeconds;
            isRunning = false;
          });
        } else {
          setState(() {
            isBreakMode = false;
            remainingSeconds = focusSeconds;
            isRunning = false;
          });
        }
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      isBreakMode = false;
      remainingSeconds = focusSeconds;
    });
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
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: premiumCardDecoration(),
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  width: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(250, 250),
                        painter: ProgressRingPainter(
                          progress: progress,
                          color: ringColor,
                        ),
                      ),
                      Container(
                        height: 190,
                        width: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              ringColor.withOpacity(0.18),
                              const Color(0xFF163255),
                              const Color(0xFF0D1B2E),
                            ],
                          ),
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
                                      fontSize: 44,
                                      fontWeight: FontWeight.w800,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    modeLabel,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 22,
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
                    ],
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
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: premiumCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Timer Summary',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 14),
                SummaryRow(
                  icon: Icons.repeat_rounded,
                  label: 'Completed Focus Sessions',
                  value: '$completedFocusSessions',
                ),
                const SizedBox(height: 12),
                SummaryRow(
                  icon: Icons.timer_rounded,
                  label: 'Total Study Time',
                  value: formatMinutes(totalStudyMinutes),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  ProgressRingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 18.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;

    final basePaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class DailyReportScreen extends StatefulWidget {
  final List<DailyReportEntry> reportHistory;
  final TimerStats timerStats;
  final Future<void> Function(List<DailyReportEntry>) onSaveHistory;

  const DailyReportScreen({
    super.key,
    required this.reportHistory,
    required this.timerStats,
    required this.onSaveHistory,
  });

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  late int rating;
  late TextEditingController summaryController;
  late List<DailyReportEntry> history;

  @override
  void initState() {
    super.initState();
    history = List.from(widget.reportHistory);

    final today = todayLabel();
    final todayEntry = history.cast<DailyReportEntry?>().firstWhere(
          (e) => e?.date == today,
          orElse: () => null,
        );

    rating = todayEntry?.rating ?? 6;
    summaryController = TextEditingController(
      text: todayEntry?.summary ?? '',
    );
  }

  Future<void> saveTodayReport() async {
    final today = todayLabel();
    final newEntry = DailyReportEntry(
      date: today,
      rating: rating,
      summary: summaryController.text.trim(),
      studyMinutes: widget.timerStats.totalStudyMinutes,
      completedTasks: 4,
      focusSessions: widget.timerStats.completedFocusSessions,
    );

    final updated = List<DailyReportEntry>.from(history);
    final existingIndex = updated.indexWhere((e) => e.date == today);

    if (existingIndex >= 0) {
      updated[existingIndex] = newEntry;
    } else {
      updated.insert(0, newEntry);
    }

    setState(() => history = updated);
    await widget.onSaveHistory(updated);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Daily report saved')),
    );
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
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
                      onTap: () => setState(() => rating = starNumber),
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
                const SizedBox(height: 14),
                TextField(
                  controller: summaryController,
                  maxLines: 5,
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
                  onTap: saveTodayReport,
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
                  'Report History',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 14),
                if (history.isEmpty)
                  const Text(
                    'No saved reports yet.',
                    style: TextStyle(
                      color: AppColors.muted,
                      decoration: TextDecoration.none,
                    ),
                  )
                else
                  ...history.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.date,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Rating: ${entry.rating}/10',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Study Time: ${formatMinutes(entry.studyMinutes)}',
                              style: const TextStyle(
                                color: AppColors.muted,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tasks Done: ${entry.completedTasks}',
                              style: const TextStyle(
                                color: AppColors.muted,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Focus Sessions: ${entry.focusSessions}',
                              style: const TextStyle(
                                color: AppColors.muted,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry.summary.isEmpty
                                  ? 'No summary written.'
                                  : entry.summary,
                              style: const TextStyle(
                                color: AppColors.muted,
                                height: 1.4,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatsPage extends StatelessWidget {
  final List<DailyReportEntry> reportHistory;
  final TimerStats timerStats;

  const StatsPage({
    super.key,
    required this.reportHistory,
    required this.timerStats,
  });

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Stats',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: premiumCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 14),
                SummaryRow(
                  icon: Icons.repeat_rounded,
                  label: 'Focus Sessions',
                  value: '${timerStats.completedFocusSessions}',
                ),
                const SizedBox(height: 12),
                SummaryRow(
                  icon: Icons.timer_rounded,
                  label: 'Total Study Time',
                  value: formatMinutes(timerStats.totalStudyMinutes),
                ),
                const SizedBox(height: 12),
                SummaryRow(
                  icon: Icons.history_rounded,
                  label: 'Saved Reports',
                  value: '${reportHistory.length}',
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
                  'Daily Logs',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 14),
                if (reportHistory.isEmpty)
                  const Text(
                    'No logs yet.',
                    style: TextStyle(
                      color: AppColors.muted,
                      decoration: TextDecoration.none,
                    ),
                  )
                else
                  ...reportHistory.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.date,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Study Time: ${formatMinutes(entry.studyMinutes)}',
                              style: const TextStyle(
                                color: AppColors.muted,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tasks Done: ${entry.completedTasks}',
                              style: const TextStyle(
                                color: AppColors.muted,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rating: ${entry.rating}/10',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry.summary,
                              style: const TextStyle(
                                color: AppColors.muted,
                                height: 1.4,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          NotesMenuCard(
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
          NotesMenuCard(
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

class NotesMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const NotesMenuCard({
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
                      colors: [AppColors.noteBlue, AppColors.blue],
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
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
          ),
        ),
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

      setState(() => notes.insert(0, newNote));
      await widget.onSave(notes);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Note saved')));
    }
  }

  Future<void> deleteNote(int index) async {
    final updated = List<AppNote>.from(notes)..removeAt(index);
    setState(() => notes = updated);
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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

String formatMinutes(int totalMinutes) {
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours == 0) return '${minutes}m';
  return '${hours}h ${minutes}m';
}
