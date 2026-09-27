import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/local_track.dart';
import '../models/catalog_track.dart';
import 'preferences_store.dart';

class PlaybackController extends ChangeNotifier {
  PlaybackController(PreferencesStore _) : _handler = AuroraAudioHandler() {
    _handler.player.playerStateStream.listen((_) => notifyListeners());
    _handler.current.addListener(notifyListeners);
    _initializeAudioService();
  }

  final AuroraAudioHandler _handler;
  String? error;

  /// Register background/notification support without delaying the player.
  /// The handler owns a just_audio player already, so a tap can start playback
  /// even while Android is still connecting the media-service notification.
  Future<void> _initializeAudioService() async {
    try {
      await AudioService.init(
        builder: () => _handler,
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'aurora_playback',
          androidNotificationChannelName: 'Aurora playback',
          androidNotificationOngoing: true,
        ),
      );
    } catch (_) {
      // Playback still works in the foreground through just_audio. Only the
      // Android notification and lock-screen integration are unavailable.
      error = 'Background playback service is unavailable.';
      notifyListeners();
    }
  }

  Stream<Duration> get position => _handler.player.positionStream;
  Stream<Duration?> get duration => _handler.player.durationStream;
  LocalTrack? get current => _handler.current.value;
  bool get playing => _handler.player.playing;
  bool get shuffle => _handler.player.shuffleModeEnabled;
  LoopMode get loopMode => _handler.player.loopMode;
  Future<void> play(List<LocalTrack> tracks, int index) => _handler.playTracks(tracks, index);
  Future<void> playCatalog(List<CatalogTrack> tracks, int index) => _handler.playCatalogTracks(tracks, index);
  Future<void> toggle() => playing ? _handler.pause() : _handler.play();
  Future<void> next() => _handler.skipToNext();
  Future<void> previous() => _handler.skipToPrevious();
  Future<void> seek(Duration value) => _handler.seek(value);
  Future<void> toggleShuffle() => _handler.setShuffleMode(!shuffle ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none);
  Future<void> cycleRepeat() => _handler.setRepeatMode(loopMode == LoopMode.off ? AudioServiceRepeatMode.all : loopMode == LoopMode.all ? AudioServiceRepeatMode.one : AudioServiceRepeatMode.none);
}

class AuroraAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final player = AudioPlayer();
  final current = ValueNotifier<LocalTrack?>(null);
  List<LocalTrack> _tracks = [];
  AuroraAudioHandler() { player.playbackEventStream.listen(_broadcastState); player.currentIndexStream.listen((i) { if (i != null && i < _tracks.length) { current.value = _tracks[i]; mediaItem.add(_item(_tracks[i])); } }); }
  MediaItem _item(LocalTrack t) => MediaItem(id: t.uri, title: t.title, artist: t.artist, album: t.album, duration: t.duration, artUri: Uri.parse('content://media/external/audio/albumart/${t.id}'));
  Future<void> playTracks(List<LocalTrack> tracks, int index) async { _tracks = tracks; queue.add(tracks.map(_item).toList()); await player.setAudioSource(ConcatenatingAudioSource(children: tracks.map((t) => AudioSource.uri(Uri.parse(t.uri))).toList()), initialIndex: index); current.value = tracks[index]; await play(); }
  Future<void> playCatalogTracks(List<CatalogTrack> tracks, int index) async {
    _tracks = tracks.map(_localCatalogTrack).toList(growable: false);
    final items = tracks.map((t) => MediaItem(id: t.streamUrl.toString(), title: t.title, artist: t.artist, album: t.album, duration: t.duration, artUri: t.artworkUrl == null ? null : Uri.parse(t.artworkUrl!))).toList();
    queue.add(items);
    await player.setAudioSource(ConcatenatingAudioSource(children: tracks.map((t) => AudioSource.uri(t.streamUrl)).toList()), initialIndex: index);
    current.value = _tracks[index];
    mediaItem.add(items[index]);
    await play();
  }
  LocalTrack _localCatalogTrack(CatalogTrack track) => LocalTrack(
    id: -track.id.hashCode.abs(),
    title: track.title,
    artist: track.artist,
    album: track.album,
    duration: track.duration,
    uri: track.streamUrl.toString(),
  );
  void _broadcastState(PlaybackEvent event) { playbackState.add(PlaybackState(controls: [MediaControl.skipToPrevious, player.playing ? MediaControl.pause : MediaControl.play, MediaControl.skipToNext], systemActions: const {MediaAction.seek, MediaAction.seekForward, MediaAction.seekBackward}, androidCompactActionIndices: const [0, 1, 2], processingState: const {ProcessingState.idle: AudioProcessingState.idle, ProcessingState.loading: AudioProcessingState.loading, ProcessingState.buffering: AudioProcessingState.buffering, ProcessingState.ready: AudioProcessingState.ready, ProcessingState.completed: AudioProcessingState.completed}[player.processingState]!, playing: player.playing, updatePosition: player.position, bufferedPosition: player.bufferedPosition, queueIndex: event.currentIndex)); }
  @override Future<void> play() => player.play();
  @override Future<void> pause() => player.pause();
  @override Future<void> seek(Duration position) => player.seek(position);
  @override Future<void> skipToNext() => player.seekToNext();
  @override Future<void> skipToPrevious() => player.seekToPrevious();
  @override Future<void> setShuffleMode(AudioServiceShuffleMode mode) async { await player.setShuffleModeEnabled(mode == AudioServiceShuffleMode.all); }
  @override Future<void> setRepeatMode(AudioServiceRepeatMode mode) => player.setLoopMode({AudioServiceRepeatMode.none: LoopMode.off, AudioServiceRepeatMode.one: LoopMode.one, AudioServiceRepeatMode.all: LoopMode.all}[mode]!);
  @override Future<void> onTaskRemoved() => pause();
}
