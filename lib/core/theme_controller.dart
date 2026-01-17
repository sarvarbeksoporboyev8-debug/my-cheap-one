import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _kKey = 'app_theme_mode';

  @override
  ThemeMode build() {
    // Default to system, then attempt to load stored preference.
    final mode = ThemeMode.system;
    // Async load after first build
    Future.microtask(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final str = prefs.getString(_kKey);
        if (str != null) {
          switch (str) {
            case 'light':
              state = ThemeMode.light;
              break;
            case 'dark':
              state = ThemeMode.dark;
              break;
            default:
              state = ThemeMode.system;
          }
        }
      } catch (e) {
        debugPrint('Theme load failed: $e');
      }
    });
    return mode;
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = switch (mode) { ThemeMode.light => 'light', ThemeMode.dark => 'dark', _ => 'system' };
      await prefs.setString(_kKey, str);
    } catch (e) {
      debugPrint('Theme save failed: $e');
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() => ThemeModeNotifier());
