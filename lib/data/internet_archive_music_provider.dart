import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/music_provider.dart';
import '../models/catalog_track.dart';

/// Streams Creative-Commons-tagged community audio from Internet Archive.
/// No API key is used. Results without an audio file are ignored safely.
class InternetArchiveMusicProvider implements MusicProvider {
  InternetArchiveMusicProvider({http.Client? client}) : _client = client ?? http.Client();

  static const _searchEndpoint = 'https://archive.org/advancedsearch.php';
  final http.Client _client;

  @override
  String get id => 'internet_archive_cc';
  @override
  String get displayName => 'Open music archive';

  @override
  Future<ProviderPage> search(String query, {int page = 1}) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return const ProviderPage(items: []);
    final uri = Uri.parse(_searchEndpoint).replace(queryParameters: {
      'q': 'mediatype:audio AND collection:opensource_audio AND licenseurl:* AND ($normalized)',
      'fl[]': 'identifier,title,creator,year',
      'rows': '20',
      'page': '$page',
      'output': 'json',
    });
    final response = await _client.get(uri).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) throw MusicProviderException('The open music archive is unavailable.');
    final root = jsonDecode(response.body) as Map<String, dynamic>;
    final responseData = root['response'] as Map<String, dynamic>?;
    final docs = responseData?['docs'] as List<dynamic>? ?? const [];
    final tracks = await Future.wait(docs.cast<Map<String, dynamic>>().map(_toTrack));
    final total = responseData?['numFound'] as int? ?? 0;
    return ProviderPage(items: tracks.whereType<CatalogTrack>().toList(), hasMore: page * 20 < total);
  }

  @override
  Future<List<CatalogTrack>> home() async => (await search('year:[2020 TO *]')).items;

  Future<CatalogTrack?> _toTrack(Map<String, dynamic> doc) async {
    final identifier = doc['identifier'] as String?;
    if (identifier == null || identifier.isEmpty) return null;
    try {
      final metadataResponse = await _client.get(Uri.parse('https://archive.org/metadata/$identifier')).timeout(const Duration(seconds: 12));
      if (metadataResponse.statusCode != 200) return null;
      final metadata = jsonDecode(metadataResponse.body) as Map<String, dynamic>;
      Map<String, dynamic>? file;
      for (final rawFile in metadata['files'] as List<dynamic>? ?? const []) {
        final candidate = rawFile as Map<String, dynamic>;
        if (_isAudio(candidate['name'] as String?)) {
          file = candidate;
          break;
        }
      }
      final name = file?['name'] as String?;
      if (name == null) return null;
      final title = doc['title'] as String? ?? name;
      return CatalogTrack(
        id: '$identifier/$name',
        title: title,
        artist: doc['creator'] as String? ?? 'Internet Archive contributor',
        album: identifier,
        streamUrl: Uri.parse('https://archive.org/download/$identifier/${Uri.encodeComponent(name)}'),
        artworkUrl: 'https://archive.org/services/img/$identifier',
      );
    } catch (_) {
      return null;
    }
  }

  bool _isAudio(String? name) => name != null && const ['.mp3', '.ogg', '.flac', '.m4a', '.wav']
      .any((extension) => name.toLowerCase().endsWith(extension));

  @override
  Future<Uri> streamUrl(CatalogTrack track) async => track.streamUrl;

  void dispose() => _client.close();
}

class MusicProviderException implements Exception {
  const MusicProviderException(this.message);
  final String message;
}
