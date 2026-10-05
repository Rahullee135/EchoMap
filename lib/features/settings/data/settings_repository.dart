import '../../../core/storage/local_store.dart';
import '../domain/app_settings.dart';

class SettingsRepository {
  const SettingsRepository(this._store);

  static const _fileName = 'settings.json';
  final LocalStore _store;

  Future<AppSettings> load() async {
    final raw = await _store.readJson(_fileName);
    if (raw is Map<String, dynamic>) return AppSettings.fromJson(raw);
    return const AppSettings();
  }

  Future<void> save(AppSettings settings) =>
      _store.writeJson(_fileName, settings.toJson());
}
