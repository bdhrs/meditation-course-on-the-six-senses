import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/lesson.dart';

class ContentService {
  static const String _documentsPath = 'assets/markdown';

  /// Reads all markdown files and creates Lesson objects
  Future<List<Lesson>> loadLessons() async {
    final lessons = <Lesson>[];

    // Get bundled files from assets
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap =
        Map<String, dynamic>.from(json.decode(manifestContent));

    final bundledFiles = manifestMap.keys
        .where((key) => key.startsWith(_documentsPath) && key.endsWith('.md'))
        .where((key) => !path.basename(key).startsWith('X')) // Skip draft files
        .toList();

    // Get local downloaded files (if any)
    final appDir = await getApplicationDocumentsDirectory();
    final localMarkdownDir = Directory(path.join(appDir.path, 'markdown'));
    final localFileNames = <String>{};
    
    if (localMarkdownDir.existsSync()) {
      localFileNames.addAll(
        localMarkdownDir
            .listSync()
            .where((entity) => entity is File && entity.path.endsWith('.md'))
            .where((entity) => !path.basename(entity.path).startsWith('X'))
            .map((entity) => path.basename(entity.path))
      );
    }

    // Process each file (prefer local version if it exists)
    final processedFileNames = <String>{};
    
    for (final bundledPath in bundledFiles) {
      final fileName = path.basename(bundledPath);
      
      if (processedFileNames.contains(fileName)) continue;
      processedFileNames.add(fileName);
      
      final String fileContent;
      final bool isLocal = localFileNames.contains(fileName);
      
      if (isLocal) {
        // Load from local storage
        final localFile = File(path.join(localMarkdownDir.path, fileName));
        fileContent = await localFile.readAsString();
      } else {
        // Load from bundled assets
        fileContent = await rootBundle.loadString(bundledPath);
      }

      // Parse the file name to generate title and slug
      final title = _getTitleFromFileName(fileName);
      final slug =
          _generateSlug(fileName); // Use fileName for slug to preserve ordering

      // Process the markdown content
      final processedContent = _processMarkdownContent(fileContent, fileName);

      // Extract audio file names
      final audioFileNames = _extractAudioFileNames(fileContent);

      // Extract headings
      final headings = _extractHeadings(fileContent);

      lessons.add(Lesson(
        title: title,
        slug: slug,
        markdownContent: processedContent,
        audioFileNames: audioFileNames,
        headings: headings,
      ));
    }

    // Sort lessons by slug to maintain proper order
    lessons.sort((a, b) => a.slug.compareTo(b.slug));

    // Create a virtual lesson for the title page
    final titlePageLesson = Lesson(
      title: 'Title Page',
      slug: 'title-page',
      markdownContent: '{{TITLE_PAGE}}',
      audioFileNames: [],
      headings: [],
    );

    // Add the title page at the beginning
    lessons.insert(0, titlePageLesson);

    // Populate nextLessonSlug and prevLessonSlug
    for (int i = 0; i < lessons.length; i++) {
      String? nextSlug;
      String? prevSlug;

      if (i > 0) {
        prevSlug = lessons[i - 1].slug;
      } else {
        // First lesson (Title Page) has no previous
        prevSlug = null;
      }

      if (i < lessons.length - 1) {
        nextSlug = lessons[i + 1].slug;
      }

      lessons[i] = lessons[i].copyWith(
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

    // Replace hyphens and underscores with spaces
    title = title.replaceAll('-', ' ').replaceAll('_', ' ');

    return title.trim();
  }

  /// Generates a URL-friendly slug from a string
  String _generateSlug(String text) {
    // Remove the .md extension if present
    String slug = text.replaceAll('.md', '');
    // Convert to lowercase
    slug = slug.toLowerCase();
    // Replace spaces and underscores with hyphens
    slug = slug.replaceAll(RegExp(r'[\s_]+'), '-');
    // Remove any characters that are not alphanumeric or hyphens
    slug = slug.replaceAll(RegExp(r'[^a-z0-9-]'), '');
    return slug;
  }

  /// Processes the markdown content with custom regex functions
  /// Adds the file name as an H1 heading at the top of the content
  String _processMarkdownContent(String content, String fileName) {
    // Add the file name as an H1 heading at the top of the content
    final title = _getTitleFromFileName(fileName);
    content = '# $title\n\n$content';

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

  /// Converts [[Link Title#Heading|Display Text]] to a placeholder for internal navigation
  String _convertWikiLinks(String text) {
    final pattern = RegExp(r'\[\[([^\]|#]+)(?:#([^\]|]+))?(?:\|([^\]]+))?\]\]');
    return text.replaceAllMapped(pattern, (match) {
      final pageTarget = match.group(1)!.trim();
      final headingTarget = match.group(2)?.trim();
      final displayText = match.group(3)?.trim() ?? headingTarget ?? pageTarget;

      final pageSlug = _generateSlug(pageTarget);
      final headingSlug =
          headingTarget != null ? _generateSlug(headingTarget) : '';

      final uri = headingSlug.isNotEmpty
          ? 'sixsenses://$pageSlug#$headingSlug'
          : 'sixsenses://$pageSlug';

      return '{{link:$uri|$displayText}}';
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

  /// Extracts all headings from the markdown content
  List<Map<String, String>> _extractHeadings(String content) {
    final headings = <Map<String, String>>[];
    final lines = content.split('\n');
    final pattern = RegExp(r'^(#{1,6})\s+(.*)');

    for (final line in lines) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        final text = match.group(2)!.trim();
        final slug = _generateSlug(text);
        headings.add({'text': text, 'slug': slug});
      }
    }
    return headings;
  }
}
