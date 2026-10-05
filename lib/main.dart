import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/storage/local_store.dart';
import 'features/echoes/application/echo_providers.dart';
import 'features/echoes/data/echo_repository.dart';
import 'features/settings/application/settings_provider.dart';
import 'features/settings/data/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  final store = await LocalStore.open();
  final settings = await SettingsRepository(store).load();
  final echoes = await EchoRepository(store).load();

  runApp(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        initialSettingsProvider.overrideWithValue(settings),
        initialEchoesProvider.overrideWithValue(echoes),
      ],
      child: const EchoMapApp(),
    ),
  );
}
