import 'package:flutter/material.dart';
import '../../models/lesson.dart';
import 'lesson_item_widget.dart';

class LeftSidebar extends StatelessWidget {
  final List<Lesson> lessons;
  final Lesson currentLesson;
  final Function(Lesson lesson) onLessonSelected;
  final VoidCallback onHomeSelected;

  const LeftSidebar({
    super.key,
    required this.lessons,
    required this.currentLesson,
    required this.onLessonSelected,
    required this.onHomeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header - Course Outline
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).appBarTheme.backgroundColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).appBarTheme.shadowColor ??
                    Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'Course Outline',
            style: TextStyle(
              color: Theme.of(context).appBarTheme.foregroundColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Lessons List
        Expanded(
          child: ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lessonItem = lessons[index];
              final bool isCurrentLesson =
                  lessonItem.slug == currentLesson.slug;

              return LessonItemWidget(
                lesson: lessonItem,
                isCurrentLesson: isCurrentLesson,
                onTap: () => onLessonSelected(lessonItem),
              );
            },
          ),
        ),
        // Home Item
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: LessonItemWidget(
            lesson: Lesson(
              title: 'Home',
              slug: 'landing',
              markdownContent: '',
              audioFileNames: [],
              prevLessonSlug: null,
              nextLessonSlug: null,
            ),
            isCurrentLesson: false,
            onTap: onHomeSelected,
            isHomeItem: true,
          ),
        ),
      ],
    );
  }
}
