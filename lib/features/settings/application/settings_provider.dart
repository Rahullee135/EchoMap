import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_store.dart';
import '../data/settings_repository.dart';
import '../domain/app_settings.dart';

/// Overridden in `main()` once the store has been opened.
final localStoreProvider = Provider<LocalStore>(
  (ref) => throw UnimplementedError('localStoreProvider not overridden'),
);

final initialSettingsProvider = Provider<AppSettings>(
  (ref) => throw UnimplementedError('initialSettingsProvider not overridden'),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(localStoreProvider)),
);

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(initialSettingsProvider);

  void _set(AppSettings next) {
    state = next;
    ref.read(settingsRepositoryProvider).save(next);
  }

  void setAccent(int index) => _set(state.copyWith(accentIndex: index));
  void setThemeMode(ThemeMode mode) => _set(state.copyWith(themeMode: mode));
  void setMapStyle(MapStyle style) => _set(state.copyWith(mapStyle: style));
  void setTriggerRadius(double meters) =>
      _set(state.copyWith(triggerRadius: meters));
  void setAutoPlay(bool value) => _set(state.copyWith(autoPlay: value));
  void setHaptics(bool value) => _set(state.copyWith(haptics: value));
}
