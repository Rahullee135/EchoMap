import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../services/location_service.dart';
import '../../settings/application/settings_provider.dart';
import '../../settings/domain/app_settings.dart';
import '../application/discovery_provider.dart';
import '../application/echo_providers.dart';
import '../application/location_provider.dart';
import '../application/player_provider.dart';
import '../application/ui_providers.dart';
import 'widgets/echo_detail_sheet.dart';
import 'widgets/echo_marker.dart';
import 'widgets/user_marker.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  static const _fallbackCenter = LatLng(51.5074, -0.1278);

  final _controller = MapController();
  bool _ready = false;
  bool _centeredOnUser = false;

  void _moveTo(LatLng point, {double zoom = 17}) {
    if (!_ready) return;
    _controller.move(point, zoom);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final position = ref.watch(userPositionProvider);
    final echoes = ref.watch(echoesProvider);
    final discovery = ref.watch(discoveryProvider);
    final playingId = ref.watch(playerProvider.select(
      (p) => p.playing ? p.echo?.id : null,
    ));
    final user = position.value?.latLng;

    ref.listen(userPositionProvider, (_, next) {
      final p = next.value;
      if (p != null && !_centeredOnUser && _ready) {
        _centeredOnUser = true;
        _moveTo(p.latLng);
      }
    });
    ref.listen(mapFocusProvider, (_, point) {
      if (point == null) return;
      _moveTo(point, zoom: 18);
      ref.read(mapFocusProvider.notifier).clear();
    });

    final dark = settings.mapStyle == MapStyle.midnight;
    final top = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: user ?? _fallbackCenter,
            initialZoom: user == null ? 12 : 17,
            minZoom: 3,
            maxZoom: 19,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onMapReady: () {
              _ready = true;
              final p = ref.read(userPositionProvider).value;
              if (p != null && !_centeredOnUser) {
                _centeredOnUser = true;
                _moveTo(p.latLng);
              }
            },
          ),
          children: [
            _Tiles(style: settings.mapStyle),
            if (user != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: user,
                    radius: settings.triggerRadius,
                    useRadiusInMeter: true,
                    color: context.colors.primary.withValues(alpha: 0.12),
                    borderColor: context.colors.primary.withValues(alpha: 0.7),
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                for (final echo in echoes)
                  Marker(
                    point: echo.position,
                    width: 76,
                    height: 76,
                    child: EchoMarker(
                      echo: echo,
                      playing: playingId == echo.id,
                      inRange: discovery.nearby
                          .any((n) => n.echo.id == echo.id),
                      onTap: () => showEchoDetailSheet(context, echo),
                    ),
                  ),
                if (user != null)
                  Marker(
                    point: user,
                    width: 76,
                    height: 76,
                    child: const UserMarker(),
                  ),
              ],
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 210),
                child: Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(
                    fontSize: 9,
                    color: (dark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: top + 12,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatusCard(
                position: position,
                nearby: discovery.nearby.length,
                total: echoes.length,
              ),
              if (position.hasError) ...[
                const SizedBox(height: 10),
                _PermissionBanner(error: position.error!),
              ],
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 230,
          child: Column(
            children: [
              _RoundButton(
                icon: Icons.layers_rounded,
                onTap: () {
                  final styles = MapStyle.values;
                  final next =
                      styles[(settings.mapStyle.index + 1) % styles.length];
                  ref.read(settingsProvider.notifier).setMapStyle(next);
                },
              ),
              const SizedBox(height: 10),
              _RoundButton(
                icon: Icons.my_location_rounded,
                onTap: () {
                  if (user != null) _moveTo(user);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tiles extends StatelessWidget {
  const _Tiles({required this.style});

  final MapStyle style;

  @override
  Widget build(BuildContext context) {
    final layer = TileLayer(
      urlTemplate: MapStyle.urlTemplate,
      userAgentPackageName: AppConstants.bundleId,
      retinaMode: RetinaMode.isHighDensity(context),
    );
    final filter = style.filter;
    return filter == null ? layer : ColorFiltered(colorFilter: filter, child: layer);
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.position,
    required this.nearby,
    required this.total,
  });

  final AsyncValue<Object?> position;
  final int nearby;
  final int total;

  @override
  Widget build(BuildContext context) {
    final listening = position.hasValue;
    final subtitle = !listening
        ? (position.hasError ? 'Location unavailable' : 'Finding you…')
        : nearby > 0
            ? '$nearby ${nearby == 1 ? 'echo' : 'echoes'} in range'
            : total == 0
                ? 'Drop your first echo'
                : 'Walk around to discover echoes';
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      radius: 22,
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (r) => context.accentGradient.createShader(r),
            child: const Icon(Icons.graphic_eq_rounded,
                size: 30, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: context.colors.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: listening ? const Color(0xFF34D399) : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionBanner extends ConsumerWidget {
  const _PermissionBanner({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issue = error is LocationException
        ? (error as LocationException).issue
        : null;
    final service = ref.read(locationServiceProvider);
    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              error is LocationException
                  ? (error as LocationException).message
                  : 'Could not read your location.',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () {
              switch (issue) {
                case LocationIssue.deniedForever:
                  service.openSettings();
                case LocationIssue.serviceDisabled:
                  service.openLocationSettings();
                default:
                  ref.invalidate(userPositionProvider);
              }
            },
            child: Text(
              issue == LocationIssue.deniedForever ||
                      issue == LocationIssue.serviceDisabled
                  ? 'Settings'
                  : 'Allow',
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Icon(icon, size: 22),
    );
  }
}
