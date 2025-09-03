import 'package:flutter/material.dart';
import '../../models/lesson.dart';

class LessonItemWidget extends StatefulWidget {
  final Lesson lesson;
  final bool isCurrentLesson;
  final VoidCallback onTap;
  final bool isHomeItem;

  const LessonItemWidget({
    super.key,
    required this.lesson,
    required this.isCurrentLesson,
    required this.onTap,
    this.isHomeItem = false,
  });

  @override
  State<LessonItemWidget> createState() => _LessonItemWidgetState();
}

class _LessonItemWidgetState extends State<LessonItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            color: widget.isCurrentLesson
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : null,
          ),
          child: Text(
            widget.lesson.title,
            style: TextStyle(
              color: widget.isCurrentLesson
                  ? Theme.of(context).colorScheme.primary
                  : _isHovered
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: widget.isCurrentLesson || widget.isHomeItem
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
