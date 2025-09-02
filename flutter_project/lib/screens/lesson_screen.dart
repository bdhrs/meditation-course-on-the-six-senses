import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../widgets/audio_player_widget.dart';

class LessonScreen extends StatelessWidget {
  final Lesson lesson;
  final Function(String slug)? onNavigateToLesson;

  const LessonScreen({
    super.key,
    required this.lesson,
    this.onNavigateToLesson,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildMarkdownContent(lesson.markdownContent),
              ),
            ),
          ),
          if (lesson.prevLessonSlug != null || lesson.nextLessonSlug != null)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (lesson.prevLessonSlug != null)
                    ElevatedButton(
                      onPressed: () => onNavigateToLesson?.call(lesson.prevLessonSlug!),
                      child: const Text('Previous'),
                    )
                  else
                    const SizedBox.shrink(),
                  if (lesson.nextLessonSlug != null)
                    ElevatedButton(
                      onPressed: () => onNavigateToLesson?.call(lesson.nextLessonSlug!),
                      child: const Text('Next'),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMarkdownContent(String content) {
    final List<Widget> widgets = [];
    final lines = content.split('\n');
    
    String currentBlock = '';
    bool inParagraph = false;
    
    for (final line in lines) {
      // Check for our custom syntax
      if (line.startsWith('{{audio:')) {
        // Add any pending paragraph
        if (currentBlock.isNotEmpty) {
          widgets.add(_buildParagraph(currentBlock));
          currentBlock = '';
          inParagraph = false;
        }
        
        // Add audio widget
        final fileName = line.substring(8, line.length - 2);
        widgets.add(_buildAudioWidget(fileName));
      } else if (line.startsWith('{{transcript:')) {
        // Add any pending paragraph
        if (currentBlock.isNotEmpty) {
          widgets.add(_buildParagraph(currentBlock));
          currentBlock = '';
          inParagraph = false;
        }
        
        // Add transcript widget
        final content = line.substring(13, line.length - 2);
        widgets.add(_buildTranscriptWidget(content));
      } else if (line.startsWith('{{link:')) {
        // Add any pending paragraph
        if (currentBlock.isNotEmpty) {
          widgets.add(_buildParagraph(currentBlock));
          currentBlock = '';
          inParagraph = false;
        }
        
        // Add link widget
        final linkContent = line.substring(7, line.length - 2);
        final parts = linkContent.split('|');
        final target = parts[0];
        final displayText = parts.length > 1 ? parts[1] : target;
        widgets.add(_buildLinkWidget(target, displayText));
      } else if (line.startsWith('#')) {
        // Add any pending paragraph
        if (currentBlock.isNotEmpty) {
          widgets.add(_buildParagraph(currentBlock));
          currentBlock = '';
          inParagraph = false;
        }
        
        // Add heading
        widgets.add(_buildHeading(line));
      } else if (line.isEmpty) {
        // Empty line indicates end of paragraph
        if (currentBlock.isNotEmpty) {
          widgets.add(_buildParagraph(currentBlock));
          currentBlock = '';
          inParagraph = false;
        }
      } else {
        // Regular text, add to current block
        if (inParagraph) {
          currentBlock = '$currentBlock $line';
        } else {
          currentBlock = line;
          inParagraph = true;
        }
      }
    }
    
    // Add any remaining paragraph
    if (currentBlock.isNotEmpty) {
      widgets.add(_buildParagraph(currentBlock));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
  
  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16.0),
      ),
    );
  }
  
  Widget _buildHeading(String line) {
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
        onTap: () => onNavigateToLesson?.call(target),
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