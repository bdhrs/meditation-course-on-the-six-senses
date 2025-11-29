import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final Function(String slug, {String? headingSlug})? onNavigateToLesson;
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
  MainContentState createState() => MainContentState();
}

class MainContentState extends State<MainContent> {
  final GlobalKey _contentKey = GlobalKey();
  bool _isContentShort = false;
  final Map<String, GlobalKey> _headingKeys = {};

  @override
  void initState() {
    super.initState();
    _generateHeadingKeys();
  }

  @override
  void didUpdateWidget(MainContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lesson != oldWidget.lesson) {
      _generateHeadingKeys();
      setState(() {
        _isContentShort = false;
      });
    }
  }

  void _generateHeadingKeys() {
    _headingKeys.clear();
    for (var heading in widget.lesson.headings) {
      _headingKeys[heading['slug']!] = GlobalKey();
    }
  }

  void scrollToHeading(String headingSlug) {
    final key = _headingKeys[headingSlug];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildTitlePage() {
    final navButtons = AdaptiveNavigationButtons(
      prevLessonSlug: widget.lesson.prevLessonSlug,
      nextLessonSlug: widget.lesson.nextLessonSlug,
      getLessonTitle: widget.getLessonTitle,
      onNavigateToLesson: (slug) => widget.onNavigateToLesson?.call(slug),
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
      onNavigateToLesson: (slug) => widget.onNavigateToLesson?.call(slug),
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

    // Extract transcript widgets before line splitting
    final transcriptWidgets = <Widget>[];
    final transcriptPattern = RegExp(r'{{transcript:(.*?)}}', dotAll: true);
    var processedContent = content;

    // Find and extract all transcript content
    final transcriptMatches = transcriptPattern.allMatches(content);
    int transcriptIndex = 0;

    for (final match in transcriptMatches) {
      final transcriptContent = match.group(1) ?? '';
      transcriptWidgets.add(_buildTranscriptWidget(transcriptContent));

      // Replace transcript pattern with a simple placeholder
      processedContent = processedContent.replaceFirst(
        match.group(0)!,
        '{{_transcript_widget_$transcriptIndex}}',
      );
      transcriptIndex++;
    }

    final lines = processedContent.split('\n');

    String currentParagraph = '';
    String currentBlockquote = '';

    void flushParagraph() {
      if (currentParagraph.isNotEmpty) {
        // Parse inline links within the paragraph
        widgets.addAll(_parseInlineContent(currentParagraph.trim()));
        currentParagraph = '';
      }
    }

    void flushBlockquote() {
      if (currentBlockquote.isNotEmpty) {
        widgets.add(_buildBlockquote(currentBlockquote.trim()));
        currentBlockquote = '';
      }
    }

    int currentTranscriptIndex = 0;

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
      } else if (line.startsWith('{{image:')) { // Handle image placeholder
        flushParagraph();
        flushBlockquote();
        final fileName = line.substring(8, line.length - 2);
        widgets.add(_buildImageWidget(fileName));
      }
      else if (line.startsWith('{{_transcript_widget_')) {
        flushParagraph();
        flushBlockquote();
        // Insert the next transcript widget from our stored list
        if (currentTranscriptIndex < transcriptWidgets.length) {
          widgets.add(transcriptWidgets[currentTranscriptIndex]);
          currentTranscriptIndex++;
        }
      } else if (line.startsWith('{{link:')) {
        flushParagraph();
        flushBlockquote();
        final linkContent =
            line.length > 9 ? line.substring(7, line.length - 2) : '';
        final linkParts = linkContent.split('|');
        final target = linkParts.isNotEmpty ? linkParts[0] : '';
        final displayText = linkParts.length > 1 ? linkParts[1] : target;
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

  List<Widget> _parseInlineContent(String text) {
    final List<Widget> widgets = [];
    final linkPattern = RegExp(r'{{link:([^}|]+(?:\|[^}]+)?)}}');

    // If no links found, just add the text as a paragraph
    if (!linkPattern.hasMatch(text)) {
      widgets.add(_buildParagraph(text));
      return widgets;
    }

    // Find all matches and their positions
    final matches = linkPattern.allMatches(text);

    // If links are found, we need to handle inline content differently
    // We'll create a single row with text and links mixed together
    final List<InlineSpan> inlineChildren = [];
    int lastEnd = 0;

    for (final match in matches) {
      // Add text before the link
      if (match.start > lastEnd) {
        final beforeText = text.substring(lastEnd, match.start);
        inlineChildren.add(TextSpan(text: beforeText));
      }

      // Add the link widget
      final linkContent = match.group(1) ?? '';
      final linkParts = linkContent.split('|');
      final target = linkParts.isNotEmpty ? linkParts[0] : '';
      final displayText = linkParts.length > 1 ? linkParts[1] : target;

      // For inline links, we need to create a WidgetSpan
      inlineChildren.add(WidgetSpan(
        child: _buildLinkWidget(target, displayText),
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
      ));

      lastEnd = match.end;
    }

    // Add any remaining text after the last link
    if (lastEnd < text.length) {
      final afterText = text.substring(lastEnd);
      inlineChildren.add(TextSpan(text: afterText));
    }

    // Create a single paragraph with mixed text and links
    widgets.add(Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16.0, height: 1.6),
          children: inlineChildren,
        ),
      ),
    ));

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
        onTapLink: (text, href, title) {
          if (href != null) {
            launchUrl(Uri.parse(href));
          }
        },
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
              onTapLink: (text, href, title) {
                if (href != null) {
                  launchUrl(Uri.parse(href));
                }
              },
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

  String _generateSlug(String text) {
    String slug = text.toLowerCase();
    slug = slug.replaceAll(RegExp(r'[\s_]+'), '-');
    slug = slug.replaceAll(RegExp(r'[^a-z0-9-]'), '');
    return slug;
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

    final slug = _generateSlug(text);
    final key = _headingKeys[slug];

    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: MarkdownBody(
        data: text,
        styleSheet: MarkdownStyleSheet(
          p: switch (level) {
            1 => const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            2 => TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            3 => const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            _ => const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          },
        ),
      ),
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

  // New function to build image widgets
  Widget _buildImageWidget(String fileName) {
    // Determine if it's an SVG or other image type
    if (fileName.toLowerCase().endsWith('.svg')) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      final svgPicture = SvgPicture.asset(
        'assets/images/$fileName',
        height: 400, // You might want to make this configurable
      );

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: isDarkMode
            ? ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  -1, 0, 0, 0, 255,
                  0, -1, 0, 0, 255,
                  0, 0, -1, 0, 255,
                  0, 0, 0, 1, 0,
                ]),
                child: svgPicture,
              )
            : svgPicture,
      );
    } else {
      // For other image types like PNG, JPG
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Image.asset(
          'assets/images/$fileName',
          height: 400, // You might want to make this configurable
        ),
      );
    }
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
              child: MarkdownBody(
                data: content,
                onTapLink: (text, href, title) {
                  if (href != null) {
                    launchUrl(Uri.parse(href));
                  }
                },
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 16.0, height: 2.0),
                  h1: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.bold, height: 2.0),
                  h2: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    height: 1.8,
                  ),
                  h3: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold, height: 2.0),
                  h4: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold, height: 2.0),
                  blockquote: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                    height: 2.0,
                  ),
                  code: TextStyle(
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    fontFamily: 'Monospace',
                    fontSize: 14.0,
                    height: 2.0,
                  ),
                  blockSpacing: 16.0,
                ),
              ),
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
        onTap: () async {
          final uri = Uri.parse(target);
          if (uri.scheme == 'sixsenses') {
            final pageSlug = uri.host;
            final headingSlug = uri.hasFragment ? uri.fragment : null;

            if (pageSlug == widget.lesson.slug) {
              // It's a link to a heading on the current page
              if (headingSlug != null) {
                scrollToHeading(headingSlug);
              }
            } else {
              // It's a link to another page
              widget.onNavigateToLesson
                  ?.call(pageSlug, headingSlug: headingSlug);
            }
          } else {
            // It's an external link, so launch it
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          }
        },
        child: Text(
          displayText,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
