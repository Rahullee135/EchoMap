import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_card.dart';
import '../application/discovery_provider.dart';
import '../application/echo_providers.dart';
import '../application/player_provider.dart';
import '../application/ui_providers.dart';
import '../domain/echo.dart';
import '../domain/echo_category.dart';
import 'widgets/echo_detail_sheet.dart';

class EchoesScreen extends ConsumerStatefulWidget {
  const EchoesScreen({super.key});

  @override
  ConsumerState<EchoesScreen> createState() => _EchoesScreenState();
}

class _EchoesScreenState extends ConsumerState<EchoesScreen> {
  EchoCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(echoesProvider);
    final echoes =
        _filter == null ? all : all.where((e) => e.category == _filter).toList();
    final distances = ref.watch(discoveryProvider).distances;
    final top = MediaQuery.of(context).padding.top;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, top + 16, 20, 240),
      children: [
        Text('Your Echoes', style: context.text.headlineMedium),
        const SizedBox(height: 4),
        Text(
          '${all.length} ${all.length == 1 ? 'memory' : 'memories'} pinned to the world',
          style: TextStyle(color: context.colors.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FilterChip(
                label: 'All',
                selected: _filter == null,
                onTap: () => setState(() => _filter = null),
              ),
              for (final c in EchoCategory.values)
                _FilterChip(
                  label: c.label,
                  color: c.color,
                  selected: _filter == c,
                  onTap: () => setState(() => _filter = c),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (echoes.isEmpty)
          const _EmptyState()
        else
          for (final echo in echoes)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _EchoTile(echo: echo, distance: distances[echo.id]),
            ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.colors.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? c.withValues(alpha: 0.22) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? c : context.colors.onSurface.withValues(alpha: 0.14),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? c : context.colors.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ),
      ),
    );
  }
}

class _EchoTile extends ConsumerWidget {
  const _EchoTile({required this.echo, required this.distance});

  final Echo echo;
  final double? distance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playerProvider);
    final playing = playback.echo?.id == echo.id && playback.playing;
    final color = echo.category.color;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      onTap: () => showEchoDetailSheet(context, echo),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(echo.category.icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  echo.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    formatDuration(echo.duration),
                    if (distance != null) formatDistance(distance!),
                    formatAgo(echo.createdAt),
                  ].join('  ·  '),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Show on map',
            onPressed: () {
              ref.read(homeTabProvider.notifier).select(0);
              ref.read(mapFocusProvider.notifier).focus(echo.position);
            },
            icon: const Icon(Icons.near_me_rounded),
          ),
          IconButton.filled(
            onPressed: () => ref.read(playerProvider.notifier).toggle(echo),
            style: IconButton.styleFrom(backgroundColor: color),
            icon: Icon(
              playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (r) => context.accentGradient.createShader(r),
            child: const Icon(Icons.mic_none_rounded,
                size: 72, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text('No echoes yet', style: context.text.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Tap “Drop Echo” to leave your first voice memory.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
