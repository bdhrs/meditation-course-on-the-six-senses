import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;
import '../models/lesson.dart';

class ContentService {
  static const String _documentsPath = 'assets/markdown';

  /// Reads all markdown files and creates Lesson objects
  Future<List<Lesson>> loadLessons() async {
    final lessons = <Lesson>[];

    // Get the list of markdown files
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap =
        Map<String, dynamic>.from(json.decode(manifestContent));

    final markdownFiles = manifestMap.keys
        .where((key) => key.startsWith(_documentsPath) && key.endsWith('.md'))
        .where((key) => !path.basename(key).startsWith('X')) // Skip draft files
        .toList();

    // Process each markdown file
    for (final filePath in markdownFiles) {
      final fileName = path.basename(filePath);
      final fileContent = await rootBundle.loadString(filePath);

      // Parse the file name to generate title and slug
      final title = _getTitleFromFileName(fileName);
      final slug =
          _generateSlug(fileName); // Use fileName for slug to preserve ordering

      // Process the markdown content
      final processedContent = _processMarkdownContent(fileContent);

      // Extract audio file names
      final audioFileNames = _extractAudioFileNames(fileContent);

      lessons.add(Lesson(
        title: title,
        slug: slug,
        markdownContent: processedContent,
        audioFileNames: audioFileNames,
      ));
    }

    // Sort lessons by slug to maintain proper order
    lessons.sort((a, b) => a.slug.compareTo(b.slug));

    // Populate nextLessonSlug and prevLessonSlug
    for (int i = 0; i < lessons.length; i++) {
      String? nextSlug;
      String? prevSlug;

      if (i > 0) {
        prevSlug = lessons[i - 1].slug;
      } else {
        // First lesson should have a link back to the landing page
        prevSlug = 'landing';
      }

      if (i < lessons.length - 1) {
        nextSlug = lessons[i + 1].slug;
      }

      lessons[i] = Lesson(
        title: lessons[i].title,
        slug: lessons[i].slug,
        markdownContent: lessons[i].markdownContent,
        audioFileNames: lessons[i].audioFileNames,
        nextLessonSlug: nextSlug,
        prevLessonSlug: prevSlug,
      );
    }

    return lessons;
  }

  /// Extracts the title from the file name
  String _getTitleFromFileName(String fileName) {
    // Remove the .md extension
    String title = fileName.replaceAll('.md', '');

    // Split on dots and take everything after the first part (which is usually a number)
    final parts = title.split('.');
    if (parts.length > 1) {
      title = parts.sublist(1).join('. '); // Join with spaces
    }

    // Replace hyphens and underscores with spaces
    title = title.replaceAll('-', ' ').replaceAll('_', ' ');

    // Capitalize first letter of each word
    if (title.isNotEmpty) {
      final words = title.split(' ');
      for (int i = 0; i < words.length; i++) {
        if (words[i].isNotEmpty) {
          words[i] = words[i][0].toUpperCase() + words[i].substring(1);
        }
      }
      title = words.join(' ');
    }

    return title;
  }

  /// Generates a URL-friendly slug from the file name
  String _generateSlug(String fileName) {
    // Remove the .md extension
    String slug = fileName.replaceAll('.md', '');

    return slug;
  }

  /// Processes the markdown content with custom regex functions
  String _processMarkdownContent(String content) {
    content = _convertMeditationInstructions(content);
    content = _convertAudioLinks(content);
    content = _convertWikiLinks(content);
    return content;
  }

  /// Converts %%...%% to a placeholder for expandable transcript
  String _convertMeditationInstructions(String text) {
    final pattern = RegExp(r'%%(.*?)%%', dotAll: true);
    return text.replaceAllMapped(pattern, (match) {
      // For markdown, we'll use a custom syntax that we can parse later
      return '{{transcript:${match.group(1)}}}';
    });
  }

  /// Converts ![[file.mp3]] to a placeholder for audio
  String _convertAudioLinks(String text) {
    final pattern = RegExp(r'!\[\[(.*?\.mp3)\]\]');
    return text.replaceAllMapped(pattern, (match) {
      final fileName = match.group(1)!;
      // For markdown, we'll use a custom syntax that we can parse later
      return '{{audio:$fileName}}';
    });
  }

  /// Converts [[Link Title]] to a placeholder for internal navigation
  String _convertWikiLinks(String text) {
    final pattern = RegExp(r'\[\[([^\]|]+)(?:\|([^\]]+))?\]\]');
    return text.replaceAllMapped(pattern, (match) {
      final target = match.group(1)!;
      final displayText = match.group(2) ?? target;
      // For markdown, we'll use a custom syntax that we can parse later
      return '{{link:$target|$displayText}}';
    });
  }

  /// Extracts all unique audio file names from the content
  List<String> _extractAudioFileNames(String content) {
    final pattern = RegExp(r'!\[\[(.*?\.mp3)\]\]');
    final matches = pattern.allMatches(content);
    final fileNames = <String>[];

    for (final match in matches) {
      final fileName = match.group(1)!;
      if (!fileNames.contains(fileName)) {
        fileNames.add(fileName);
      }
    }

    return fileNames;
  }
}
