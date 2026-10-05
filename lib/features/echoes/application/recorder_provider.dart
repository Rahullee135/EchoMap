import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../services/audio_recorder_service.dart';
import 'echo_providers.dart';

enum RecorderPhase { idle, recording, recorded, denied }

class RecorderState {
  const RecorderState({
    this.phase = RecorderPhase.idle,
    this.elapsed = Duration.zero,
    this.levels = const [],
    this.draftId,
  });

  final RecorderPhase phase;
  final Duration elapsed;
  final List<double> levels;
  final String? draftId;

  double get progress =>
      elapsed.inMilliseconds / AppConstants.maxEchoDuration.inMilliseconds;

  RecorderState copyWith({
    RecorderPhase? phase,
    Duration? elapsed,
    List<double>? levels,
    String? draftId,
  }) =>
      RecorderState(
        phase: phase ?? this.phase,
        elapsed: elapsed ?? this.elapsed,
        levels: levels ?? this.levels,
        draftId: draftId ?? this.draftId,
      );
}

final recorderProvider =
    NotifierProvider.autoDispose<RecorderNotifier, RecorderState>(
  RecorderNotifier.new,
);

/// Drives the record sheet. Auto-disposes with the sheet and discards any
/// unsaved draft audio.
class RecorderNotifier extends Notifier<RecorderState> {
  final _recorder = AudioRecorderService();
  final _stopwatch = Stopwatch();
  Timer? _ticker;
  StreamSubscription<double>? _levelSub;
  bool _saved = false;

  @override
  RecorderState build() {
    ref.onDispose(() {
      _ticker?.cancel();
      _levelSub?.cancel();
      final id = state.draftId;
      _recorder.dispose();
      if (!_saved && id != null) _deleteDraft(id);
    });
    return const RecorderState();
  }

  String? get draftPath {
    final id = state.draftId;
    return id == null ? null : ref.read(echoRepositoryProvider).audioPathFor(id);
  }

  Future<void> start() async {
    if (!await _recorder.ensurePermission()) {
      state = state.copyWith(phase: RecorderPhase.denied);
      return;
    }
    final previous = state.draftId;
    if (previous != null) _deleteDraft(previous);

    final id = const Uuid().v4();
    final path = ref.read(echoRepositoryProvider).audioPathFor(id);
    await _recorder.start(path);

    _stopwatch
      ..reset()
      ..start();
    state = RecorderState(phase: RecorderPhase.recording, draftId: id);

    _levelSub = _recorder.levels(const Duration(milliseconds: 80)).listen((l) {
      state = state.copyWith(levels: [...state.levels, l]);
    });
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final elapsed = _stopwatch.elapsed;
      if (elapsed >= AppConstants.maxEchoDuration) {
        stop();
      } else {
        state = state.copyWith(elapsed: elapsed);
      }
    });
  }

  Future<void> stop() async {
    if (state.phase != RecorderPhase.recording) return;
    _ticker?.cancel();
    await _levelSub?.cancel();
    _stopwatch.stop();
    final elapsed = _stopwatch.elapsed > AppConstants.maxEchoDuration
        ? AppConstants.maxEchoDuration
        : _stopwatch.elapsed;
    await _recorder.stop();
    state = state.copyWith(phase: RecorderPhase.recorded, elapsed: elapsed);
  }

  void discard() {
    final id = state.draftId;
    if (id != null) _deleteDraft(id);
    state = const RecorderState();
  }

  /// Marks the draft as kept so disposing the sheet does not delete it.
  void markSaved() => _saved = true;

  void _deleteDraft(String id) {
    final file = File(ref.read(echoRepositoryProvider).audioPathFor(id));
    if (file.existsSync()) file.deleteSync();
  }
}
