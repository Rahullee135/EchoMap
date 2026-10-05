import 'package:echomap/features/echoes/domain/echo.dart';
import 'package:echomap/features/echoes/domain/echo_category.dart';
import 'package:echomap/features/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Echo survives a JSON round trip', () {
    final echo = Echo(
      id: 'abc',
      title: 'Best chai',
      category: EchoCategory.food,
      audioPath: '/tmp/abc.m4a',
      latitude: 12.97,
      longitude: 77.59,
      durationMs: 21000,
      createdAt: DateTime.utc(2026, 10, 5),
      plays: 3,
    );
    final copy = Echo.fromJson(echo.toJson());
    expect(copy.title, 'Best chai');
    expect(copy.category, EchoCategory.food);
    expect(copy.position.latitude, 12.97);
    expect(copy.plays, 3);
  });

  test('AppSettings falls back to defaults for missing keys', () {
    final s = AppSettings.fromJson({'themeMode': 'light', 'triggerRadius': 90});
    expect(s.themeMode, ThemeMode.light);
    expect(s.triggerRadius, 90);
    expect(s.autoPlay, isTrue);
    expect(s.mapStyle, MapStyle.midnight);
  });
}
