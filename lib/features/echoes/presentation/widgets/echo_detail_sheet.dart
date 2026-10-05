import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../application/discovery_provider.dart';
import '../../application/echo_providers.dart';
import '../../application/player_provider.dart';
import '../../domain/echo.dart';

Future<void> showEchoDetailSheet(BuildContext context, Echo echo) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => EchoDetailSheet(echoId: echo.id),
  );
}

class EchoDetailSheet extends ConsumerWidget {
  const EchoDetailSheet({super.key, required this.echoId});

  final String echoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final echo = ref
        .watch(echoesProvider)
        .where((e) => e.id == echoId)
        .cast<Echo?>()
        .firstOrNull;
    if (echo == null) return const SizedBox.shrink();

    final playback = ref.watch(playerProvider);
    final isCurrent = playback.echo?.id == echo.id;
    final playing = isCurrent && playback.playing;
    final distance = ref.watch(discoveryProvider).distances[echo.id];
    final color = echo.category.color;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(32),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.18),
              ),
              child: Icon(echo.category.icon, color: color, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              echo.title,
              textAlign: TextAlign.center,
              style: context.text.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              [
                echo.category.label,
                if (distance != null) formatDistance(distance),
                formatAgo(echo.createdAt),
                '${echo.plays} plays',
              ].join('  ·  '),
              style: TextStyle(
                color: context.colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 22),
            Slider(
              value: isCurrent ? playback.progress : 0,
              onChanged: isCurrent
                  ? (v) => ref.read(playerProvider.notifier).seekFraction(v)
                  : null,
              activeColor: color,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatDuration(isCurrent ? playback.position : Duration.zero)),
                  Text(formatDuration(echo.duration)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final player = ref.read(playerProvider.notifier);
                    final isThis = ref.read(playerProvider).echo?.id == echo.id;
                    if (isThis) await player.stop();
                    await ref.read(echoesProvider.notifier).remove(echo);
                    navigator.pop();
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientButton(
                    expanded: true,
                    icon: playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    label: playing ? 'Pause' : 'Play echo',
                    onPressed: () =>
                        ref.read(playerProvider.notifier).toggle(echo),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
