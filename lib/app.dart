import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_palette.dart';
import 'core/theme/app_theme.dart';
import 'features/echoes/application/discovery_provider.dart';
import 'features/settings/application/settings_provider.dart';
import 'features/shell/presentation/home_shell.dart';

class EchoMapApp extends ConsumerWidget {
  const EchoMapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    // Keep the proximity engine alive for the whole app lifetime.
    ref.watch(discoveryProvider);

    final palette = accentPalettes[settings.accentIndex % accentPalettes.length];
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: AppTheme.build(palette, Brightness.light),
      darkTheme: AppTheme.build(palette, Brightness.dark),
      home: const HomeShell(),
    );
  }
}
