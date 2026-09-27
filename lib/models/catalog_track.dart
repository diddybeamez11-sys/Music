class CatalogTrack {
  const CatalogTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.streamUrl,
    this.artworkUrl,
    this.duration = Duration.zero,
  });

  /// Parses the documented, provider-owned catalog response. Stream URLs must
  /// be short-lived URLs issued by a licensed service, never scraped URLs.
  factory CatalogTrack.fromJson(Map<String, dynamic> json) => CatalogTrack(
        id: json['id'] as String,
        title: json['title'] as String,
        artist: json['artist'] as String,
        album: json['album'] as String? ?? 'Single',
        streamUrl: Uri.parse(json['streamUrl'] as String),
        artworkUrl: json['artworkUrl'] as String?,
        duration: Duration(milliseconds: json['durationMs'] as int? ?? 0),
      );

  final String id;
  final String title;
  final String artist;
  final String album;
  final Uri streamUrl;
  final String? artworkUrl;
  final Duration duration;
}
