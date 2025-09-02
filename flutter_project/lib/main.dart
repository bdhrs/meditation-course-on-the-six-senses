import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          home: const HomeScreen(),
          routes: {
            '/downloadManager': (context) => const DownloadManagerScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      final lesson = lessons.firstWhere((l) => l.slug == slug);
      setState(() {
        _currentLesson = lesson;
      });
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
