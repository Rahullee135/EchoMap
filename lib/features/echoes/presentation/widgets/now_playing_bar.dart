import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../application/player_provider.dart';
import '../../application/ui_providers.dart';

/// Floating mini-player shown whenever an echo is loaded.
class NowPlayingBar extends ConsumerWidget {
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playerProvider);
    final echo = playback.echo;
    if (echo == null) return const SizedBox.shrink();

    final color = echo.category.color;
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      radius: 22,
      onTap: () => ref.read(mapFocusProvider.notifier).focus(echo.position),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(echo.category.icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      echo.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${formatDuration(playback.position)} / '
                      '${formatDuration(playback.duration)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                onPressed: () =>
                    ref.read(playerProvider.notifier).toggle(echo),
                style: IconButton.styleFrom(backgroundColor: color),
                icon: Icon(
                  playback.playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => ref.read(playerProvider.notifier).stop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: playback.progress,
              minHeight: 4,
              color: color,
              backgroundColor: color.withValues(alpha: 0.18),
            ),
          ),
        ],
      ),
    );
  }
}
