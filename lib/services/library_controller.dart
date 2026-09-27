import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../models/local_track.dart';
import '../models/playlist.dart';
import 'preferences_store.dart';

class LibraryController extends ChangeNotifier {
  LibraryController(this._store);
  final PreferencesStore _store;
  final _query = OnAudioQuery();
  List<LocalTrack> tracks = [];
  Set<int> favorites = {};
  List<Playlist> playlists = [];
  List<int> recentIds = [];
  bool loading = true;
  bool permissionDenied = false;

  Future<void> load() async {
    favorites = _store.favorites; playlists = _store.playlists; recentIds = _store.recentIds;
    final granted = (await Permission.audio.request()).isGranted ||
        (await Permission.storage.request()).isGranted;
    if (!granted) { loading = false; permissionDenied = true; notifyListeners(); return; }
    final songs = await _query.querySongs(uriType: UriType.EXTERNAL, ignoreCase: true);
    tracks = songs.where((song) => song.isMusic && (song.uri ?? song.data).isNotEmpty).map(LocalTrack.fromSong).toList();
    loading = false; permissionDenied = false; notifyListeners();
  }

  List<LocalTrack> get recent => recentIds.map(_byId).whereType<LocalTrack>().toList();
  LocalTrack? _byId(int id) { for (final track in tracks) { if (track.id == id) return track; } return null; }
  List<LocalTrack> matches(String query) { final q = query.toLowerCase(); return tracks.where((t) => '${t.title} ${t.artist} ${t.album}'.toLowerCase().contains(q)).toList(); }
  Future<void> toggleFavorite(int id) async { favorites.contains(id) ? favorites.remove(id) : favorites.add(id); await _store.saveFavorites(favorites); notifyListeners(); }
  Future<void> markPlayed(int id) async { recentIds = [id, ...recentIds.where((x) => x != id)].take(20).toList(); await _store.saveRecent(recentIds); notifyListeners(); }
  Future<void> createPlaylist(String name) async { playlists = [...playlists, Playlist(id: const Uuid().v4(), name: name, trackIds: const [])]; await _store.savePlaylists(playlists); notifyListeners(); }
  Future<void> renamePlaylist(String id, String name) async { playlists = playlists.map((p) => p.id == id ? p.copyWith(name: name) : p).toList(); await _store.savePlaylists(playlists); notifyListeners(); }
  Future<void> deletePlaylist(String id) async { playlists.removeWhere((p) => p.id == id); await _store.savePlaylists(playlists); notifyListeners(); }
  Future<void> addToPlaylist(String id, int trackId) async { playlists = playlists.map((p) => p.id == id && !p.trackIds.contains(trackId) ? p.copyWith(trackIds: [...p.trackIds, trackId]) : p).toList(); await _store.savePlaylists(playlists); notifyListeners(); }
  Future<void> reorderPlaylist(String id, int oldIndex, int newIndex) async { final p = playlists.firstWhere((x) => x.id == id); final ids = [...p.trackIds]; if (oldIndex < newIndex) newIndex--; ids.insert(newIndex, ids.removeAt(oldIndex)); playlists = playlists.map((x) => x.id == id ? x.copyWith(trackIds: ids) : x).toList(); await _store.savePlaylists(playlists); notifyListeners(); }
  List<LocalTrack> playlistTracks(Playlist p) => p.trackIds.map(_byId).whereType<LocalTrack>().toList();
  List<LocalTrack> get shuffled => [...tracks]..shuffle(Random());
}
