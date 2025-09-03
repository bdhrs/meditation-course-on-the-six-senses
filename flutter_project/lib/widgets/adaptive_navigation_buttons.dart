import 'package:flutter/material.dart';

class AdaptiveNavigationButtons extends StatelessWidget {
  final String? prevLessonSlug;
  final String? nextLessonSlug;
  final String Function(String slug) getLessonTitle;
  final Function(String slug)? onNavigateToLesson;
  final ScrollController? scrollController;

  const AdaptiveNavigationButtons({
    super.key,
    required this.prevLessonSlug,
    required this.nextLessonSlug,
    required this.getLessonTitle,
    this.onNavigateToLesson,
    this.scrollController,
  });

  void _navigateToLesson(String slug) {
    if (scrollController?.hasClients ?? false) {
      scrollController?.jumpTo(0.0);
    }
    onNavigateToLesson?.call(slug);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          if (prevLessonSlug != null)
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
                  onPressed: () => _navigateToLesson(prevLessonSlug!),
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
                          getLessonTitle(prevLessonSlug!),
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
          if (nextLessonSlug != null)
            Expanded(
              child: TextButton(
                onPressed: () => _navigateToLesson(nextLessonSlug!),
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
                        getLessonTitle(nextLessonSlug!),
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
}