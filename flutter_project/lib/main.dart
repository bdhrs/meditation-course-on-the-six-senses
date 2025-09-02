import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/landing_page_screen.dart';
import 'screens/table_of_contents_screen.dart';
import 'screens/lesson_screen.dart';
import 'screens/download_manager_screen.dart';
import 'screens/settings_screen.dart';
import 'models/lesson.dart';
import 'services/content_service.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Six Senses Meditation Course',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/landing',
          routes: {
            '/landing': (context) => const LandingPageScreen(),
            '/tableOfContents': (context) => const TableOfContentsScreenWrapper(),
            '/downloadManager': (context) => const DownloadManagerScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}

class TableOfContentsScreenWrapper extends StatefulWidget {
  const TableOfContentsScreenWrapper({super.key});

  @override
  State<TableOfContentsScreenWrapper> createState() => _TableOfContentsScreenWrapperState();
}

class _TableOfContentsScreenWrapperState extends State<TableOfContentsScreenWrapper> {
  late Future<List<Lesson>> _lessonsFuture;
  Lesson? _currentLesson;

  @override
  void initState() {
    super.initState();
    _lessonsFuture = ContentService().loadLessons();
  }

  void _navigateToLesson(Lesson lesson) {
    setState(() {
      _currentLesson = lesson;
    });
  }

  void _navigateToLessonBySlug(String slug) {
    _lessonsFuture.then((lessons) {
      try {
        final lesson = lessons.firstWhere((l) => l.slug == slug);
        // Check if the widget is still mounted before calling setState
        if (mounted) {
          setState(() {
            _currentLesson = lesson;
          });
        }
      } catch (e) {
        // If we can't find the lesson by slug, navigate back to landing page
        // We need to ensure we're still mounted before navigating
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/landing', (route) => false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLesson != null) {
      return LessonScreen(
        lesson: _currentLesson!,
        onNavigateToLesson: _navigateToLessonBySlug,
      );
    }

    return TableOfContentsScreen(
      onNavigateToLesson: _navigateToLesson,
    );
  }
}