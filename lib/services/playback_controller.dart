import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/local_track.dart';
import '../models/catalog_track.dart';
import 'preferences_store.dart';

class PlaybackController extends ChangeNotifier {
  PlaybackController(this._store) {
    _ready = _initialize();
  }

  final PreferencesStore _store;
  AuroraAudioHandler? _handler;
  late final Future<void> _ready;
  String? error;

  Future<void> _initialize() async {
    try {
      final handler = await AudioService.init(
        builder: AuroraAudioHandler.new,
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'aurora_playback',
          androidNotificationChannelName: 'Aurora playback',
          androidNotificationOngoing: true,
        ),
      ).timeout(const Duration(seconds: 15));
      _handler = handler;
      handler.player.playerStateStream.listen((_) => notifyListeners());
      handler.current.addListener(notifyListeners);
    } catch (_) {
      error = 'Playback service is unavailable.';
    }
    notifyListeners();
  }

  Stream<Duration> get position => _handler?.player.positionStream ?? const Stream.empty();
  Stream<Duration?> get duration => _handler?.player.durationStream ?? const Stream.empty();
  LocalTrack? get current => _handler?.current.value;
  bool get playing => _handler?.player.playing ?? false;
  bool get shuffle => _handler?.player.shuffleModeEnabled ?? false;
  LoopMode get loopMode => _handler?.player.loopMode ?? LoopMode.off;
  /// Queue the user's first tap until the audio service has finished starting.
  /// Previously these taps were discarded while the service initialized.
  Future<void> _whenReady(Future<void> Function(AuroraAudioHandler handler) action) async {
    await _ready;
    final handler = _handler;
    if (handler != null) await action(handler);
  }

  Future<void> play(List<LocalTrack> tracks, int index) => _whenReady((handler) => handler.playTracks(tracks, index));
  Future<void> playCatalog(List<CatalogTrack> tracks, int index) => _whenReady((handler) => handler.playCatalogTracks(tracks, index));
  Future<void> toggle() => _whenReady((handler) => playing ? handler.pause() : handler.play());
  Future<void> next() => _whenReady((handler) => handler.skipToNext());
  Future<void> previous() => _whenReady((handler) => handler.skipToPrevious());
  Future<void> seek(Duration value) => _whenReady((handler) => handler.seek(value));
  Future<void> toggleShuffle() => _whenReady((handler) => handler.setShuffleMode(!shuffle ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none));
  Future<void> cycleRepeat() => _whenReady((handler) => handler.setRepeatMode(loopMode == LoopMode.off ? AudioServiceRepeatMode.all : loopMode == LoopMode.all ? AudioServiceRepeatMode.one : AudioServiceRepeatMode.none));
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
