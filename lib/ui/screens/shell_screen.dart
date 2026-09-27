import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/playback_controller.dart';
import '../widgets/track_artwork.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'now_playing_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class ShellScreen extends StatefulWidget { const ShellScreen({super.key}); @override State<ShellScreen> createState() => _ShellScreenState(); }
class _ShellScreenState extends State<ShellScreen> {
  int index = 0; final pages = const [HomeScreen(), SearchScreen(), LibraryScreen(), SettingsScreen()];
  @override Widget build(BuildContext context) => Scaffold(body: Stack(children: [IndexedStack(index: index, children: pages), Align(alignment: Alignment.bottomCenter, child: Column(mainAxisSize: MainAxisSize.min, children: [const _MiniPlayer(), NavigationBar(selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v), destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'), NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Search'), NavigationDestination(icon: Icon(Icons.library_music_outlined), selectedIcon: Icon(Icons.library_music_rounded), label: 'Library'), NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'Settings')])]))]));
}
class _MiniPlayer extends StatelessWidget { const _MiniPlayer(); @override Widget build(BuildContext context) { final p = context.watch<PlaybackController>(); final t = p.current; if (t == null) return const SizedBox.shrink(); return Material(color: const Color(0xff25232b), child: InkWell(onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NowPlayingScreen())), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(children: [TrackArtwork(id: t.id, size: 42, radius: 10), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)), Text(t.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: .6)))])), IconButton(onPressed: p.toggle, icon: Icon(p.playing ? Icons.pause_rounded : Icons.play_arrow_rounded))])))); } }
