import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          initialRoute: '/',
          routes: {
            '/': (context) => const LessonScreenWrapper(),
            '/downloadManager': (context) => const DownloadManagerScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}

class LessonScreenWrapper extends StatefulWidget {
  const LessonScreenWrapper({super.key});

  @override
  State<LessonScreenWrapper> createState() => _LessonScreenWrapperState();
}

class _LessonScreenWrapperState extends State<LessonScreenWrapper> {
  late Future<List<Lesson>> _lessonsFuture;
  Lesson? _currentLesson;
  String? _targetHeadingSlug;

  @override
  void initState() {
    super.initState();
    _lessonsFuture = ContentService().loadLessons();
  }

  void _navigateToLessonBySlug(String slug, {String? headingSlug}) {
    _lessonsFuture.then((lessons) {
      try {
        final lesson = lessons.firstWhere((l) => l.slug == slug);
        if (mounted) {
          setState(() {
            _currentLesson = lesson;
            _targetHeadingSlug = headingSlug;
          });
        }
      } catch (e) {
        if (mounted) {
          _navigateToLessonBySlug('title-page');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Lesson>>(
      future: _lessonsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading lessons...'),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _lessonsFuture = ContentService().loadLessons();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasData) {
          final lessons = snapshot.data!;

          if (_currentLesson != null) {
            return LessonScreen(
              lesson: _currentLesson!,
              onNavigateToLesson: _navigateToLessonBySlug,
              lessons: lessons,
              targetHeadingSlug: _targetHeadingSlug,
            );
          }

          // If no lesson is selected, show the first lesson by default
          if (lessons.isNotEmpty) {
            // Only set the current lesson if it hasn't been set yet
            if (_currentLesson == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _currentLesson = lessons.first;
                  });
                }
              });
            }
            return LessonScreen(
              lesson: _currentLesson ?? lessons.first,
              onNavigateToLesson: _navigateToLessonBySlug,
              lessons: lessons,
            );
          }

          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No lessons found'),
                ],
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No lessons found'),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
