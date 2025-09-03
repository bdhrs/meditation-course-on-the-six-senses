import 'package:flutter/material.dart';
import '../../models/lesson.dart';
import '../../widgets/audio_player_widget.dart';
import '../../widgets/adaptive_navigation_buttons.dart';

class MainContent extends StatefulWidget {
  final Lesson lesson;
  final ScrollController scrollController;
  final bool isDesktop;
  final bool isTablet;
  final bool isMobile;
  final Function(String slug)? onNavigateToLesson;
  final String Function(String slug) getLessonTitle;

  const MainContent({
    super.key,
    required this.lesson,
    required this.scrollController,
    required this.isDesktop,
    required this.isTablet,
    required this.isMobile,
    this.onNavigateToLesson,
    required this.getLessonTitle,
  });

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  final GlobalKey _contentKey = GlobalKey();
  bool _isContentShort = false;

  @override
  void didUpdateWidget(MainContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lesson != oldWidget.lesson) {
      setState(() {
        _isContentShort = false;
      });
    }
  }

  Widget _buildTitlePage() {
    final navButtons = AdaptiveNavigationButtons(
      prevLessonSlug: widget.lesson.prevLessonSlug,
      nextLessonSlug: widget.lesson.nextLessonSlug,
      getLessonTitle: widget.getLessonTitle,
      onNavigateToLesson: widget.onNavigateToLesson,
      scrollController: widget.scrollController,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Meditation Course on the Six Senses',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                Text(
                  'A comprehensive guide to developing calm and insight through sense experience',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: navButtons,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lesson.markdownContent == '{{TITLE_PAGE}}') {
      return _buildTitlePage();
    }

    EdgeInsets padding;
    if (widget.isDesktop) {
      padding = const EdgeInsets.all(48.0);
    } else if (widget.isTablet) {
      padding = const EdgeInsets.all(24.0);
    } else {
      padding = const EdgeInsets.all(16.0);
    }

    final navButtons = AdaptiveNavigationButtons(
      prevLessonSlug: widget.lesson.prevLessonSlug,
      nextLessonSlug: widget.lesson.nextLessonSlug,
      getLessonTitle: widget.getLessonTitle,
      onNavigateToLesson: widget.onNavigateToLesson,
      scrollController: widget.scrollController,
    );

    return LayoutBuilder(builder: (context, constraints) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final contentContext = _contentKey.currentContext;
        if (contentContext == null) return;

        final contentHeight = contentContext.size?.height ?? 0;
        final viewPortHeight = constraints.maxHeight;

        final shouldBeShort = contentHeight < viewPortHeight;
        if (shouldBeShort != _isContentShort) {
          setState(() {
            _isContentShort = shouldBeShort;
          });
        }
      });

      return Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            controller: widget.scrollController,
            child: Padding(
              padding: padding,
              child: Column(
                children: [
                  Column(
                    key: _contentKey,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildMarkdownContent(widget.lesson.markdownContent),
                  ),
                  if (!_isContentShort) navButtons,
                ],
              ),
            ),
          ),
          if (_isContentShort)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: navButtons,
            ),
        ],
      );
    });
  }

  List<Widget> _buildMarkdownContent(String content) {
    final List<Widget> widgets = [];
    final lines = content.split('\n');

    String currentBlock = '';
    bool inParagraph = false;

    for (final line in lines) {
      if (line.startsWith('{{audio:')) {
        if (currentBlock.isNotEmpty) {
          widgets.add(_buildParagraph(currentBlock));
          currentBlock = '';
          inParagraph = false;
        }
        final fileName =
            line.length > 10 ? line.substring(8, line.length - 2) : '';
        widgets.add(_buildAudioWidget(fileName));
      } else if (line.startsWith('{{transcript:')) {
        if (currentBlock.isNotEmpty) {
          widgets.add(_buildParagraph(currentBlock));
          currentBlock = '';
          inParagraph = false;
        }
        final content =
            line.length > 15 ? line.substring(13, line.length - 2) : '';
        widgets.add(_buildTranscriptWidget(content));
      } else if (line.startsWith('{{link:')) {
        if (currentBlock.isNotEmpty) {
          widgets.add(_buildParagraph(currentBlock));
          currentBlock = '';
          inParagraph = false;
        }
        final linkContent =
            line.length > 9 ? line.substring(7, line.length - 2) : '';
        final parts = linkContent.split('|');
        final target = parts.isNotEmpty ? parts[0] : '';
        final displayText = parts.length > 1 ? parts[1] : target;
        widgets.add(_buildLinkWidget(target, displayText));
      } else if (line.startsWith('#')) {
        if (currentBlock.isNotEmpty) {
          widgets.add(_buildParagraph(currentBlock));
          currentBlock = '';
          inParagraph = false;
        }
        widgets.add(_buildHeading(line));
      } else if (line.isEmpty) {
        if (currentBlock.isNotEmpty) {
          widgets.add(_buildParagraph(currentBlock));
          currentBlock = '';
          inParagraph = false;
        }
      } else {
        if (inParagraph) {
          currentBlock = '$currentBlock $line';
        } else {
          currentBlock = line;
          inParagraph = true;
        }
      }
    }

    if (currentBlock.isNotEmpty) {
      widgets.add(_buildParagraph(currentBlock));
    }

    return widgets;
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16.0, height: 1.6),
      ),
    );
  }

  Widget _buildHeading(String line) {
    int level = 0;
    String text = line;

    while (level < line.length && line[level] == '#') {
      level++;
    }

    if (level < line.length) {
      text = line.substring(level).trim();
    }

    TextStyle style;
    switch (level) {
      case 1:
        style = const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold);
        break;
      case 2:
        style = const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold);
        break;
      case 3:
        style = const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);
        break;
      default:
        style = const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(text, style: style),
    );
  }

  Widget _buildAudioWidget(String fileName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AudioPlayerWidget(
        fileName: fileName,
      ),
    );
  }

  Widget _buildTranscriptWidget(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        child: ExpansionTile(
          title: const Text('Transcript'),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(content),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkWidget(String target, String displayText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: GestureDetector(
        onTap: () => widget.onNavigateToLesson?.call(target),
        child: Text(
          displayText,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}