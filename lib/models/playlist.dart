class Playlist {
  const Playlist({required this.id, required this.name, required this.trackIds});

  final String id;
  final String name;
  final List<int> trackIds;

  Map<String, Object> toJson() => {'id': id, 'name': name, 'trackIds': trackIds};
  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'] as String,
        name: json['name'] as String,
        trackIds: (json['trackIds'] as List).cast<int>(),
      );

  Playlist copyWith({String? name, List<int>? trackIds}) => Playlist(
        id: id, name: name ?? this.name, trackIds: trackIds ?? this.trackIds);
}
