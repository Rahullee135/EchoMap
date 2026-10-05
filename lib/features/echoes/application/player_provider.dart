import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../domain/echo.dart';
import 'echo_providers.dart';

class PlaybackState {
  const PlaybackState({
    this.echo,
    this.playing = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  final Echo? echo;
  final bool playing;
  final Duration position;
  final Duration duration;

  double get progress => duration.inMilliseconds == 0
      ? 0
      : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

  PlaybackState copyWith({
    Echo? echo,
    bool? playing,
    Duration? position,
    Duration? duration,
  }) =>
      PlaybackState(
        echo: echo ?? this.echo,
        playing: playing ?? this.playing,
        position: position ?? this.position,
        duration: duration ?? this.duration,
      );
}

final playerProvider =
    NotifierProvider<PlayerNotifier, PlaybackState>(PlayerNotifier.new);

class PlayerNotifier extends Notifier<PlaybackState> {
  final AudioPlayer _player = AudioPlayer();

  @override
  PlaybackState build() {
    final subs = <StreamSubscription<Object?>>[
      _player.positionStream.listen((p) {
        state = state.copyWith(position: p);
      }),
      _player.durationStream.listen((d) {
        if (d != null) state = state.copyWith(duration: d);
      }),
      _player.playerStateStream.listen((s) {
        if (s.processingState == ProcessingState.completed) {
          _player.pause();
          _player.seek(Duration.zero);
          state = state.copyWith(playing: false, position: Duration.zero);
        } else {
          state = state.copyWith(playing: s.playing);
        }
      }),
    ];
    ref.onDispose(() {
      for (final s in subs) {
        s.cancel();
      }
      _player.dispose();
    });
    return const PlaybackState();
  }

  /// Starts [echo] from the beginning, or toggles pause when it is current.
  Future<void> toggle(Echo echo) async {
    if (state.echo?.id == echo.id) {
      state.playing ? await _player.pause() : _resume();
      return;
    }
    await play(echo);
  }

  Future<void> play(Echo echo) async {
    if (!File(echo.audioPath).existsSync()) return;
    state = PlaybackState(
      echo: echo,
      playing: false,
      duration: echo.duration,
    );
    try {
      await _player.setFilePath(echo.audioPath);
    } on PlayerException {
      return;
    }
    ref.read(echoesProvider.notifier).recordPlay(echo.id);
    _resume();
  }

  void _resume() {
    // `play()` resolves when playback ends, so it is intentionally not awaited.
    unawaited(_player.play());
  }

  Future<void> seekFraction(double fraction) => _player
      .seek(Duration(milliseconds: (state.duration.inMilliseconds * fraction).round()));

  Future<void> stop() async {
    await _player.stop();
    state = const PlaybackState();
  }
}
