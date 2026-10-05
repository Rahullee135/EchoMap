import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/settings_provider.dart';
import '../data/echo_repository.dart';
import '../domain/echo.dart';

final initialEchoesProvider = Provider<List<Echo>>(
  (ref) => throw UnimplementedError('initialEchoesProvider not overridden'),
);

final echoRepositoryProvider = Provider<EchoRepository>(
  (ref) => EchoRepository(ref.watch(localStoreProvider)),
);

final echoesProvider =
    NotifierProvider<EchoesNotifier, List<Echo>>(EchoesNotifier.new);

class EchoesNotifier extends Notifier<List<Echo>> {
  EchoRepository get _repo => ref.read(echoRepositoryProvider);

  @override
  List<Echo> build() => ref.read(initialEchoesProvider);

  void _commit(List<Echo> next) {
    state = next;
    _repo.save(next);
  }

  void add(Echo echo) => _commit([echo, ...state]);

  Future<void> remove(Echo echo) async {
    _commit([
      for (final e in state)
        if (e.id != echo.id) e,
    ]);
    await _repo.deleteAudio(echo);
  }

  void recordPlay(String id) => _commit([
        for (final e in state) e.id == id ? e.copyWith(plays: e.plays + 1) : e,
      ]);
}
