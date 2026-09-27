import '../models/catalog_track.dart';

/// A replaceable, keyless source of music that the user is permitted to stream.
/// Providers return metadata only; playback obtains a URL through [streamUrl].
abstract interface class MusicProvider {
  String get id;
  String get displayName;

  Future<ProviderPage> search(String query, {int page = 1});
  Future<List<CatalogTrack>> home();
  Future<Uri> streamUrl(CatalogTrack track);
}

class ProviderPage {
  const ProviderPage({required this.items, this.hasMore = false});
  final List<CatalogTrack> items;
  final bool hasMore;
}
