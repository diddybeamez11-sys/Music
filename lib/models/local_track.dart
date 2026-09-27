import 'package:on_audio_query/on_audio_query.dart';

class LocalTrack {
  const LocalTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.uri,
  });

  factory LocalTrack.fromSong(SongModel song) => LocalTrack(
        id: song.id,
        title: song.title.trim().isEmpty ? 'Untitled' : song.title,
        artist: song.artist ?? 'Unknown artist',
        album: song.album ?? 'Unknown album',
        duration: Duration(milliseconds: song.duration ?? 0),
        uri: song.uri ?? song.data,
      );

  final int id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String uri;
}
