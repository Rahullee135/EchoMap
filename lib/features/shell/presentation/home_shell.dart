import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../echoes/application/ui_providers.dart';
import '../../echoes/presentation/echoes_screen.dart';
import '../../echoes/presentation/map_screen.dart';
import '../../echoes/presentation/widgets/now_playing_bar.dart';
import '../../echoes/presentation/widgets/record_sheet.dart';
import '../../settings/presentation/settings_screen.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static const _tabs = [
    (Icons.map_rounded, 'Map'),
    (Icons.graphic_eq_rounded, 'Echoes'),
    (Icons.tune_rounded, 'Style'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(homeTabProvider);
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: tab,
            children: const [MapScreen(), EchoesScreen(), SettingsScreen()],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: bottom + 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const NowPlayingBar(),
                if (tab != 2) ...[
                  const SizedBox(height: 12),
                  GradientButton(
                    label: 'Drop Echo',
                    icon: Icons.mic_rounded,
                    onPressed: () => showRecordSheet(context),
                  ),
                ],
                const SizedBox(height: 12),
                GlassCard(
                  radius: 28,
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    children: [
                      for (var i = 0; i < _tabs.length; i++)
                        Expanded(
                          child: _NavItem(
                            icon: _tabs[i].$1,
                            label: _tabs[i].$2,
                            selected: tab == i,
                            onTap: () =>
                                ref.read(homeTabProvider.notifier).select(i),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: selected ? context.accentGradient : null,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected
                  ? Colors.white
                  : context.colors.onSurface.withValues(alpha: 0.6),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
