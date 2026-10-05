import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/waveform_bars.dart';
import '../../application/echo_providers.dart';
import '../../application/location_provider.dart';
import '../../application/recorder_provider.dart';
import '../../domain/echo.dart';
import '../../domain/echo_category.dart';

Future<void> showRecordSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const RecordSheet(),
  );
}

class RecordSheet extends ConsumerStatefulWidget {
  const RecordSheet({super.key});

  @override
  ConsumerState<RecordSheet> createState() => _RecordSheetState();
}

class _RecordSheetState extends ConsumerState<RecordSheet> {
  final _title = TextEditingController();
  final _preview = AudioPlayer();
  EchoCategory _category = EchoCategory.story;
  bool _previewing = false;
  StreamSubscription<PlayerState>? _previewSub;

  @override
  void initState() {
    super.initState();
    _previewSub = _preview.playerStateStream.listen((s) {
      if (s.processingState == ProcessingState.completed) {
        _preview.pause();
        _preview.seek(Duration.zero);
      }
      if (mounted) setState(() => _previewing = s.playing);
    });
  }

  @override
  void dispose() {
    _previewSub?.cancel();
    _preview.dispose();
    _title.dispose();
    super.dispose();
  }

  Future<void> _togglePreview() async {
    final path = ref.read(recorderProvider.notifier).draftPath;
    if (path == null) return;
    if (_previewing) {
      await _preview.pause();
      return;
    }
    await _preview.setFilePath(path);
    unawaited(_preview.play());
  }

  void _save() {
    final position = ref.read(userPositionProvider).value;
    final recorder = ref.read(recorderProvider);
    final notifier = ref.read(recorderProvider.notifier);
    final path = notifier.draftPath;
    if (position == null || path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waiting for your location…')),
      );
      return;
    }
    final title = _title.text.trim();
    ref.read(echoesProvider.notifier).add(
          Echo(
            id: recorder.draftId ?? const Uuid().v4(),
            title: title.isEmpty ? '${_category.label} echo' : title,
            category: _category,
            audioPath: path,
            latitude: position.latitude,
            longitude: position.longitude,
            durationMs: recorder.elapsed.inMilliseconds,
            createdAt: DateTime.now(),
          ),
        );
    notifier.markSaved();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final rec = ref.watch(recorderProvider);
    final notifier = ref.read(recorderProvider.notifier);
    final colors = context.colors;
    final recording = rec.phase == RecorderPhase.recording;
    final recorded = rec.phase == RecorderPhase.recorded;
    final gotPosition = ref.watch(userPositionProvider).hasValue;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(32),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text('Drop an Echo', style: context.text.titleLarge),
              const SizedBox(height: 4),
              Text(
                gotPosition
                    ? 'Pinned to exactly where you stand'
                    : 'Finding your location…',
                style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 24),
              _RecordButton(
                phase: rec.phase,
                progress: rec.progress,
                onPressed: () {
                  if (recording) {
                    notifier.stop();
                  } else {
                    notifier.start();
                  }
                },
              ),
              const SizedBox(height: 12),
              Text(
                '${formatDuration(rec.elapsed)} / '
                '${formatDuration(AppConstants.maxEchoDuration)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 12),
              if (rec.phase == RecorderPhase.denied)
                Text(
                  'Microphone access is needed to record. Enable it in settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.error),
                )
              else
                WaveformBars(levels: rec.levels, color: colors.primary),
              const SizedBox(height: 20),
              if (recorded) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final c in EchoCategory.values)
                      ChoiceChip(
                        selected: _category == c,
                        onSelected: (_) => setState(() => _category = c),
                        avatar: Icon(c.icon, size: 18, color: c.color),
                        label: Text(c.label),
                        showCheckmark: false,
                        side: BorderSide(
                          color: _category == c
                              ? c.color
                              : colors.onSurface.withValues(alpha: 0.12),
                        ),
                        selectedColor: c.color.withValues(alpha: 0.2),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 48,
                  decoration: const InputDecoration(
                    hintText: 'Give it a title (optional)',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: notifier.discard,
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: 'Re-record',
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: _togglePreview,
                      icon: Icon(
                        _previewing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      tooltip: 'Preview',
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        expanded: true,
                        icon: Icons.push_pin_rounded,
                        label: 'Pin echo here',
                        onPressed: gotPosition ? _save : null,
                      ),
                    ),
                  ],
                ),
              ] else
                Text(
                  recording
                      ? 'Tap to stop'
                      : 'Tap the mic and tell people something about this place.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordButton extends StatelessWidget {
  const _RecordButton({
    required this.phase,
    required this.progress,
    required this.onPressed,
  });

  final RecorderPhase phase;
  final double progress;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final recording = phase == RecorderPhase.recording;
    final recorded = phase == RecorderPhase.recorded;
    return GestureDetector(
      onTap: recorded ? null : onPressed,
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: recording || recorded ? progress.clamp(0.0, 1.0) : 0,
                strokeWidth: 5,
                strokeCap: StrokeCap.round,
                color: context.colors.primary,
                backgroundColor:
                    context.colors.onSurface.withValues(alpha: 0.1),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: recording ? 72 : 92,
              height: recording ? 72 : 92,
              decoration: BoxDecoration(
                gradient: context.accentGradient,
                borderRadius: BorderRadius.circular(recording ? 22 : 46),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.5),
                    blurRadius: 28,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                recorded
                    ? Icons.check_rounded
                    : recording
                        ? Icons.stop_rounded
                        : Icons.mic_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
