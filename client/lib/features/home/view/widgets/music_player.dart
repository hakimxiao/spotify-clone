import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicPlayer extends ConsumerWidget {
  const MusicPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongNotifierProvider);
    final songNotifier = ref.read(currentSongNotifierProvider.notifier);
    final userFavorites = ref.watch(
      currentUserNotifierProvider.select((value) => value!.favorites),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [hexToColor(currentSong!.hex_code), Color(0xFF121212)],
        ),
      ),
      child: Scaffold(
        backgroundColor: AppPallete.transparentColor,
        appBar: AppBar(
          backgroundColor: AppPallete.transparentColor,
          leading: Transform.translate(
            offset: Offset(-15, 0),
            child: InkWell(
              highlightColor: AppPallete.transparentColor,
              focusColor: AppPallete.transparentColor,
              splashColor: AppPallete.transparentColor,
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset(
                    'assets/images/pull-down-arrow.png',
                    color: AppPallete.whiteColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Hero(
                  tag: 'music-image',
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(currentSong.thumbnail_url),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentSong.song_name,
                            style: TextStyle(
                              color: AppPallete.whiteColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            currentSong.artist,
                            style: TextStyle(
                              color: AppPallete.subtitleText,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Expanded(child: SizedBox()),
                      IconButton(
                        onPressed: () async {
                          await ref
                              .read(homeViewmodelProvider.notifier)
                              .favSong(songId: currentSong.id);
                        },
                        icon: Icon(
                          userFavorites
                                  .where((fav) => fav.song_id == currentSong.id)
                                  .toList()
                                  .isNotEmpty
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                        ),
                        color: AppPallete.whiteColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  StreamBuilder(
                    stream: songNotifier.audioPlayer!.positionStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox();
                      }

                      final position = snapshot.data;
                      final duration = songNotifier.audioPlayer!.duration;
                      double sliderValue = 0.0;

                      if (position != null && duration != null) {
                        sliderValue =
                            position.inMilliseconds / duration.inMilliseconds;
                      }
                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppPallete.whiteColor,
                              inactiveTrackColor: AppPallete.whiteColor
                                  .withValues(alpha: 0.117),
                              thumbColor: AppPallete.whiteColor,
                              trackHeight: 4,
                              overlayShape: SliderComponentShape.noOverlay,
                            ),
                            child: Slider(
                              value: sliderValue,
                              min: 0,
                              max: 1,
                              onChanged: (value) {
                                sliderValue = value;
                              },
                              onChangeEnd: (value) {
                                songNotifier.seek(value);
                              },
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${position?.inMinutes}:${(position?.inSeconds ?? 0) < 10 ? '0${position?.inSeconds}' : position?.inSeconds}',
                                style: TextStyle(
                                  color: AppPallete.subtitleText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Expanded(child: SizedBox()),
                              Text(
                                '${duration?.inMinutes}:${(duration?.inSeconds ?? 0) < 10 ? '0${duration?.inSeconds}' : duration?.inSeconds}',
                                style: TextStyle(
                                  color: AppPallete.subtitleText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/images/shuffle.png',
                          color: AppPallete.whiteColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/images/previus-song.png',
                          color: AppPallete.whiteColor,
                        ),
                      ),
                      IconButton(
                        onPressed: songNotifier.playPause,
                        icon: Icon(
                          songNotifier.isPlaying
                              ? CupertinoIcons.pause_circle_fill
                              : CupertinoIcons.play_circle_fill,
                        ),
                        iconSize: 80,
                        color: AppPallete.whiteColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/images/next-song.png',
                          color: AppPallete.whiteColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/images/repeat.png',
                          color: AppPallete.whiteColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/images/connect-device.png',
                          color: AppPallete.whiteColor,
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/images/playlist.png',
                          color: AppPallete.whiteColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
