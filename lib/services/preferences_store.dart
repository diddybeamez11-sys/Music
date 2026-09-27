import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/playlist.dart';

class PreferencesStore {
  PreferencesStore._(this._prefs);
  final SharedPreferences _prefs;
  static Future<PreferencesStore> create() async => PreferencesStore._(await SharedPreferences.getInstance());

  Set<int> get favorites => (_prefs.getStringList('favorites') ?? []).map(int.parse).toSet();
  Future<void> saveFavorites(Set<int> ids) => _prefs.setStringList('favorites', ids.map((id) => '$id').toList());
  List<Playlist> get playlists => (_prefs.getStringList('playlists') ?? [])
      .map((raw) => Playlist.fromJson(jsonDecode(raw) as Map<String, dynamic>)).toList();
  Future<void> savePlaylists(List<Playlist> items) => _prefs.setStringList('playlists', items.map((p) => jsonEncode(p.toJson())).toList());
  List<int> get recentIds => (_prefs.getStringList('recent') ?? []).map(int.parse).toList();
  Future<void> saveRecent(List<int> ids) => _prefs.setStringList('recent', ids.map((id) => '$id').toList());
}
