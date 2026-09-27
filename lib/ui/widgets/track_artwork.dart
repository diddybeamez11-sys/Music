import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class TrackArtwork extends StatelessWidget {
  const TrackArtwork({super.key, required this.id, this.size = 52, this.radius = 12});
  final int id; final double size; final double radius;
  @override Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(radius), child: QueryArtworkWidget(id: id, type: ArtworkType.AUDIO, artworkFit: BoxFit.cover, size: size.round(), nullArtworkWidget: Container(width: size, height: size, alignment: Alignment.center, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xff7356a6), Color(0xff28364f)])), child: Icon(Icons.graphic_eq_rounded, color: Colors.white.withValues(alpha: .8)))));
}
