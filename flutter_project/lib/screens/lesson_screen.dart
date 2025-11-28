import 'package:flutter/material.dart';
import '../models/lesson.dart';
import 'app_bar.dart';
import 'left_sidebar.dart';
import 'right_sidebar.dart';
import 'main_content.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  final Function(String slug, {String? headingSlug})? onNavigateToLesson;
  final List<Lesson> lessons;
  final String? targetHeadingSlug;

  const LessonScreen({
    super.key,
    required this.lesson,
    this.onNavigateToLesson,
    required this.lessons,
    this.targetHeadingSlug,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<MainContentState> _mainContentKey =
      GlobalKey<MainContentState>();
  bool _isLeftSidebarVisible = false;
  bool _isRightSidebarVisible = false;
  double _previousWidth = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _scrollToHeadingIfNeeded(widget.targetHeadingSlug);
  }

  @override
  void didUpdateWidget(LessonScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lesson.slug != oldWidget.lesson.slug) {
      // If the lesson has changed, scroll to the top.
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      // After the new lesson is built, scroll to the heading if one is provided.
      _scrollToHeadingIfNeeded(widget.targetHeadingSlug);
    } else if (widget.targetHeadingSlug != oldWidget.targetHeadingSlug) {
      // If only the heading has changed within the same lesson, scroll to it.
      _scrollToHeadingIfNeeded(widget.targetHeadingSlug);
    }
  }

  void _scrollToHeadingIfNeeded(String? headingSlug) {
    if (headingSlug != null) {
      // We need to wait for the MainContent widget to be built or updated.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mainContentKey.currentState?.scrollToHeading(headingSlug);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    // Scroll handling for other features (like sidebar behavior) can go here
    // Currently keeping scroll handling minimal to avoid jarring behavior
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 1200;
        final bool wasDesktop = _previousWidth > 1200;

        if (isDesktop != wasDesktop) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                if (isDesktop) {
                  _isLeftSidebarVisible = true;
                  _isRightSidebarVisible = true;
                } else {
                  _isLeftSidebarVisible = false;
                  _isRightSidebarVisible = false;
                }
              });
            }
          });
        }
        _previousWidth = constraints.maxWidth;

        final bool isTablet =
            constraints.maxWidth > 768 && constraints.maxWidth <= 1200;
        final bool isMobile = constraints.maxWidth <= 768;

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: ThreePaneAppBar(
              isMobile: isMobile,
              isTablet: isTablet,
              onMenuPressed: () {
                setState(() {
                  _isLeftSidebarVisible = !_isLeftSidebarVisible;
                });
              },
              onSettingsPressed: () {
                Navigator.of(context).pushNamed('/settings');
              },
            ),
          ),
          body: SafeArea(
            top: true,
            bottom: true,
            child: _buildBody(context, isDesktop, isTablet, isMobile),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    // For desktop, show all three panes
    // For tablet and mobile, hide both sidebars initially
    final bool showLeftSidebar = isDesktop && _isLeftSidebarVisible;
    final bool showRightSidebar = isDesktop && _isRightSidebarVisible;

    return Stack(
      children: [
        // Main row with all three panes
        Row(
          children: [
            // Left Sidebar - Course Outline (only on desktop when visible)
            if (showLeftSidebar)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                transform: Matrix4.translationValues(
                  0,
                  0,
                  0,
                ), // Always show sidebar, no animation needed
                transformAlignment: Alignment.centerLeft,
                width: 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: LeftSidebar(
                  lessons: widget.lessons,
                  currentLesson: widget.lesson,
                  onLessonSelected: (lesson) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(0.0);
                    }
                    widget.onNavigateToLesson?.call(lesson.slug);
                  },
                ),
              ),

            // Main Content Area
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 960),
                child: MainContent(
                  key: _mainContentKey,
                  lesson: widget.lesson,
                  scrollController: _scrollController,
                  isDesktop: isDesktop,
                  isTablet: isTablet,
                  isMobile: isMobile,
                  onNavigateToLesson: (slug, {headingSlug}) {
                    // Scroll to top when navigating to a new lesson
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(0.0);
                    }
                    widget.onNavigateToLesson?.call(
                      slug,
                      headingSlug: headingSlug,
                    );
                  },
                  getLessonTitle: _getLessonTitle,
                ),
              ),
            ),

            // Right Sidebar - On-Page Table of Contents (only on desktop when visible)
            if (showRightSidebar)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                transform: Matrix4.translationValues(
                  0,
                  0,
                  0,
                ), // Always show sidebar, no animation needed
                transformAlignment: Alignment.centerRight,
                width: 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    left: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: RightSidebar(
                  lesson: widget.lesson,
                  onHeadingTap: (headingSlug) {
                    _mainContentKey.currentState?.scrollToHeading(headingSlug);
                  },
                ),
              ),
          ],
        ),

        // Overlay sidebars for tablet and mobile
        if (!isDesktop && _isLeftSidebarVisible)
          Positioned(
            left: 0,
            top: kToolbarHeight, // Always start below the app bar
            bottom: 0,
            width: 300,
            child: Material(
              elevation: 16.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: LeftSidebar(
                  lessons: widget.lessons,
                  currentLesson: widget.lesson,
                  onLessonSelected: (lesson) {
                    // Close sidebar after selection
                    setState(() {
                      _isLeftSidebarVisible = false;
                    });
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(0.0);
                    }
                    widget.onNavigateToLesson?.call(lesson.slug);
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getLessonTitle(String slug) {
    if (slug == 'landing') {
      return 'Home';
    }

    try {
      final lesson = widget.lessons.firstWhere((l) => l.slug == slug);
      return lesson.title;
    } catch (e) {
      return slug;
    }
  }
}
