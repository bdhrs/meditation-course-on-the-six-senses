import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/lesson_screen.dart';
import 'screens/settings_screen.dart';
import 'models/lesson.dart';
import 'services/content_service.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  JustAudioMediaKit.ensureInitialized();
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

class LessonHistoryEntry {
  final String lessonSlug;
  final double scrollOffset;

  LessonHistoryEntry({required this.lessonSlug, required this.scrollOffset});
}

class _LessonScreenWrapperState extends State<LessonScreenWrapper> {
  late Future<List<dynamic>> _initFuture;
  Lesson? _currentLesson;
  String? _targetHeadingSlug;
  final List<LessonHistoryEntry> _history = [];
  double? _initialScrollOffset;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _initFuture = Future.wait([
      ContentService().loadLessons(),
      SharedPreferences.getInstance(),
    ]);
  }

  void _reloadLessons() {
    setState(() {
      _loadData();
      _currentLesson = null;
      _targetHeadingSlug = null;
      _initialScrollOffset = null;
      _history.clear();
    });
  }

  void _navigateToLessonBySlug(String slug,
      {String? headingSlug, double? scrollOffset}) {
    _initFuture.then((data) {
      final lessons = data[0] as List<Lesson>;
      try {
        final lesson = lessons.firstWhere((l) => l.slug == slug);
        if (mounted) {
          setState(() {
            if (_currentLesson != null && scrollOffset != null) {
              _history.add(LessonHistoryEntry(
                lessonSlug: _currentLesson!.slug,
                scrollOffset: scrollOffset,
              ));
            }
            _currentLesson = lesson;
            _targetHeadingSlug = headingSlug;
            _initialScrollOffset = 0.0; // Reset scroll for new page
            _prefs?.setString('last_lesson_slug', slug);
          });
        }
      } catch (e) {
        if (mounted) {
          _navigateToLessonBySlug('title-page');
        }
      }
    });
  }

  void _handleBack() {
    if (_history.isNotEmpty) {
      final lastEntry = _history.removeLast();
      _initFuture.then((data) {
        final lessons = data[0] as List<Lesson>;
        try {
          final lesson = lessons.firstWhere((l) => l.slug == lastEntry.lessonSlug);
          if (mounted) {
            setState(() {
              _currentLesson = lesson;
              _targetHeadingSlug = null;
              _initialScrollOffset = lastEntry.scrollOffset;
              _prefs?.setString('last_lesson_slug', lesson.slug);
            });
          }
        } catch (e) {
          // Should not happen if history is valid
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _history.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: FutureBuilder<List<dynamic>>(
        future: _initFuture,
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
                          _loadData();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final lessons = snapshot.data![0] as List<Lesson>;
            _prefs = snapshot.data![1] as SharedPreferences;

            if (_currentLesson != null) {
              return LessonScreen(
                lesson: _currentLesson!,
                onNavigateToLesson: _navigateToLessonBySlug,
                lessons: lessons,
                targetHeadingSlug: _targetHeadingSlug,
                initialScrollOffset: _initialScrollOffset,
                onUpdateComplete: _reloadLessons,
              );
            }

            // If no lesson is selected, try to restore last lesson or show the first one
            if (lessons.isNotEmpty) {
              // Only set the current lesson if it hasn't been set yet
              if (_currentLesson == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      final lastSlug = _prefs?.getString('last_lesson_slug');
                      if (lastSlug != null) {
                        try {
                          _currentLesson = lessons.firstWhere((l) => l.slug == lastSlug);
                        } catch (e) {
                          _currentLesson = lessons.first;
                        }
                      } else {
                        _currentLesson = lessons.first;
                      }
                    });
                  }
                });
              }
              // While waiting for the post frame callback, show a loading or the first lesson temporarily
              // To avoid flicker, we can show the first lesson or a loader.
              // Showing the first lesson might be jarring if it switches to another one.
              // But since we are in the same frame, returning a widget is required.
              // If we return a loader here, it might flash.
              // If we return LessonScreen with lessons.first, it might flash.
              // However, since we are doing setState in addPostFrameCallback, the build will run again immediately.
              // Let's return a loader if _currentLesson is null to be safe and avoid "wrong content" flash.
              
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
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
      ),
    );
  }
}
