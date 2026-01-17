import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:go_router/go_router.dart';
import 'package:sellingapp/core/config/app_config.dart';
import 'package:sellingapp/nav.dart';

class AccountPage extends rp.ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ListTile(
          leading: Icon(Icons.favorite, color: scheme.primary),
          title: const Text('Favorites'),
          subtitle: const Text('Your saved shops and products'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('${AppRoutes.account}/favorites'),
        ),
        const Divider(height: 0),
        ListTile(
          leading: Icon(Icons.receipt_long, color: scheme.primary),
          title: const Text('Orders'),
          subtitle: const Text('View past orders'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('${AppRoutes.account}/orders'),
        ),
        const Divider(height: 0),
        ListTile(
          leading: Icon(Icons.person, color: scheme.primary),
          title: const Text('Profile'),
          subtitle: const Text('Update your info'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('${AppRoutes.account}/profile'),
        ),
        const Divider(height: 0),
        ListTile(
          leading: Icon(Icons.settings, color: scheme.primary),
          title: const Text('Settings'),
          subtitle: const Text('Theme and data source'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('${AppRoutes.account}/settings'),
        ),
        const Divider(height: 0),
        ListTile(
          leading: Icon(Icons.admin_panel_settings, color: scheme.primary),
          title: const Text('Admin Mode'),
          subtitle: const Text('Manage admin settings and API token'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('${AppRoutes.account}/admin'),
        ),
        const Divider(height: 0),
        ListTile(
          leading: Icon(Icons.data_usage, color: scheme.tertiary),
          title: const Text('Data Source'),
          subtitle: Text(config.useApiDataSource ? 'API (${"${config.apiBaseUrl}"})' : 'Mock data'),
        ),
        const Divider(height: 0),
        ListTile(
          leading: Icon(Icons.info_outline, color: scheme.secondary),
          title: const Text('About'),
          subtitle: const Text('Open Food Marketplace v1.0.0'),
        ),
      ],
    );
  }
}
