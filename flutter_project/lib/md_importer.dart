import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MdImporter extends StatelessWidget {
  final String filePath;

  MdImporter({required this.filePath});

  Future<String> loadMarkdown() async {
    try {
      return await rootBundle.loadString(filePath);
    } catch (e) {
      return 'Error loading file: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: loadMarkdown(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              snapshot.data ?? 'No content available.',
              style: const TextStyle(fontSize: 14),
            ),
          );
        }
      },
    );
  }
}
