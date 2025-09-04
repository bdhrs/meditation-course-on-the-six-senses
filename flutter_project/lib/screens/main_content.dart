import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/lesson.dart';
import '../../theme/app_theme.dart';
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
            child: SelectionArea(
              child: Padding(
                padding: padding,
                child: Column(
                  children: [
                    Column(
                      key: _contentKey,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildMarkdownContent(widget.lesson.markdownContent),
                    ),
                    if (!_isContentShort) navButtons,
                  ],
                ),
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

    String currentParagraph = '';
    String currentBlockquote = '';

    void flushParagraph() {
      if (currentParagraph.isNotEmpty) {
        widgets.add(_buildParagraph(currentParagraph.trim()));
        currentParagraph = '';
      }
    }

    void flushBlockquote() {
      if (currentBlockquote.isNotEmpty) {
        widgets.add(_buildBlockquote(currentBlockquote.trim()));
        currentBlockquote = '';
      }
    }

    for (final line in lines) {
      if (line.startsWith('>')) {
        flushParagraph();
        currentBlockquote += '$line\n';
      } else if (line.startsWith('{{audio:')) {
        flushParagraph();
        flushBlockquote();
        final fileName =
            line.length > 10 ? line.substring(8, line.length - 2) : '';
        widgets.add(_buildAudioWidget(fileName));
      } else if (line.startsWith('{{transcript:')) {
        flushParagraph();
        flushBlockquote();
        final content =
            line.length > 15 ? line.substring(13, line.length - 2) : '';
        widgets.add(_buildTranscriptWidget(content));
      } else if (line.startsWith('{{link:')) {
        flushParagraph();
        flushBlockquote();
        final linkContent =
            line.length > 9 ? line.substring(7, line.length - 2) : '';
        final parts = linkContent.split('|');
        final target = parts.isNotEmpty ? parts[0] : '';
        final displayText = parts.length > 1 ? parts[1] : target;
        widgets.add(_buildLinkWidget(target, displayText));
      } else if (line.startsWith('#')) {
        flushParagraph();
        flushBlockquote();
        widgets.add(_buildHeading(line));
      } else if (line.trim().isEmpty) {
        flushParagraph();
        flushBlockquote();
        widgets.add(const SizedBox(height: 16.0));
      } else {
        flushBlockquote();
        currentParagraph += '$line\n';
      }
    }

    flushParagraph();
    flushBlockquote();

    return widgets;
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: MarkdownBody(
        data: text,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(fontSize: 16.0, height: 1.6),
        ),
      ),
    );
  }

  Widget _buildBlockquote(String text) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final blockBgColor =
        isDarkMode ? AppTheme.darkBlockBg : AppTheme.lightBlockBg;
    final primaryColor =
        isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.lightPrimaryColor;

    final List<Widget> blockquoteContent = [];
    final lines = text.split('\n');
    String currentParagraph = '';

    void flushParagraph() {
      if (currentParagraph.isNotEmpty) {
        blockquoteContent.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: MarkdownBody(
              data: currentParagraph.trim(),
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                    fontSize: 16.0, height: 1.6, fontStyle: FontStyle.italic),
              ),
            ),
          ),
        );
        currentParagraph = '';
      }
    }

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      if (line.startsWith('> --')) {
        flushParagraph();
        // Remove the '> --' prefix and any surrounding asterisks for italics
        String suttaText = line.substring(4).trim();
        // Remove leading and trailing asterisks if present
        if (suttaText.startsWith('*') &&
            suttaText.endsWith('*') &&
            suttaText.length > 1) {
          suttaText = suttaText.substring(1, suttaText.length - 1);
        }
        blockquoteContent.add(
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    suttaText,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 16.0,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.startsWith('>')) {
        currentParagraph += '${line.substring(1).trim()}\n';
      }
    }
    flushParagraph();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24.0),
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
      decoration: BoxDecoration(
        color: blockBgColor,
        border: Border(
          left: BorderSide(
            color: primaryColor,
            width: 5.0,
          ),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: blockquoteContent,
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
