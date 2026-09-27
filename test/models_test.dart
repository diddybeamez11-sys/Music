import 'package:flutter_test/flutter_test.dart';
import 'package:aurora_music/models/catalog_track.dart';
import 'package:aurora_music/models/playlist.dart';

void main() {
  test('catalog response track parses an authorized stream URL', () {
    final track = CatalogTrack.fromJson({
      'id': 'open-1',
      'title': 'Open track',
      'artist': 'An artist',
      'album': 'An album',
      'durationMs': 120000,
      'streamUrl': 'https://media.example.test/open-1.mp3',
    });
    expect(track.streamUrl.scheme, 'https');
    expect(track.duration, const Duration(minutes: 2));
  });

  test('playlist round trips its locally persisted track order', () {
    const playlist = Playlist(id: 'p1', name: 'Focus', trackIds: [7, 2, 9]);
    final restored = Playlist.fromJson(playlist.toJson());
    expect(restored.name, 'Focus');
    expect(restored.trackIds, [7, 2, 9]);
  });
}
