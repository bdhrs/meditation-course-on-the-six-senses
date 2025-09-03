import 'package:flutter/material.dart';
import '../../models/lesson.dart';
import 'lesson_item_widget.dart';

class LeftSidebar extends StatelessWidget {
  final List<Lesson> lessons;
  final Lesson currentLesson;
  final Function(Lesson lesson) onLessonSelected;

  const LeftSidebar({
    super.key,
    required this.lessons,
    required this.currentLesson,
    required this.onLessonSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header - Course Outline
        Container(
          alignment: Alignment.centerLeft,
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

              // Use a regular LessonItemWidget for all items
              return LessonItemWidget(
                lesson: lessonItem,
                isCurrentLesson: isCurrentLesson,
                onTap: () => onLessonSelected(lessonItem),
              );
            },
          ),
        ),
      ],
    );
  }
}
