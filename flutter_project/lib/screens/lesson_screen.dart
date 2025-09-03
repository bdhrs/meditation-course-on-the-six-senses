import 'package:flutter/material.dart';
import '../models/lesson.dart';
import 'app_bar.dart';
import 'left_sidebar.dart';
import 'right_sidebar.dart';
import 'main_content.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  final Function(String slug)? onNavigateToLesson;
  final List<Lesson> lessons;
  final Function()? onNavigateToLanding;

  const LessonScreen({
    super.key,
    required this.lesson,
    this.onNavigateToLesson,
    required this.lessons,
    this.onNavigateToLanding,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLeftSidebarVisible = true;
  bool _isRightSidebarVisible = true;
  bool _isHeaderVisible = true;
  double _lastScrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final double currentScrollPosition = _scrollController.offset;
    final double delta = 5.0; // Minimum scroll change to trigger action

    // Make sure we scroll more than delta
    if ((currentScrollPosition - _lastScrollPosition).abs() <= delta) {
      return;
    }

    final bool scrollingDown = currentScrollPosition > _lastScrollPosition;
    final double maxScrollExtent = _scrollController.position.maxScrollExtent;
    final bool isAtBottom = currentScrollPosition >= maxScrollExtent - 20;

    setState(() {
      // If scrolling down, hide the header
      if (scrollingDown && currentScrollPosition > kToolbarHeight) {
        _isHeaderVisible = false;
      } else {
        // If scrolling up, show the header
        _isHeaderVisible = true;
      }

      // Always show header if at the bottom of the page
      if (isAtBottom) {
        _isHeaderVisible = true;
      }

      _lastScrollPosition = currentScrollPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 1200;
        final bool isTablet =
            constraints.maxWidth > 768 && constraints.maxWidth <= 1200;
        final bool isMobile = constraints.maxWidth <= 768;

        // Update sidebar visibility based on screen size
        // Both sidebars visible only on desktop (>1200px)
        // Both sidebars hidden on tablet and mobile (≤1200px)
        if (isDesktop) {
          // On desktop, both sidebars are visible by default
          // But respect user's manual toggle if they've interacted with them
          if (!_isLeftSidebarVisible) _isLeftSidebarVisible = true;
          if (!_isRightSidebarVisible) _isRightSidebarVisible = true;
        } else {
          // On tablet and mobile, both sidebars are hidden by default
          _isLeftSidebarVisible = false;
          _isRightSidebarVisible = false;
        }

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(
                  0, _isHeaderVisible ? 0 : -kToolbarHeight, 0),
              transformAlignment: Alignment.topCenter,
              child: ThreePaneAppBar(
                isMobile: isMobile,
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
          ),
          body: _buildBody(context, isDesktop, isTablet, isMobile),
          bottomNavigationBar: isMobile ? _buildFooterNavigation() : null,
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context, bool isDesktop, bool isTablet, bool isMobile) {
    return Row(
      children: [
        // Left Sidebar - Course Outline
        if (_isLeftSidebarVisible)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 250,
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
                // Close sidebar on mobile after selection
                if (MediaQuery.of(context).size.width <= 768) {
                  setState(() {
                    _isLeftSidebarVisible = false;
                  });
                }
                widget.onNavigateToLesson?.call(lesson.slug);
              },
              onHomeSelected: () {
                // Close sidebar on mobile after selection
                if (MediaQuery.of(context).size.width <= 768) {
                  setState(() {
                    _isLeftSidebarVisible = false;
                  });
                }
                widget.onNavigateToLanding?.call();
              },
            ),
          ),

        // Main Content Area
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 960),
            child: MainContent(
              lesson: widget.lesson,
              scrollController: _scrollController,
              isDesktop: isDesktop,
              isTablet: isTablet,
              isMobile: isMobile,
              onNavigateToLesson: widget.onNavigateToLesson,
            ),
          ),
        ),

        // Right Sidebar - On-Page Table of Contents
        if (_isRightSidebarVisible && !isMobile)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 250,
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
            ),
          ),
      ],
    );
  }

  Widget _buildFooterNavigation() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          if (widget.lesson.prevLessonSlug != null)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: TextButton(
                  onPressed: () {
                    if (widget.lesson.prevLessonSlug == 'landing') {
                      widget.onNavigateToLanding?.call();
                    } else {
                      widget.onNavigateToLesson
                          ?.call(widget.lesson.prevLessonSlug!);
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('←', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getLessonTitle(widget.lesson.prevLessonSlug!),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: TextButton(
                  onPressed: null,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('←', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (widget.lesson.nextLessonSlug != null)
            Expanded(
              child: TextButton(
                onPressed: () => widget.onNavigateToLesson
                    ?.call(widget.lesson.nextLessonSlug!),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        _getLessonTitle(widget.lesson.nextLessonSlug!),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('→', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: TextButton(
                onPressed: null,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        '',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('→', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
        ],
      ),
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
