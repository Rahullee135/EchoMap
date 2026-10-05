import 'dart:async';

import 'package:record/record.dart';

class AudioRecorderService {
  AudioRecorderService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;

  Future<bool> ensurePermission() => _recorder.hasPermission();

  Future<void> start(String path) => _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 96000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: path,
      );

  Future<String?> stop() => _recorder.stop();

  Future<void> cancel() => _recorder.cancel();

  /// Normalised 0‥1 input level, roughly every [interval].
  Stream<double> levels(Duration interval) =>
      _recorder.onAmplitudeChanged(interval).map(
            (amp) => ((amp.current + 50) / 50).clamp(0.0, 1.0),
          );

  Future<void> dispose() => _recorder.dispose();
}
