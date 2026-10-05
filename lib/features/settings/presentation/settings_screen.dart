import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_card.dart';
import '../../echoes/application/echo_providers.dart';
import '../application/settings_provider.dart';
import '../domain/app_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final echoCount = ref.watch(echoesProvider).length;
    final top = MediaQuery.of(context).padding.top;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, top + 16, 20, 200),
      children: [
        Text('Make it yours', style: context.text.headlineMedium),
        const SizedBox(height: 20),
        _Section(
          title: 'Appearance',
          children: [
            SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_rounded),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_rounded),
                  label: Text('Dark'),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_rounded),
                  label: Text('Auto'),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) => notifier.setThemeMode(s.first),
            ),
            const SizedBox(height: 20),
            const _Label('Accent colour'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (var i = 0; i < accentPalettes.length; i++)
                  _AccentSwatch(
                    palette: accentPalettes[i],
                    selected: settings.accentIndex == i,
                    onTap: () => notifier.setAccent(i),
                  ),
              ],
            ),
          ],
        ),
        _Section(
          title: 'Map',
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final style in MapStyle.values)
                  _MapStyleChip(
                    style: style,
                    selected: settings.mapStyle == style,
                    onTap: () => notifier.setMapStyle(style),
                  ),
              ],
            ),
          ],
        ),
        _Section(
          title: 'Discovery',
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _Label('Trigger radius'),
                Text(
                  formatDistance(settings.triggerRadius),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: settings.triggerRadius,
              min: AppConstants.minTriggerRadius,
              max: AppConstants.maxTriggerRadius,
              divisions: 7,
              onChanged: notifier.setTriggerRadius,
            ),
            _SwitchRow(
              title: 'Auto-play nearby echoes',
              subtitle: 'Plays through your earbuds as you walk by',
              value: settings.autoPlay,
              onChanged: notifier.setAutoPlay,
            ),
            _SwitchRow(
              title: 'Haptic nudge',
              subtitle: 'Gentle buzz when an echo starts',
              value: settings.haptics,
              onChanged: notifier.setHaptics,
            ),
          ],
        ),
        _Section(
          title: 'About',
          children: [
            Text(
              '$echoCount ${echoCount == 1 ? 'echo' : 'echoes'} stored on this device.\n'
              'Recordings never leave your phone.\n\n'
              'Map data © OpenStreetMap contributors.',
              style: TextStyle(
                height: 1.5,
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: context.colors.primary,
                )),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.w600));
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final AccentPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [palette.primary, palette.secondary],
              ),
              border: Border.all(
                color: selected ? context.colors.onSurface : Colors.transparent,
                width: 3,
              ),
            ),
            child: selected
                ? const Icon(Icons.check_rounded, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 6),
          Text(palette.name, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _MapStyleChip extends StatelessWidget {
  const _MapStyleChip({
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final MapStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lightSwatch = style.swatch.computeLuminance() > 0.4;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: style.swatch,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? context.colors.primary : Colors.transparent,
            width: 3,
          ),
        ),
        child: Text(
          style.label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: lightSwatch ? Colors.black87 : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label(title),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.5,
                  color: context.colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
