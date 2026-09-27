import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/catalog_track.dart';

/// Transport boundary for a licensed music provider or a first-party catalog.
/// The client never contains provider credentials or music files.
class CatalogRepository {
  CatalogRepository({required String endpoint, http.Client? client})
      : _endpoint = Uri.parse(endpoint),
        _client = client ?? http.Client();

  final Uri _endpoint;
  final http.Client _client;

  Future<List<CatalogTrack>> search(String query) async {
    if (query.trim().isEmpty) return const [];
    final uri = _endpoint.resolve('/v1/catalog/search').replace(
      queryParameters: {'q': query.trim(), 'limit': '50'},
    );
    final response = await _client.get(uri, headers: const {'Accept': 'application/json'});
    if (response.statusCode != 200) {
      throw CatalogException('Catalog search failed (${response.statusCode}).');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = decoded['items'] as List<dynamic>? ?? const [];
    return items
        .cast<Map<String, dynamic>>()
        .map(CatalogTrack.fromJson)
        .toList(growable: false);
  }

  void dispose() => _client.close();
}

class CatalogException implements Exception {
  const CatalogException(this.message);
  final String message;
  @override
  String toString() => message;
}
