import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:go_router/go_router.dart';
import 'package:sellingapp/core/auth.dart';
import 'package:sellingapp/core/developer_settings.dart';
import 'package:sellingapp/core/strings.dart';
import 'package:sellingapp/features/account/presentation/widgets/account_list_tile.dart';
import 'package:sellingapp/features/account/presentation/widgets/account_section_card.dart';
import 'package:sellingapp/nav.dart';
import 'package:sellingapp/theme.dart';

class AccountPage extends rp.ConsumerStatefulWidget {
  const AccountPage({super.key});
  @override
  rp.ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends rp.ConsumerState<AccountPage> {
  int _versionLongPresses = 0;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final dev = ref.watch(developerSettingsProvider);
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                CircleAvatar(radius: 26, backgroundColor: scheme.primaryContainer, child: Icon(Icons.person, color: scheme.primary)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(auth.name ?? 'Guest', style: Theme.of(context).textTheme.titleLarge?.semiBold.withColor(scheme.onSurface), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(auth.email ?? 'Not signed in', style: Theme.of(context).textTheme.bodySmall?.withColor(scheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                  ]),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton.tonalIcon(onPressed: () => context.push('${AppRoutes.account}/profile'), icon: const Icon(Icons.edit), label: const Text('Edit')),
              ]),
            ),
          ),
        ),

        // Personal
        AccountSectionCard(title: 'Personal', children: [
          AccountListTile(icon: Icons.person_outline, title: 'Profile', subtitle: 'Your details and business info', onTap: () => context.push('${AppRoutes.account}/profile')),
          const Divider(height: 0),
          AccountListTile(icon: Icons.favorite_outline, title: 'Favorites / Saved', subtitle: 'Listings you saved', onTap: () => context.push('${AppRoutes.account}/favorites')),
        ]),

        // Activity / Commerce
        AccountSectionCard(title: 'Activity / Commerce', children: [
          AccountListTile(icon: Icons.storefront, title: 'My Listings (Seller mode)', subtitle: 'Your urgent sale listings', onTap: () => context.push('${AppRoutes.account}/my-listings')),
          const Divider(height: 0),
          AccountListTile(icon: Icons.local_offer_outlined, title: 'Offers', subtitle: 'Offers you made and received', onTap: () => context.push('${AppRoutes.account}/offers')),
          const Divider(height: 0),
          AccountListTile(icon: Icons.receipt_long, title: 'Orders / Reservations', subtitle: 'Your reservations and purchases', onTap: () => context.push('${AppRoutes.account}/orders')),
        ]),

        // Preferences
        AccountSectionCard(title: 'Preferences', children: [
          AccountListTile(icon: Icons.my_location_outlined, title: 'Location & Radius', subtitle: 'Near me settings', onTap: () => context.push('${AppRoutes.account}/location')),
          const Divider(height: 0),
          AccountListTile(icon: Icons.notifications_active_outlined, title: 'Notifications', subtitle: 'Alerts for urgent deals', onTap: () => context.push('${AppRoutes.account}/notifications')),
          const Divider(height: 0),
          AccountListTile(icon: Icons.palette_outlined, title: 'Appearance', subtitle: 'Theme and language', onTap: () => context.push('${AppRoutes.account}/appearance')),
        ]),

        // Support / Legal
        AccountSectionCard(title: 'Support / Legal', children: [
          AccountListTile(icon: Icons.help_outline, title: 'Help & Support', subtitle: 'FAQs and contact', onTap: () => context.push('${AppRoutes.account}/support')),
          const Divider(height: 0),
          AccountListTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: '${AppStrings.appName} · ${AppStrings.appVersion}',
            onTap: () => context.push('${AppRoutes.account}/about'),
            trailing: GestureDetector(
              onLongPress: () {
                _versionLongPresses++;
                if (_versionLongPresses >= 5) {
                  ref.read(developerSettingsProvider.notifier).setDeveloperMode(true);
                  _versionLongPresses = 0;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Developer Mode enabled')));
                }
              },
              child: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ),
          ),
        ]),

        if (dev.developerMode || !kReleaseMode)
          AccountSectionCard(title: 'Developer / Admin', children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                const Text('Developer Mode'),
                const Spacer(),
                Switch(value: dev.developerMode, onChanged: (v) => ref.read(developerSettingsProvider.notifier).setDeveloperMode(v)),
              ]),
            ),
            AccountListTile(icon: Icons.admin_panel_settings_outlined, title: 'Admin Mode', subtitle: 'API token and advanced controls', onTap: () => context.push('${AppRoutes.account}/admin')),
          ]),

        const SizedBox(height: AppSpacing.md),

        // Logout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Log out'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Log out'),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;
              await ref.read(authStateProvider.notifier).logout();
              if (mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Log out'),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
