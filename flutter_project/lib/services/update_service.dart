import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';

class UpdateService {
  static const String _repoOwner = 'bdhrs';
  static const String _repoName = 'meditation-course-on-the-six-senses';
  static const String _markdownUrl =
      'https://api.github.com/repos/$_repoOwner/$_repoName/contents/source';
  static const String _audioReleaseUrl =
      'https://api.github.com/repos/$_repoOwner/$_repoName/releases/tags/audio-assets';

  // Keys for SharedPreferences
  static const String _prefKeyMarkdownSha = 'markdown_sha_';
  static const String _prefKeyAudioDigest = 'audio_digest_';

  Future<bool> checkForUpdates() async {
    try {
      debugPrint('UpdateService: Checking for updates...');
      final prefs = await SharedPreferences.getInstance();

      // Check Markdown updates
      final markdownUpdates = await _getMarkdownUpdates(prefs);
      debugPrint('UpdateService: Found ${markdownUpdates.length} markdown updates');
      if (markdownUpdates.isNotEmpty) {
        debugPrint('UpdateService: Markdown files to update: ${markdownUpdates.map((f) => f['name']).join(', ')}');
        return true;
      }

      // Check Audio updates
      final audioUpdates = await _getAudioUpdates(prefs);
      debugPrint('UpdateService: Found ${audioUpdates.length} audio updates');
      if (audioUpdates.isNotEmpty) {
        debugPrint('UpdateService: Audio files to update: ${audioUpdates.map((f) => f['name']).join(', ')}');
        return true;
      }

      debugPrint('UpdateService: No updates available');
      return false;
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      return false;
    }
  }

  Future<void> downloadUpdates(
      Function(double progress, String status) onProgress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appDir = await getApplicationDocumentsDirectory();

      // 1. Get updates
      onProgress(0.0, 'Checking for updates...');
      final markdownUpdates = await _getMarkdownUpdates(prefs);
      final audioUpdates = await _getAudioUpdates(prefs);

      final totalFiles = markdownUpdates.length + audioUpdates.length;
      if (totalFiles == 0) {
        onProgress(1.0, 'Up to date!');
        return;
      }

      int downloadedCount = 0;

      // 2. Download Markdown
      if (markdownUpdates.isNotEmpty) {
        final markdownDir = Directory(path.join(appDir.path, 'markdown'));
        if (!markdownDir.existsSync()) markdownDir.createSync(recursive: true);

        for (final file in markdownUpdates) {
          onProgress(
              downloadedCount / totalFiles, 'Downloading ${file['name']}...');
          await _downloadFile(
              file['download_url'], path.join(markdownDir.path, file['name']));
          await prefs.setString(
              '$_prefKeyMarkdownSha${file['name']}', file['sha']);
          downloadedCount++;
        }
      }

      // 3. Download Audio
      if (audioUpdates.isNotEmpty) {
        final audioDir = Directory(path.join(appDir.path, 'audio'));
        if (!audioDir.existsSync()) audioDir.createSync(recursive: true);

        for (final file in audioUpdates) {
          onProgress(
              downloadedCount / totalFiles, 'Downloading ${file['name']}...');
          await _downloadFile(file['browser_download_url'],
              path.join(audioDir.path, file['name']));
          // Store digest if available, otherwise use a placeholder to avoid re-downloading loop if API changes
          final digest = file['digest'] ?? 'downloaded_${DateTime.now().toIso8601String()}';
          await prefs.setString(
              '$_prefKeyAudioDigest${file['name']}', digest);
          downloadedCount++;
        }
      }

      onProgress(1.0, 'Update complete!');
    } catch (e) {
      debugPrint('Error downloading updates: $e');
      onProgress(1.0, 'Error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _getMarkdownUpdates(
      SharedPreferences prefs) async {
    final response = await http.get(Uri.parse(_markdownUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch markdown list: ${response.statusCode}');
    }

    final List<dynamic> remoteFiles = json.decode(response.body);
    final updates = <Map<String, dynamic>>[];

    for (final file in remoteFiles) {
      if (file['type'] != 'file' ||
          !file['name'].toString().endsWith('.md') ||
          file['name'].toString().startsWith('X')) {
        continue;
      }

      final name = file['name'];
      final sha = file['sha'];
      final localSha = prefs.getString('$_prefKeyMarkdownSha$name');

      debugPrint('UpdateService: Checking $name - Local SHA: ${localSha ?? "null"}, Remote SHA: $sha');
      
      // If we have a stored SHA, compare it
      if (localSha != null) {
        if (localSha != sha) {
          debugPrint('UpdateService: $name needs update (SHA changed)');
          updates.add(file as Map<String, dynamic>);
        }
      } else {
        // No stored SHA - compute SHA of bundled asset
        try {
          final bundledContent = await rootBundle.loadString('assets/markdown/$name');
          final bundledSha = _computeGitBlobSha(bundledContent);
          debugPrint('UpdateService: $name bundled SHA: $bundledSha');
          
          if (bundledSha != sha) {
            debugPrint('UpdateService: $name needs update (bundled differs from remote)');
            updates.add(file as Map<String, dynamic>);
          } else {
            debugPrint('UpdateService: $name bundled matches remote, skipping');
          }
        } catch (e) {
          // File doesn't exist in assets, need to download
          debugPrint('UpdateService: $name not in assets, needs download');
          updates.add(file as Map<String, dynamic>);
        }
      }
    }
    return updates;
  }

  /// Computes Git blob SHA-1 hash (same as GitHub uses)
  String _computeGitBlobSha(String content) {
    final bytes = utf8.encode(content);
    final header = utf8.encode('blob ${bytes.length}\u0000');
    final store = header + bytes;
    return sha1.convert(store).toString();
  }

  Future<List<Map<String, dynamic>>> _getAudioUpdates(
      SharedPreferences prefs) async {
    final response = await http.get(Uri.parse(_audioReleaseUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch audio release: ${response.statusCode}');
    }

    final releaseData = json.decode(response.body);
    final List<dynamic> assets = releaseData['assets'];
    final updates = <Map<String, dynamic>>[];

    for (final asset in assets) {
      if (!asset['name'].toString().endsWith('.mp3')) continue;

      final name = asset['name'];
      final digest = asset['digest'];
      final localDigest = prefs.getString('$_prefKeyAudioDigest$name');

      debugPrint('UpdateService: Checking audio $name - Local digest: ${localDigest ?? "null (using bundled)"}, Remote digest: $digest');
      
      // If localDigest is null, we're using bundled assets
      // Only mark for update if we have a stored digest and it differs from remote
      if (localDigest != null && digest != null && localDigest != digest) {
        debugPrint('UpdateService: $name needs update (digest changed)');
        updates.add(asset as Map<String, dynamic>);
      } else if (localDigest == null) {
        debugPrint('UpdateService: $name using bundled assets, skipping');
      }
    }
    return updates;
  }

  Future<void> _downloadFile(String url, String savePath) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to download file: $url');
    }
    final file = File(savePath);
    await file.writeAsBytes(response.bodyBytes);
  }
}
