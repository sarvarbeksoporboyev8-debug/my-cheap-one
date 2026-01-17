import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:go_router/go_router.dart';
import 'package:sellingapp/core/config/app_config.dart';
import 'package:sellingapp/core/theme_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsPage extends rp.ConsumerStatefulWidget {
  const SettingsPage({super.key});
  @override
  rp.ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends rp.ConsumerState<SettingsPage> {
  final _storage = const FlutterSecureStorage();
  final _tokenController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final t = await _storage.read(key: 'mapbox_token');
      if (t != null) _tokenController.text = t;
    } catch (e) {
      debugPrint('Failed to read mapbox_token: $e');
    }
  }

  Future<void> _saveToken() async {
    setState(() => _saving = true);
    try {
      final v = _tokenController.text.trim();
      if (v.isEmpty) {
        await _storage.delete(key: 'mapbox_token');
      } else {
        await _storage.write(key: 'mapbox_token', value: v, aOptions: const AndroidOptions(encryptedSharedPreferences: true));
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Token saved')));
    } catch (e) {
      debugPrint('Failed to save mapbox_token: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save token')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: Text(switch (mode) { ThemeMode.light => 'Light', ThemeMode.dark => 'Dark', _ => 'System' }),
            trailing: DropdownButton<ThemeMode>(
              value: mode,
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (v) => v != null ? ref.read(themeModeProvider.notifier).setMode(v) : null,
            ),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.data_usage),
            title: const Text('Data Source'),
            subtitle: Text(config.useApiDataSource ? 'API (${config.apiBaseUrl})' : 'Mock data'),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Admin Mode'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/account/admin'),
          ),
          if (!kReleaseMode) const Divider(height: 0),
          if (!kReleaseMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: const [Icon(Icons.map_outlined), SizedBox(width: 8), Text('Mapbox Token (dev only)')]),
                const SizedBox(height: 8),
                TextField(
                  controller: _tokenController,
                  decoration: const InputDecoration(
                    hintText: 'Paste Mapbox access token',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 8),
                Row(children: [
                  FilledButton.icon(onPressed: _saving ? null : _saveToken, icon: const Icon(Icons.save), label: Text(_saving ? 'Saving...' : 'Save')),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _saving
                        ? null
                        : () async {
                            _tokenController.clear();
                            try {
                              await _storage.delete(key: 'mapbox_token');
                            } catch (_) {}
                          },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
                ]),
              ]),
            ),
        ],
      ),
    );
  }
}
