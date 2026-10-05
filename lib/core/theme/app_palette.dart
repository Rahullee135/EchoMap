import 'package:flutter/material.dart';

/// A user-selectable accent: two colours that drive every gradient in the app.
class AccentPalette {
  const AccentPalette(this.name, this.primary, this.secondary);

  final String name;
  final Color primary;
  final Color secondary;
}

const accentPalettes = <AccentPalette>[
  AccentPalette('Aurora', Color(0xFF8B5CF6), Color(0xFF22D3EE)),
  AccentPalette('Sunset', Color(0xFFFF6B6B), Color(0xFFFFB347)),
  AccentPalette('Lagoon', Color(0xFF0EA5E9), Color(0xFF34D399)),
  AccentPalette('Bloom', Color(0xFFEC4899), Color(0xFFA78BFA)),
  AccentPalette('Citrus', Color(0xFFF59E0B), Color(0xFF84CC16)),
  AccentPalette('Ember', Color(0xFFEF4444), Color(0xFFF97316)),
];
