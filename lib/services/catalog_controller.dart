import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/catalog_track.dart';
import '../domain/music_provider.dart';
import '../data/internet_archive_music_provider.dart';

class CatalogController extends ChangeNotifier {
  CatalogController([MusicProvider? provider]) : _provider = provider ?? InternetArchiveMusicProvider();
  final MusicProvider _provider;
  List<CatalogTrack> results = const [];
  List<CatalogTrack> featured = const [];
  String? error;
  bool loading = false;
  Timer? _debounce;
  bool get available => true;
  String get providerName => _provider.displayName;

  Future<void> loadHome() async {
    if (featured.isNotEmpty || loading) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      featured = await _provider.home();
    } on MusicProviderException catch (exception) {
      error = exception.message;
    } catch (_) {
      error = 'Could not load music while offline.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      results = const [];
      error = null;
      notifyListeners();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () => _load(query));
  }

  Future<void> _load(String query) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      results = (await _provider.search(query)).items;
    } on MusicProviderException catch (exception) {
      error = exception.message;
      results = const [];
    } catch (_) {
      error = 'Could not reach the music catalog.';
      results = const [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (_provider is InternetArchiveMusicProvider) {
      (_provider as InternetArchiveMusicProvider).dispose();
    }
    super.dispose();
  }
}
