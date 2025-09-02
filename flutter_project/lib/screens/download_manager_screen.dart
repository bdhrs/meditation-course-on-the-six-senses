import 'package:flutter/material.dart';
import '../services/download_service.dart';

class DownloadManagerScreen extends StatefulWidget {
  const DownloadManagerScreen({super.key});

  @override
  State<DownloadManagerScreen> createState() => _DownloadManagerScreenState();
}

class _DownloadManagerScreenState extends State<DownloadManagerScreen> {
  late Future<List<String>> _audioFilesFuture;
  final DownloadService _downloadService = DownloadService();
  Map<String, DownloadStatus> _downloadStatus = {};
  Map<String, double> _downloadProgress = {};
  double _overallProgress = 0.0;
  bool _isDownloading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAudioFiles();
  }

  Future<void> _loadAudioFiles() async {
    setState(() {
      _error = null;
    });
    
    try {
      final audioFiles = await _downloadService.getAllAudioFiles();
      
      setState(() {
        _audioFilesFuture = Future.value(audioFiles);
        _downloadStatus = {
          for (final file in audioFiles)
            file: DownloadStatus.notStarted
        };
        _downloadProgress = {
          for (final file in audioFiles)
            file: 0.0
        };
      });
      
      // Check which files are already downloaded
      for (final fileName in audioFiles) {
        final isDownloaded = await _downloadService.isAudioFileDownloaded(fileName);
        if (isDownloaded) {
          setState(() {
            _downloadStatus[fileName] = DownloadStatus.completed;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _downloadAllAudio() async {
    setState(() {
      _isDownloading = true;
      _error = null;
    });
    
    try {
      await _downloadService.downloadAllAudioFiles(
        onFileProgress: (fileName, progress) {
          setState(() {
            _downloadProgress[fileName] = progress;
            if (progress < 1.0) {
              _downloadStatus[fileName] = DownloadStatus.downloading;
            } else {
              _downloadStatus[fileName] = DownloadStatus.completed;
            }
          });
        },
        onOverallProgress: (progress) {
          setState(() {
            _overallProgress = progress;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  Future<void> _deleteAllAudio() async {
    try {
      await _downloadService.deleteAllAudioFiles();
      
      // Reset download status
      final audioFiles = await _audioFilesFuture;
      setState(() {
        _downloadStatus = {
          for (final file in audioFiles)
            file: DownloadStatus.notStarted
        };
        _downloadProgress = {
          for (final file in audioFiles)
            file: 0.0
        };
        _overallProgress = 0.0;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Download Audio Files',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _overallProgress),
            const SizedBox(height: 8),
            Text('${(_overallProgress * 100).round()}% complete'),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isDownloading ? null : _downloadAllAudio,
                  child: _isDownloading
                      ? const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Downloading...'),
                          ],
                        )
                      : const Text('Download All'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isDownloading ? null : _deleteAllAudio,
                  child: const Text('Delete All'),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Error:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            const Text(
              'Audio Files',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: _audioFilesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading audio files...'),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error: ${snapshot.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadAudioFiles,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasData) {
                    final audioFiles = snapshot.data!;
                    return ListView.builder(
                      itemCount: audioFiles.length,
                      itemBuilder: (context, index) {
                        final fileName = audioFiles[index];
                        final status = _downloadStatus[fileName] ?? DownloadStatus.notStarted;
                        final progress = _downloadProgress[fileName] ?? 0.0;
                        return Card(
                          child: ListTile(
                            title: Text(fileName),
                            subtitle: status == DownloadStatus.downloading
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      LinearProgressIndicator(value: progress),
                                      const SizedBox(height: 4),
                                      Text('${(progress * 100).round()}%'),
                                    ],
                                  )
                                : Text(_getStatusText(status)),
                            trailing: _getStatusIcon(status),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No audio files found'),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.notStarted:
        return 'Not downloaded';
      case DownloadStatus.downloading:
        return 'Downloading...';
      case DownloadStatus.completed:
        return 'Downloaded';
      case DownloadStatus.failed:
        return 'Failed';
    }
  }

  Widget _getStatusIcon(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.notStarted:
        return const Icon(Icons.cloud_download, color: Colors.grey);
      case DownloadStatus.downloading:
        return const CircularProgressIndicator();
      case DownloadStatus.completed:
        return const Icon(Icons.check, color: Colors.green);
      case DownloadStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
    }
  }
}

enum DownloadStatus {
  notStarted,
  downloading,
  completed,
  failed,
}