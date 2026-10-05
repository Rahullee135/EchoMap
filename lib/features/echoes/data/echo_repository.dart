import 'dart:io';

import '../../../core/storage/local_store.dart';
import '../domain/echo.dart';

class EchoRepository {
  const EchoRepository(this._store);

  static const _fileName = 'echoes.json';
  final LocalStore _store;

  Future<List<Echo>> load() async {
    final raw = await _store.readJson(_fileName);
    if (raw is! List) return [];
    return [
      for (final item in raw)
        if (item is Map<String, dynamic>) Echo.fromJson(item),
    ];
  }

  Future<void> save(List<Echo> echoes) =>
      _store.writeJson(_fileName, [for (final e in echoes) e.toJson()]);

  Future<void> deleteAudio(Echo echo) async {
    final file = File(echo.audioPath);
    if (file.existsSync()) await file.delete();
  }

  String audioPathFor(String id) => _store.audioPathFor(id);
}
