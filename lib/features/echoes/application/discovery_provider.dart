import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/constants/app_constants.dart';
import '../../settings/application/settings_provider.dart';
import '../domain/echo.dart';
import 'echo_providers.dart';
import 'location_provider.dart';
import 'player_provider.dart';

class NearbyEcho {
  const NearbyEcho(this.echo, this.distance);

  final Echo echo;
  final double distance;
}

class DiscoveryState {
  const DiscoveryState({this.nearby = const [], this.distances = const {}});

  /// Echoes inside the trigger radius, closest first.
  final List<NearbyEcho> nearby;

  /// Distance in metres to every echo, keyed by echo id.
  final Map<String, double> distances;
}

final discoveryProvider =
    NotifierProvider<DiscoveryNotifier, DiscoveryState>(DiscoveryNotifier.new);

/// Watches the user position and plays echoes as they come into range.
class DiscoveryNotifier extends Notifier<DiscoveryState> {
  final Set<String> _triggered = {};
  Position? _last;

  @override
  DiscoveryState build() {
    ref.listen(userPositionProvider, (_, next) {
      next.whenData((p) {
        _last = p;
        _recompute();
      });
    }, fireImmediately: true);
    ref.listen(echoesProvider, (_, _) => _recompute());
    ref.listen(settingsProvider, (_, _) => _recompute());
    return const DiscoveryState();
  }

  void _recompute() {
    final position = _last;
    if (position == null) return;

    final settings = ref.read(settingsProvider);
    final echoes = ref.read(echoesProvider);
    final radius = settings.triggerRadius;

    final distances = <String, double>{};
    final nearby = <NearbyEcho>[];
    for (final echo in echoes) {
      final d = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        echo.latitude,
        echo.longitude,
      );
      distances[echo.id] = d;
      if (d <= radius) nearby.add(NearbyEcho(echo, d));
      if (d > radius * AppConstants.rearmFactor) _triggered.remove(echo.id);
    }
    nearby.sort((a, b) => a.distance.compareTo(b.distance));
    state = DiscoveryState(nearby: nearby, distances: distances);

    if (!settings.autoPlay || ref.read(playerProvider).playing) return;
    for (final item in nearby) {
      if (_triggered.add(item.echo.id)) {
        if (settings.haptics) HapticFeedback.mediumImpact();
        ref.read(playerProvider.notifier).play(item.echo);
        break;
      }
    }
  }
}
