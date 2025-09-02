class Lesson {
  final String title;
  final String slug;
  final String markdownContent;
  final List<String> audioFileNames;
  final String? nextLessonSlug;
  final String? prevLessonSlug;

  Lesson({
    required this.title,
    required this.slug,
    required this.markdownContent,
    required this.audioFileNames,
    this.nextLessonSlug,
    this.prevLessonSlug,
  });

  Lesson copyWith({
    String? title,
    String? slug,
    String? markdownContent,
    List<String>? audioFileNames,
    String? nextLessonSlug,
    String? prevLessonSlug,
  }) {
    return Lesson(
      title: title ?? this.title,
      slug: slug ?? this.slug,
      markdownContent: markdownContent ?? this.markdownContent,
      audioFileNames: audioFileNames ?? this.audioFileNames,
      nextLessonSlug: nextLessonSlug ?? this.nextLessonSlug,
      prevLessonSlug: prevLessonSlug ?? this.prevLessonSlug,
    );
  }

  /// Creates a Lesson instance from a map of data
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      title: json['title'] as String,
      slug: json['slug'] as String,
      markdownContent: json['markdownContent'] as String,
      audioFileNames: List<String>.from(json['audioFileNames'] as List),
      nextLessonSlug: json['nextLessonSlug'] as String?,
      prevLessonSlug: json['prevLessonSlug'] as String?,
    );
  }

  /// Converts a Lesson instance to a map of data
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'slug': slug,
      'markdownContent': markdownContent,
      'audioFileNames': audioFileNames,
      'nextLessonSlug': nextLessonSlug,
      'prevLessonSlug': prevLessonSlug,
    };
  }
}