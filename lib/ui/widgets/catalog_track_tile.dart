import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/catalog_track.dart';
import '../../services/playback_controller.dart';

class CatalogTrackTile extends StatelessWidget {
  const CatalogTrackTile({super.key, required this.track, required this.queue});
  final CatalogTrack track;
  final List<CatalogTrack> queue;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
        leading: Semantics(
          label: 'Artwork for ${track.title}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              track.artworkUrl ?? '',
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Color(0xff373440),
                child: SizedBox(width: 52, height: 52, child: Icon(Icons.music_note_rounded)),
              ),
            ),
          ),
        ),
        title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${track.artist} · ${track.album}', maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.play_circle_outline_rounded),
        onTap: () => context.read<PlaybackController>().playCatalog(queue, queue.indexOf(track)),
      );
}
