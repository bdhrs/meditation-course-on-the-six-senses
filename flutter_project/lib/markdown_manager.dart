// models/markdown_page.dart
class MarkdownPage {
  final String title;
  final String slug;
  final String content;
  final DateTime lastModified;
  final Map<String, dynamic>? metadata;

  MarkdownPage({
    required this.title,
    required this.slug,
    required this.content,
    DateTime? lastModified,
    this.metadata,
  }) : lastModified = lastModified ?? DateTime.now();

  // Factory constructor to create from JSON/Map
  factory MarkdownPage.fromMap(Map<String, dynamic> map) {
    return MarkdownPage(
      title: map['title'] as String,
      slug: map['slug'] as String,
      content: map['content'] as String,
      lastModified: DateTime.parse(map['lastModified'] as String),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'slug': slug,
      'content': content,
      'lastModified': lastModified.toIso8601String(),
      'metadata': metadata,
    };
  }
}

// services/markdown_service.dart
class MarkdownService {
  final Map<String, MarkdownPage> _pages = {};
  
  // Load pages from assets
  Future<void> loadPages() async {
    try {
      // Example loading from assets - adjust path as needed
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestContent);
      
      final markdownFiles = manifest.keys.where((String key) => 
        key.startsWith('assets/markdown/') && key.endsWith('.md'));

      for (final file in markdownFiles) {
        final content = await rootBundle.loadString(file);
        final fileName = file.split('/').last.replaceAll('.md', '');
        final title = fileName.replaceAll('-', ' ').capitalize();
        
        _pages[fileName] = MarkdownPage(
          title: title,
          slug: fileName,
          content: content,
        );
      }
    } catch (e) {
      print('Error loading markdown pages: $e');
      rethrow;
    }
  }

  List<MarkdownPage> get allPages => _pages.values.toList();
  
  MarkdownPage? getPage(String slug) => _pages[slug];
  
  List<MarkdownPage> searchPages(String query) {
    query = query.toLowerCase();
    return _pages.values.where((page) =>
      page.title.toLowerCase().contains(query) ||
      page.content.toLowerCase().contains(query)
    ).toList();
  }
}