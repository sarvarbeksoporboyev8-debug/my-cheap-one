import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'driver_settings.dart';

class DriverSettingsNotifier extends Notifier<DriverSettings> {
  static const _kKey = 'driver_settings';

  @override
  DriverSettings build() {
    // Load settings asynchronously after initial build
    Future.microtask(_loadSettings);
    return const DriverSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_kKey);
      if (jsonStr != null) {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        state = DriverSettings.fromJson(json);
      }
    } catch (e) {
      debugPrint('Failed to load driver settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(state.toJson());
      await prefs.setString(_kKey, jsonStr);
    } catch (e) {
      debugPrint('Failed to save driver settings: $e');
    }
  }

  // Availability & Jobs
  void setAutoGoOnline(bool value) {
    state = state.copyWith(autoGoOnline: value);
    _saveSettings();
  }

  void setAutoAccept(bool value) {
    state = state.copyWith(autoAccept: value);
    _saveSettings();
  }

  void setMaxPickupKm(double value) {
    state = state.copyWith(maxPickupKm: value.clamp(1.0, 50.0));
    _saveSettings();
  }

  void setMinFee(double value) {
    state = state.copyWith(minFee: value.clamp(0.0, 50.0));
    _saveSettings();
  }

  void setPreferredJobType(String value) {
    state = state.copyWith(preferredJobType: value);
    _saveSettings();
  }

  // Navigation & Maps
  void setNavApp(String value) {
    state = state.copyWith(navApp: value);
    _saveSettings();
  }

  void setVoiceNav(bool value) {
    state = state.copyWith(voiceNav: value);
    _saveSettings();
  }

  void setAvoidTolls(bool value) {
    state = state.copyWith(avoidTolls: value);
    _saveSettings();
  }

  void setUnits(String value) {
    state = state.copyWith(units: value);
    _saveSettings();
  }

  void setKeepScreenAwake(bool value) {
    state = state.copyWith(keepScreenAwake: value);
    _saveSettings();
  }

  // Notifications
  void setNotifRequests(bool value) {
    state = state.copyWith(notifRequests: value);
    _saveSettings();
  }

  void setNotifSound(bool value) {
    state = state.copyWith(notifSound: value);
    _saveSettings();
  }

  void setNotifVibration(bool value) {
    state = state.copyWith(notifVibration: value);
    _saveSettings();
  }

  void setNotifChat(bool value) {
    state = state.copyWith(notifChat: value);
    _saveSettings();
  }

  void setQuietHours(TimeOfDay? start, TimeOfDay? end) {
    if (start == null || end == null) {
      state = state.copyWith(quietStartMinutes: -1, quietEndMinutes: -1);
    } else {
      state = state.copyWith(
        quietStartMinutes: start.hour * 60 + start.minute,
        quietEndMinutes: end.hour * 60 + end.minute,
      );
    }
    _saveSettings();
  }

  void disableQuietHours() {
    state = state.copyWith(quietStartMinutes: -1, quietEndMinutes: -1);
    _saveSettings();
  }

  // Safety
  void setShareLiveLocation(bool value) {
    state = state.copyWith(shareLiveLocation: value);
    _saveSettings();
  }

  void setSafetyReminders(bool value) {
    state = state.copyWith(safetyReminders: value);
    _saveSettings();
  }

  void setEmergencyContact(String name, String phone) {
    state = state.copyWith(emergencyName: name, emergencyPhone: phone);
    _saveSettings();
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    state = const DriverSettings();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kKey);
    } catch (e) {
      debugPrint('Failed to reset driver settings: $e');
    }
  }
}

final driverSettingsProvider = NotifierProvider<DriverSettingsNotifier, DriverSettings>(
  () => DriverSettingsNotifier(),
);
