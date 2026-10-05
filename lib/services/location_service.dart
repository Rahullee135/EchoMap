import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum LocationIssue { serviceDisabled, denied, deniedForever }

class LocationException implements Exception {
  const LocationException(this.issue);

  final LocationIssue issue;

  String get message => switch (issue) {
        LocationIssue.serviceDisabled =>
          'Location services are turned off. Turn them on to discover echoes.',
        LocationIssue.denied =>
          'EchoMap needs your location to pin and play echoes.',
        LocationIssue.deniedForever =>
          'Location access is blocked. Enable it in system settings.',
      };

  @override
  String toString() => message;
}

class LocationService {
  const LocationService();

  Future<void> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(LocationIssue.serviceDisabled);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    switch (permission) {
      case LocationPermission.denied:
        throw const LocationException(LocationIssue.denied);
      case LocationPermission.deniedForever:
        throw const LocationException(LocationIssue.deniedForever);
      default:
        break;
    }
  }

  Future<Position> currentPosition() => Geolocator.getCurrentPosition();

  /// Platform-tuned stream: Android runs a foreground service and iOS enables
  /// the background-location indicator so echoes keep triggering with the
  /// screen off.
  Stream<Position> positionStream() =>
      Geolocator.getPositionStream(locationSettings: _settings());

  Future<void> openSettings() => Geolocator.openAppSettings();
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  LocationSettings _settings() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
          intervalDuration: const Duration(seconds: 3),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: 'EchoMap is listening',
            notificationText: 'Echoes will play as you walk past them.',
            enableWakeLock: true,
            setOngoing: true,
          ),
        );
      case TargetPlatform.iOS:
        return AppleSettings(
          accuracy: LocationAccuracy.high,
          activityType: ActivityType.fitness,
          distanceFilter: 5,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: true,
          allowBackgroundLocationUpdates: true,
        );
      default:
        return const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        );
    }
  }
}
