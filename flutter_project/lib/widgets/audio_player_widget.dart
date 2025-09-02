import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class AudioPlayerWidget extends StatefulWidget {
  final String fileName;

  const AudioPlayerWidget({
    super.key,
    required this.fileName,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isDownloaded = false;
  bool _checkingDownloadStatus = true;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
    });
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });
    
    // Check if the file is downloaded
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = path.join(dir.path, 'audio', widget.fileName);
      final file = File(filePath);
      final isDownloaded = await file.exists();
      
      if (mounted) {
        setState(() {
          _isDownloaded = isDownloaded;
          _checkingDownloadStatus = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _checkingDownloadStatus = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    if (_playerState == PlayerState.playing) {
      await _audioPlayer.pause();
    } else {
      if (_playerState == PlayerState.stopped) {
        if (_isDownloaded) {
          // Play from local file
          final dir = await getApplicationDocumentsDirectory();
          final audioPath = path.join(dir.path, 'audio', widget.fileName);
          await _audioPlayer.play(DeviceFileSource(audioPath));
        } else {
          // Play from online URL
          final baseUrl = 'https://github.com/bdhrs/meditation-course-on-the-six-senses/releases/download/audio-assets/';
          final url = '$baseUrl${widget.fileName}';
          await _audioPlayer.play(UrlSource(url));
        }
      } else {
        await _audioPlayer.resume();
      }
    }
  }

  Future<void> _stop() async {
    await _audioPlayer.stop();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audio: ${widget.fileName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_checkingDownloadStatus)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Checking download status...'),
              )
            else if (_isDownloaded)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Available offline',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Streaming from online source',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 16),
            Slider(
              min: 0,
              max: _duration.inMilliseconds.toDouble(),
              value: _position.inMilliseconds.toDouble(),
              onChanged: (value) {
                _audioPlayer.seek(Duration(milliseconds: value.toInt()));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position)),
                Text(_formatDuration(_duration)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: _stop,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    _playerState == PlayerState.playing
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  onPressed: _play,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}