import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:sellingapp/nav.dart';
import 'package:sellingapp/theme.dart';
import 'package:sellingapp/core/config/app_config.dart';
import 'package:sellingapp/core/theme_controller.dart';

class App extends rp.ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    // Force initialization of config/provider graph
    ref.read(appConfigProvider);
    final mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Open Food Marketplace',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: mode,
      routerConfig: AppRouter.router,
    );
  }
}
