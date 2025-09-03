import 'package:flutter/material.dart';

class NavigationButtons extends StatefulWidget {
  final String? prevLessonSlug;
  final String? nextLessonSlug;
  final String Function(String slug) getLessonTitle;
  final Function(String slug)? onNavigateToLesson;
  final VoidCallback? onNavigateToLanding;
  final ScrollController? scrollController;

  const NavigationButtons({
    super.key,
    required this.prevLessonSlug,
    required this.nextLessonSlug,
    required this.getLessonTitle,
    this.onNavigateToLesson,
    this.onNavigateToLanding,
    this.scrollController,
  });

  @override
  State<NavigationButtons> createState() => _NavigationButtonsState();
}

class _NavigationButtonsState extends State<NavigationButtons> {
  final GlobalKey _buttonsKey = GlobalKey();
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPosition();
    });
  }

  void _checkPosition() {
    if (widget.scrollController != null) {
      widget.scrollController!.addListener(_scrollListener);
      _scrollListener();
    }
  }

  void _scrollListener() {
    if (widget.scrollController != null && _buttonsKey.currentContext != null) {
      final scrollPosition = widget.scrollController!.position;
      final isAtBottom =
          scrollPosition.pixels >= scrollPosition.maxScrollExtent - 50;

      if (isAtBottom != _isAtBottom) {
        setState(() {
          _isAtBottom = isAtBottom;
        });
      }
    }
  }

  @override
  void dispose() {
    if (widget.scrollController != null) {
      widget.scrollController!.removeListener(_scrollListener);
    }
    super.dispose();
  }

  void _navigateToLesson(String slug) {
    // Scroll to top when navigating to a new lesson
    widget.scrollController?.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    widget.onNavigateToLesson?.call(slug);
  }

  void _navigateToLanding() {
    // Scroll to top when navigating to landing page
    widget.scrollController?.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    widget.onNavigateToLanding?.call();
  }

  @override
  Widget build(BuildContext context) {
    final buttonRow = Container(
      key: _buttonsKey,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          if (widget.prevLessonSlug != null)
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
                    if (widget.prevLessonSlug == 'landing') {
                      _navigateToLanding();
                    } else {
                      _navigateToLesson(widget.prevLessonSlug!);
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
                          widget.prevLessonSlug == 'landing'
                              ? 'Home'
                              : widget.getLessonTitle(widget.prevLessonSlug!),
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
          if (widget.nextLessonSlug != null)
            Expanded(
              child: TextButton(
                onPressed: () => _navigateToLesson(widget.nextLessonSlug!),
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
                        widget.getLessonTitle(widget.nextLessonSlug!),
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

    // For short content, we want the buttons at the bottom of the screen
    // For long content, we want the buttons at the bottom of the content
    // This is handled by the parent widget (MainContent) which positions the buttons appropriately
    return buttonRow;
  }
}
