import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:math';

class AudioPlayerWidget extends StatefulWidget {
  final String fileName;

  const AudioPlayerWidget({
    super.key,
    required this.fileName,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;


  // Stream combining position data using RxDart
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position,
          bufferedPosition,
          duration ?? Duration.zero,
        ),
      );

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _configureAudioSession();
    _initAudio();
  }

  Future<void> _configureAudioSession() async {
    try {
      // Configure audio session for proper audio focus handling on Android
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      debugPrint('Error configuring audio session: $e');
    }
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setAsset('assets/audio/${widget.fileName}');
    } catch (e) {
      debugPrint('Error loading audio asset: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(1, '0'); // No leading zero if single digit
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Colors matching transcript widget theme from app_theme.dart
    final Color cardBackgroundColor = isDarkMode
        ? const Color(0xFF15271D) // darkBlockBg
        : const Color(0xFFF0F0F0); // lightBlockBg
    final Color textColor = isDarkMode
        ? const Color(0xFFE0E0E0) // darkTextColor
        : const Color(0xFF212121); // lightTextColor
    final Color inactiveTrackColor = isDarkMode
        ? const Color(0xFF264532) // darkBorderColor
        : const Color(0xFFE0E0E0); // lightBorderColor
    final Color activeTrackColor = isDarkMode
        ? const Color(0xFF96C5A9) // darkPrimaryColor
        : const Color(0xFF366348); // lightPrimaryColor
    final Color thumbColor = isDarkMode
        ? const Color(0xFF96C5A9) // darkPrimaryColor
        : const Color(0xFF366348); // lightPrimaryColor
    final Color playButtonColor = isDarkMode
        ? const Color(0xFF96C5A9) // darkPrimaryColor
        : const Color(0xFF366348); // lightPrimaryColor

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Play/Pause Button
          StreamBuilder<PlayerState>(
            stream: _audioPlayer.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;

              Widget iconWidget;
              VoidCallback? onPressed;

              if (processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering) {
                iconWidget = SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(playButtonColor),
                  ),
                );
                onPressed = null;
              } else {
                // Use appropriate icon color based on theme
                final iconColor = isDarkMode ? Colors.black : Colors.white;
                iconWidget = Icon(
                  _audioPlayer.playing ? Icons.pause : Icons.play_arrow,
                  color: iconColor,
                  size: 30,
                );
                onPressed = _play;
              }

              return GestureDetector(
                onTap: onPressed,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: playButtonColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: iconWidget),
                ),
              );
            },
          ),
          const SizedBox(width: 12),

          Expanded(
            child: StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                final duration = positionData?.duration ?? Duration.zero;
                final position = positionData?.position ?? Duration.zero;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Time display - elapsed and total together in center
                    Center(
                      child: Text(
                        '${_formatDuration(position)} / ${_formatDuration(duration)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor
                              .withAlpha(204), // 0.8 opacity equivalent
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Slider with improved scrolling using just_audio
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4.0,
                        activeTrackColor: activeTrackColor,
                        inactiveTrackColor: inactiveTrackColor,
                        thumbColor: thumbColor,
                        overlayColor: thumbColor.withValues(alpha: 0.2),
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6.0),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 12.0),
                      ),
                      child: Slider(
                        min: 0.0,
                        max: duration.inMilliseconds.toDouble(),
                        value: min(
                          position.inMilliseconds.toDouble(),
                          duration.inMilliseconds.toDouble(),
                        ),
                        onChanged: (value) {
                          _audioPlayer
                              .seek(Duration(milliseconds: value.round()));
                        },
                        onChangeEnd: (value) {
                          _audioPlayer
                              .seek(Duration(milliseconds: value.round()));
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
