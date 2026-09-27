import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/local_track.dart';
import '../../services/library_controller.dart';
import '../../services/playback_controller.dart';
import 'track_artwork.dart';

class TrackTile extends StatelessWidget {
  const TrackTile({super.key, required this.track, required this.queue, this.onMore});
  final LocalTrack track; final List<LocalTrack> queue; final VoidCallback? onMore;
  @override Widget build(BuildContext context) => ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3), leading: TrackArtwork(id: track.id), title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis), subtitle: Text('${track.artist} · ${track.album}', maxLines: 1, overflow: TextOverflow.ellipsis), trailing: IconButton(icon: const Icon(Icons.more_horiz_rounded), onPressed: onMore ?? () => _menu(context)), onTap: () { context.read<PlaybackController>().play(queue, queue.indexOf(track)); context.read<LibraryController>().markPlayed(track.id); });
  void _menu(BuildContext context) { showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Wrap(children: [ListTile(leading: const Icon(Icons.favorite_border_rounded), title: const Text('Toggle favorite'), onTap: () { context.read<LibraryController>().toggleFavorite(track.id); Navigator.pop(context); }), ListTile(leading: const Icon(Icons.playlist_add_rounded), title: const Text('Add to playlist'), onTap: () { Navigator.pop(context); _choosePlaylist(context); })]))); }
  void _choosePlaylist(BuildContext context) { final library = context.read<LibraryController>(); showModalBottomSheet(context: context, builder: (_) => SafeArea(child: ListView(children: library.playlists.map((p) => ListTile(title: Text(p.name), onTap: () { library.addToPlaylist(p.id, track.id); Navigator.pop(context); })).toList()))); }
}
