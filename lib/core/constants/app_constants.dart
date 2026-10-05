class AppConstants {
  const AppConstants._();

  static const appName = 'EchoMap';
  static const bundleId = 'com.echomap.echomap';

  /// Maximum length of a single echo.
  static const maxEchoDuration = Duration(seconds: 30);

  static const minTriggerRadius = 25.0;
  static const maxTriggerRadius = 200.0;
  static const defaultTriggerRadius = 60.0;

  /// An echo re-arms once the listener walks this many times the trigger
  /// radius away, so it does not replay while you stand at its edge.
  static const rearmFactor = 1.6;
}
