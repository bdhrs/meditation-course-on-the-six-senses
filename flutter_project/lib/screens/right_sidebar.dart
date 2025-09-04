import 'package:flutter/material.dart';
import '../../models/lesson.dart';

class RightSidebar extends StatelessWidget {
  final Lesson lesson;
  final Function(String headingSlug)? onHeadingTap;

  const RightSidebar({
    super.key,
    required this.lesson,
    this.onHeadingTap,
  });

  @override
  Widget build(BuildContext context) {
    // Extract headings from the lesson content
    final List<Map<String, String>> headings =
        _extractHeadings(lesson.markdownContent);

    return Column(
      children: [
        // Header - On This Page
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
            'On This Page',
            style: TextStyle(
              color: Theme.of(context).appBarTheme.foregroundColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Table of Contents List
        Expanded(
          child: headings.isEmpty
              ? const Center(
                  child: Text('No headings found'),
                )
              : ListView.builder(
                  itemCount: headings.length,
                  itemBuilder: (context, index) {
                    final heading = headings[index];
                    final String level = heading['level'] ?? 'h2';
                    final String text = heading['text'] ?? '';
                    // final String id = heading['id'] ?? ''; // Not currently used

                    return Container(
                      padding: EdgeInsets.only(
                        left: level == 'h3'
                            ? 24.0
                            : level == 'h1'
                                ? 8.0
                                : 16.0,
                        top: 8.0,
                        bottom: 8.0,
                      ),
                      child: TextButton(
                        onPressed: onHeadingTap != null
                            ? () {
                                // Find the heading slug from the lesson's headings
                                final headingMap = lesson.headings.firstWhere(
                                  (h) => h['text'] == text,
                                  orElse: () => {'slug': ''},
                                );
                                final slug = headingMap['slug'] ?? '';
                                if (slug.isNotEmpty) {
                                  onHeadingTap!(slug);
                                }
                              }
                            : null,
                        style: TextButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.zero,
                          textStyle: TextStyle(
                            fontSize: level == 'h3'
                                ? 14.0
                                : level == 'h2'
                                    ? 16.0
                                    : 18.0, // h1: 18px, h2: 16px, h3: 14px
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: level == 'h3'
                                ? 14.0
                                : level == 'h2'
                                    ? 16.0
                                    : 18.0, // h1: 18px, h2: 16px, h3: 14px
                            fontWeight: FontWeight.normal,
                            color: level == 'h2'
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color, // h2: green, h1 & h3: white
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<Map<String, String>> _extractHeadings(String content) {
    final List<Map<String, String>> headings = [];
    final lines = content.split('\n');

    for (final line in lines) {
      if (line.startsWith('#')) {
        int level = 0;
        String text = line;

        // Count # characters to determine heading level
        while (level < line.length && line[level] == '#') {
          level++;
        }

        // Remove # characters and spaces
        if (level < line.length) {
          text = line.substring(level).trim();
        }

        // Only include h2 and h3 headings (excluding h1/page title)
        if (level == 2 || level == 3) {
          // Create an ID for the heading (similar to website)
          final String id = text
              .toLowerCase()
              .replaceAll(RegExp(r'\s+'), '-')
              .replaceAll(RegExp(r'[^a-z0-9-]'), '');

          headings.add({
            'level': level == 2 ? 'h2' : 'h3',
            'text': text,
            'id': id,
          });
        }
      }
    }

    return headings;
  }
}
