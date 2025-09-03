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

  bool _isSectionHeading(String title) {
    final isSingleNumber = RegExp(r'^\d+\.\s').hasMatch(title);
    final isDoubleNumber = RegExp(r'^\d+\.\d+\.\s').hasMatch(title);
    return isSingleNumber && !isDoubleNumber;
  }

  bool _isSubSectionHeading(String title) {
    return RegExp(r'^\d+\.\d+\.\s').hasMatch(title);
  }

  @override
  Widget build(BuildContext context) {
    final isSection = _isSectionHeading(widget.lesson.title);
    final isSubSection = _isSubSectionHeading(widget.lesson.title);

    EdgeInsets padding;
    if (isSubSection) {
      padding = const EdgeInsets.fromLTRB(32.0, 14.0, 16.0, 14.0);
    } else if (isSection) {
      padding = const EdgeInsets.fromLTRB(16.0, 28.0, 16.0, 14.0);
    } else {
      padding = const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 14.0);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            color: widget.isCurrentLesson
                ? Theme.of(context).colorScheme.primary.withAlpha(25)
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
              fontWeight: widget.isCurrentLesson ||
                      widget.isHomeItem ||
                      isSection
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
