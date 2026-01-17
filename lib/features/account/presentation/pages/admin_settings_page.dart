import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminSettingsPage extends ConsumerStatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  ConsumerState<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends ConsumerState<AdminSettingsPage> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    const storage = FlutterSecureStorage();
    storage.read(key: 'admin_api_token').then((value) => setState(() => _controller.text = value ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Enter API token to enable admin features.'),
        const SizedBox(height: 12),
        TextField(controller: _controller, decoration: const InputDecoration(labelText: 'X-Spree-Token')),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _saving
              ? null
              : () async {
                  setState(() => _saving = true);
                  try {
                    const storage = FlutterSecureStorage();
                    await storage.write(key: 'admin_api_token', value: _controller.text.trim());
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
                  } finally {
                    if (mounted) setState(() => _saving = false);
                  }
                },
          child: _saving ? const CircularProgressIndicator() : const Text('Save'),
        )
      ]),
    );
  }
}
