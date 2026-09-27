import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../../services/library_controller.dart';
import '../../services/playback_controller.dart';
import '../widgets/track_artwork.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<PlaybackController>();
    final track = playback.current;
    if (track == null) {
      return const Scaffold(body: Center(child: Text('Nothing is playing')));
    }

    final liked = context.watch<LibraryController>().favorites.contains(track.id);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
              ),
              const Spacer(),
              Hero(
                tag: 'art-${track.id}',
                child: TrackArtwork(
                  id: track.id,
                  size: MediaQuery.of(context).size.width - 48,
                  radius: 24,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${track.artist} · ${track.album}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context
                        .read<LibraryController>()
                        .toggleFavorite(track.id),
                    icon: Icon(
                      liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: liked ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StreamBuilder<Duration>(
                stream: playback.position,
                builder: (_, positionSnapshot) {
                  final position = positionSnapshot.data ?? Duration.zero;
                  return StreamBuilder<Duration?>(
                    stream: playback.duration,
                    builder: (_, durationSnapshot) {
                      final duration = durationSnapshot.data ?? track.duration;
                      final maximum = duration.inMilliseconds
                          .toDouble()
                          .clamp(1, double.infinity)
                          .toDouble();
                      final value = position.inMilliseconds
                          .clamp(0, duration.inMilliseconds)
                          .toDouble();
                      return Column(
                        children: [
                          Slider(
                            value: value,
                            max: maximum,
                            onChanged: (newValue) => playback.seek(
                              Duration(milliseconds: newValue.round()),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_time(position)),
                              Text('-${_time(duration - position)}'),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: playback.toggleShuffle,
                    icon: Icon(
                      Icons.shuffle_rounded,
                      color: playback.shuffle
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  IconButton(
                    iconSize: 38,
                    onPressed: playback.previous,
                    icon: const Icon(Icons.skip_previous_rounded),
                  ),
                  FilledButton(
                    onPressed: playback.toggle,
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(17),
                    ),
                    child: Icon(
                      playback.playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 36,
                    ),
                  ),
                  IconButton(
                    iconSize: 38,
                    onPressed: playback.next,
                    icon: const Icon(Icons.skip_next_rounded),
                  ),
                  IconButton(
                    onPressed: playback.cycleRepeat,
                    icon: Icon(
                      Icons.repeat_rounded,
                      color: playback.loopMode == LoopMode.off
                          ? null
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  String _time(Duration duration) =>
      '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
}
