import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AudioWaves extends StatefulWidget {
  final String path;
  const AudioWaves({super.key, required this.path});

  @override
  State<AudioWaves> createState() => _AudioWavesState();
}

class _AudioWavesState extends State<AudioWaves> {
  final PlayerController playerController = PlayerController();
  bool _isPreparing = false;

  @override
  void initState() {
    super.initState();
    playerController.addListener(_refreshPlayerState);
    initAudioPlayer();
  }

  @override
  void didUpdateWidget(covariant AudioWaves oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      initAudioPlayer();
    }
  }

  Future<void> initAudioPlayer() async {
    if (_isPreparing) return;
    _isPreparing = true;
    try {
      await playerController.stopPlayer();
      await playerController.preparePlayer(path: widget.path, noOfSamples: 25);
    } finally {
      _isPreparing = false;
      _refreshPlayerState();
    }
  }

  Future<void> playAndPause() async {
    if (_isPreparing) return;
    if (playerController.playerState.isPlaying) {
      await playerController.pausePlayer();
    } else {
      await playerController.startPlayer();
    }
    _refreshPlayerState();
  }

  void _refreshPlayerState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    playerController.removeListener(_refreshPlayerState);
    playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            playAndPause();
          },
          icon: Icon(
            playerController.playerState.isPlaying
                ? CupertinoIcons.pause_solid
                : CupertinoIcons.play_arrow_solid,
          ),
        ),
        Expanded(
          child: AudioFileWaveforms(
            size: Size(double.infinity, 100),
            playerController: playerController,
            playerWaveStyle: PlayerWaveStyle(
              fixedWaveColor: AppPallete.borderColor,
              liveWaveColor: AppPallete.gradient2,
              spacing: 6,
              showSeekLine: false,
            ),
          ),
        ),
      ],
    );
  }
}
