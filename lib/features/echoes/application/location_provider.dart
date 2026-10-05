import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../services/location_service.dart';

final locationServiceProvider =
    Provider<LocationService>((ref) => const LocationService());

/// Live user position. Errors with [LocationException] when permission or
/// services are unavailable; `ref.invalidate` retries.
final userPositionProvider = StreamProvider<Position>((ref) async* {
  final service = ref.watch(locationServiceProvider);
  await service.ensurePermission();
  yield await service.currentPosition();
  yield* service.positionStream();
});

extension PositionX on Position {
  LatLng get latLng => LatLng(latitude, longitude);
}
