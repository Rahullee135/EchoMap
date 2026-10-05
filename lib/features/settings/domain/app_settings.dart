import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

/// Every style uses keyless OpenStreetMap tiles; the look comes from a colour
/// filter applied on top, so no tile-provider API key is ever required.
enum MapStyle {
  midnight('Midnight', Color(0xFF1B1B2B), _midnightMatrix),
  paper('Paper', Color(0xFFE9E8F0), _paperMatrix),
  vivid('Vivid', Color(0xFFCFE6F7), _vividMatrix),
  streets('Streets', Color(0xFFEFE9DC), null);

  const MapStyle(this.label, this.swatch, this.matrix);

  static const urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  final String label;
  final Color swatch;
  final List<double>? matrix;

  ColorFilter? get filter =>
      matrix == null ? null : ColorFilter.matrix(matrix!);

  static MapStyle fromName(String? name) =>
      values.firstWhere((s) => s.name == name, orElse: () => midnight);
}

// invert + hue-rotate(180°), dimmed: keeps water blue and parks green.
const _midnightMatrix = <double>[
  0.488, -1.216, -0.122, 0, 217, //
  -0.362, -0.366, -0.122, 0, 217,
  -0.362, -1.216, 0.728, 0, 217,
  0, 0, 0, 1, 0,
];

const _paperMatrix = <double>[
  0.33, 0.55, 0.12, 0, 12, //
  0.33, 0.55, 0.12, 0, 10,
  0.33, 0.55, 0.12, 0, 8,
  0, 0, 0, 1, 0,
];

const _vividMatrix = <double>[
  1.35, -0.25, -0.1, 0, 0, //
  -0.15, 1.3, -0.15, 0, 0,
  -0.1, -0.25, 1.35, 0, 0,
  0, 0, 0, 1, 0,
];

class AppSettings {
  const AppSettings({
    this.accentIndex = 0,
    this.themeMode = ThemeMode.dark,
    this.mapStyle = MapStyle.midnight,
    this.triggerRadius = AppConstants.defaultTriggerRadius,
    this.autoPlay = true,
    this.haptics = true,
  });

  final int accentIndex;
  final ThemeMode themeMode;
  final MapStyle mapStyle;
  final double triggerRadius;
  final bool autoPlay;
  final bool haptics;

  AppSettings copyWith({
    int? accentIndex,
    ThemeMode? themeMode,
    MapStyle? mapStyle,
    double? triggerRadius,
    bool? autoPlay,
    bool? haptics,
  }) =>
      AppSettings(
        accentIndex: accentIndex ?? this.accentIndex,
        themeMode: themeMode ?? this.themeMode,
        mapStyle: mapStyle ?? this.mapStyle,
        triggerRadius: triggerRadius ?? this.triggerRadius,
        autoPlay: autoPlay ?? this.autoPlay,
        haptics: haptics ?? this.haptics,
      );

  Map<String, Object?> toJson() => {
        'accentIndex': accentIndex,
        'themeMode': themeMode.name,
        'mapStyle': mapStyle.name,
        'triggerRadius': triggerRadius,
        'autoPlay': autoPlay,
        'haptics': haptics,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    const defaults = AppSettings();
    return AppSettings(
      accentIndex: json['accentIndex'] as int? ?? defaults.accentIndex,
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == json['themeMode'],
        orElse: () => defaults.themeMode,
      ),
      mapStyle: MapStyle.fromName(json['mapStyle'] as String?),
      triggerRadius:
          (json['triggerRadius'] as num?)?.toDouble() ?? defaults.triggerRadius,
      autoPlay: json['autoPlay'] as bool? ?? defaults.autoPlay,
      haptics: json['haptics'] as bool? ?? defaults.haptics,
    );
  }
}
