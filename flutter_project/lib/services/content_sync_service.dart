import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ContentSyncService {
  static const String _repoUrl = 
      'https://github.com/bdhrs/meditation-course-on-the-six-senses';
  static const String _apiUrl = 
      'https://api.github.com/repos/bdhrs/meditation-course-on-the-six-senses';
  
  /// Get the path to the local documents directory
  Future<String> getLocalDocumentsPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return path.join(dir.path, 'documents');
  }
  
  /// Check if local content exists
  Future<bool> hasLocalContent() async {
    final documentsPath = await getLocalDocumentsPath();
    final documentsDir = Directory(documentsPath);
    return await documentsDir.exists();
  }
  
  /// Get the last updated timestamp of local content
  Future<DateTime?> getLastUpdated() async {
    try {
      final documentsPath = await getLocalDocumentsPath();
      final timestampFile = File(path.join(documentsPath, '.timestamp'));
      if (await timestampFile.exists()) {
        final timestampStr = await timestampFile.readAsString();
        return DateTime.parse(timestampStr);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Get the latest commit information from GitHub
  Future<Map<String, dynamic>?> getLatestCommitInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/commits'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );
      
      if (response.statusCode == 200) {
        final List commits = json.decode(response.body);
        if (commits.isNotEmpty) {
          return commits[0];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Check if an update is available
  Future<bool> isUpdateAvailable() async {
    try {
      final localLastUpdated = await getLastUpdated();
      final latestCommit = await getLatestCommitInfo();
      
      if (latestCommit == null) {
        return false;
      }
      
      final latestCommitDate = 
          DateTime.parse(latestCommit['commit']['committer']['date']);
      
      if (localLastUpdated == null) {
        return true; // No local content, update needed
      }
      
      return latestCommitDate.isAfter(localLastUpdated);
    } catch (e) {
      return false;
    }
  }
  
  /// Download and extract the repository zip file
  Future<void> downloadAndExtractContent() async {
    try {
      // Download the zip file
      final response = await http.get(
        Uri.parse('$_repoUrl/archive/refs/heads/main.zip'),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to download repository zip file');
      }
      
      // Decode the zip archive
      final archive = ZipDecoder().decodeBytes(response.bodyBytes);
      
      // Get the documents path
      final documentsPath = await getLocalDocumentsPath();
      final documentsDir = Directory(documentsPath);
      
      // Create the documents directory if it doesn't exist
      if (!await documentsDir.exists()) {
        await documentsDir.create(recursive: true);
      }
      
      // Extract files from the archive
      for (final file in archive) {
        final filename = file.name;
        
        // Skip directories
        if (file.isFile) {
          // Extract only files from the source directory
          if (filename.contains('/source/') && 
              (filename.endsWith('.md') || 
               filename.contains('/source/assets/'))) {
            
            // Get the relative path
            final relativePath = filename.split('/source/').last;
            final outputPath = path.join(documentsPath, relativePath);
            
            // Create directories if needed
            final outputFile = File(outputPath);
            await outputFile.create(recursive: true);
            
            // Write file content
            await outputFile.writeAsBytes(file.content as List<int>);
          }
        }
      }
      
      // Update the timestamp
      final timestampFile = File(path.join(documentsPath, '.timestamp'));
      await timestampFile.writeAsString(DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('Failed to download and extract content: $e');
    }
  }
  
  /// Sync content with the remote repository
  Future<void> syncContent() async {
    try {
      final updateAvailable = await isUpdateAvailable();
      if (updateAvailable) {
        await downloadAndExtractContent();
      }
    } catch (e) {
      throw Exception('Failed to sync content: $e');
    }
  }
}