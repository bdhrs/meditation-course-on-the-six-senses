import 'dart:io';
import 'package:path/path.dart' as path;

/// Library copy_assets.dart
/// 1. clears the local 'assets/md' folder
/// 2. copies Markdown files from the Obsidian folder to the local 'assets/md' folder
/// - It ignores files that don't have the '.md' extension
/// - It ignores files that start with 'xxx' 

const sourceDir = "../../../Obsidian/4. Projects/Six sense fields/";
const targetDir = "assets/md";

Future<void> clearDirectory(String dirPath) async {
  final directory = Directory(dirPath);
  if (await directory.exists()) {
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        await entity.delete();
      } else if (entity is Directory) {
        await entity.delete(recursive: true);
      }
    }
    print('Cleared target directory: $dirPath');
  }
}

Future<void> copyMarkdownFiles(String sourceDir, String targetDir) async {
  final source = Directory(sourceDir);
  if (!await source.exists()) {
    throw Exception('Source directory not found: $sourceDir');
  }

  await Directory(targetDir).create(recursive: true);
  
  await for (final entity in source.list(recursive: true)) {
    if (
      entity is File && 
      path.extension(entity.path).toLowerCase() == '.md' &&
      !path.basenameWithoutExtension(entity.path).startsWith('xxx')
    ) {
      final relativePath = path.relative(entity.path, from: sourceDir);
      final targetPath = path.join(targetDir, relativePath);
      
      await Directory(path.dirname(targetPath)).create(recursive: true);
      await entity.copy(targetPath);
      print('Copied: $relativePath');
    }
  }
}

// Usage
void main() async {
  await clearDirectory(targetDir);
  await copyMarkdownFiles(sourceDir, targetDir);
}
