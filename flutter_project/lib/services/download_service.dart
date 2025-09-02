import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class DownloadService {
  static const String _baseUrl = 
      'https://github.com/bdhrs/meditation-course-on-the-six-senses/releases/download/audio-assets/';
  
  final Dio _dio = Dio();
  
  /// Get the list of all unique audio files from all lessons
  Future<List<String>> getAllAudioFiles() async {
    // For now, we'll return an empty list since we don't have access to ContentService here
    // In a real implementation, this would fetch the list of audio files
    return [];
  }
  
  /// Check if an audio file is already downloaded
  Future<bool> isAudioFileDownloaded(String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = path.join(dir.path, 'audio', fileName);
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
  
  /// Download a single audio file
  Future<void> downloadAudioFile(
    String fileName,
    Function(double progress)? onProgress,
  ) async {
    try {
      // Create directory if it doesn't exist
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory(path.join(dir.path, 'audio'));
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }
      
      // Download file
      final filePath = path.join(audioDir.path, fileName);
      final url = '$_baseUrl$fileName';
      
      await _dio.download(
        url, 
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );
    } catch (e) {
      throw Exception('Failed to download audio file: $e');
    }
  }
  
  /// Download all audio files
  Future<void> downloadAllAudioFiles({
    Function(String fileName, double progress)? onFileProgress,
    Function(double overallProgress)? onOverallProgress,
  }) async {
    try {
      final audioFiles = await getAllAudioFiles();
      final totalFiles = audioFiles.length;
      int completedFiles = 0;
      
      for (final fileName in audioFiles) {
        await downloadAudioFile(
          fileName,
          (progress) => onFileProgress?.call(fileName, progress),
        );
        
        completedFiles++;
        onOverallProgress?.call(completedFiles / totalFiles);
      }
    } catch (e) {
      throw Exception('Failed to download all audio files: $e');
    }
  }
  
  /// Delete all downloaded audio files
  Future<void> deleteAllAudioFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory(path.join(dir.path, 'audio'));
      if (await audioDir.exists()) {
        await audioDir.delete(recursive: true);
      }
    } catch (e) {
      throw Exception('Failed to delete audio files: $e');
    }
  }
  
  /// Get the local file path for a downloaded audio file
  Future<String?> getLocalFilePath(String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = path.join(dir.path, 'audio', fileName);
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}