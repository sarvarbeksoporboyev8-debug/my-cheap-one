import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sellingapp/core/theme_controller.dart';
import 'package:sellingapp/features/delivery/data/driver_settings_provider.dart';
import 'package:sellingapp/features/delivery/presentation/pages/driver_mode_page.dart';
import 'package:sellingapp/features/delivery/presentation/widgets/settings_section_card.dart';

class DriverSettingsPage extends ConsumerWidget {
  const DriverSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(driverSettingsProvider);
    final notifier = ref.read(driverSettingsProvider.notifier);
    final driverState = ref.watch(driverModeProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(context, ref, driverState, scheme),
            ),
            title: const Text('Driver Settings'),
          ),
          
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),
              
              // Section 1: Availability & Jobs
              _buildAvailabilitySection(context, settings, notifier, scheme),
              
              // Section 2: Navigation & Maps
              _buildNavigationSection(context, settings, notifier),
              
              // Section 3: Notifications
              _buildNotificationsSection(context, settings, notifier),
              
              // Section 4: Safety
              _buildSafetySection(context, settings, notifier),
              
              // Section 5: Account & Vehicle
              _buildAccountSection(context),
              
              // Section 6: App Preferences
              _buildAppPreferencesSection(context, ref),
              
              // Section 7: Danger Zone
              _buildDangerZone(context, ref),
              
              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, DriverModeState driverState, ColorScheme scheme) {
    final driver = driverState.currentDriver;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [scheme.primaryContainer, scheme.surface],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: driver?.photoUrl != null 
                    ? NetworkImage(driver!.photoUrl) 
                    : null,
                child: driver?.photoUrl == null 
                    ? const Icon(Icons.person, size: 36) 
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      driver?.name ?? 'Driver',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text('${driver?.rating ?? 0}'),
                        const SizedBox(width: 12),
                        Text('${driver?.completedDeliveries ?? 0} deliveries', 
                            style: TextStyle(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${driver?.vehicleType?.toUpperCase() ?? 'CAR'} • ${driver?.vehiclePlate ?? 'N/A'}',
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Online status chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: driverState.isOnline ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  driverState.isOnline ? 'Online' : 'Offline',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilitySection(BuildContext context, settings, notifier, ColorScheme scheme) {
    return SettingsSectionCard(
      title: 'Availability & Jobs',
      icon: Icons.work_outline,
      iconColor: Colors.green,
      children: [
        SettingsSwitchTile(
          title: 'Auto go online',
          subtitle: 'Automatically go online when opening Driver Mode',
          value: settings.autoGoOnline,
          onChanged: notifier.setAutoGoOnline,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsSwitchTile(
          title: 'Auto-accept requests',
          subtitle: 'Automatically accept incoming delivery requests',
          value: settings.autoAccept,
          onChanged: notifier.setAutoAccept,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsSliderTile(
          title: 'Max pickup distance',
          leadingIcon: Icons.place_outlined,
          value: settings.maxPickupKm,
          min: 1,
          max: 30,
          divisions: 29,
          labelBuilder: (v) => '${v.round()} km',
          onChanged: notifier.setMaxPickupKm,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsSliderTile(
          title: 'Minimum delivery fee',
          leadingIcon: Icons.attach_money,
          value: settings.minFee,
          min: 0,
          max: 20,
          divisions: 20,
          labelBuilder: (v) => '\$${v.toStringAsFixed(0)}',
          onChanged: notifier.setMinFee,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsSegmentedTile<String>(
          title: 'Preferred job types',
          leadingIcon: Icons.category_outlined,
          value: settings.preferredJobType,
          segments: const [
            ButtonSegment(value: 'food', label: Text('Food')),
            ButtonSegment(value: 'grocery', label: Text('Grocery')),
            ButtonSegment(value: 'both', label: Text('Both')),
          ],
          onChanged: (v) => notifier.setPreferredJobType(v.first),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildNavigationSection(BuildContext context, settings, notifier) {
    return SettingsSectionCard(
      title: 'Navigation & Maps',
      icon: Icons.map_outlined,
      iconColor: Colors.blue,
      children: [
        SettingsDropdownTile<String>(
          title: 'Navigation app',
          leadingIcon: Icons.navigation_outlined,
          value: settings.navApp,
          items: const [
            DropdownMenuItem(value: 'in_app', child: Text('In-app')),
            DropdownMenuItem(value: 'google_maps', child: Text('Google Maps')),
            DropdownMenuItem(value: 'waze', child: Text('Waze')),
          ],
          onChanged: (v) => v != null ? notifier.setNavApp(v) : null,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsSwitchTile(
          title: 'Voice navigation',
          value: settings.voiceNav,
          onChanged: notifier.setVoiceNav,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsSwitchTile(
          title: 'Avoid tolls',
          value: settings.avoidTolls,
          onChanged: notifier.setAvoidTolls,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsSegmentedTile<String>(
          title: 'Distance units',
          leadingIcon: Icons.straighten,
          value: settings.units,
          segments: const [
            ButtonSegment(value: 'km', label: Text('Kilometers')),
            ButtonSegment(value: 'mi', label: Text('Miles')),
          ],
          onChanged: (v) => notifier.setUnits(v.first),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsSwitchTile(
          title: 'Keep screen awake',
          subtitle: 'During active deliveries',
          value: settings.keepScreenAwake,
          onChanged: notifier.setKeepScreenAwake,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildNotificationsSection(BuildContext context, settings, notifier) {
    return SettingsSectionCard(
      title: 'Notifications',
      icon: Icons.notifications_outlined,
      iconColor: Colors.orange,
      children: [
        SettingsSwitchTile(
          title: 'New request alerts',
          value: settings.notifRequests,
          onChanged: notifier.setNotifRequests,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsSwitchTile(
          title: 'Sound',
          value: settings.notifSound,
          onChanged: notifier.setNotifSound,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsSwitchTile(
          title: 'Vibration',
          value: settings.notifVibration,
          onChanged: notifier.setNotifVibration,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsSwitchTile(
          title: 'Chat messages',
          value: settings.notifChat,
          onChanged: notifier.setNotifChat,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsNavigationTile(
          title: 'Quiet hours',
          subtitle: settings.quietHoursDisplay,
          leadingIcon: Icons.bedtime_outlined,
          onTap: () => _showQuietHoursDialog(context, settings, notifier),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSafetySection(BuildContext context, settings, notifier) {
    return SettingsSectionCard(
      title: 'Safety',
      icon: Icons.shield_outlined,
      iconColor: Colors.red,
      children: [
        SettingsNavigationTile(
          title: 'Emergency contact',
          subtitle: settings.emergencyName.isNotEmpty 
              ? '${settings.emergencyName} • ${settings.emergencyPhone}'
              : 'Not set',
          leadingIcon: Icons.emergency_outlined,
          onTap: () => _showEmergencyContactDialog(context, settings, notifier),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsSwitchTile(
          title: 'Share live location',
          subtitle: 'During active deliveries',
          value: settings.shareLiveLocation,
          onChanged: notifier.setShareLiveLocation,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsSwitchTile(
          title: 'Safety check reminders',
          value: settings.safetyReminders,
          onChanged: notifier.setSafetyReminders,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsNavigationTile(
          title: 'Emergency info',
          leadingIcon: Icons.info_outline,
          onTap: () => _showEmergencyInfoSheet(context),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return SettingsSectionCard(
      title: 'Account & Vehicle',
      icon: Icons.person_outline,
      iconColor: Colors.purple,
      children: [
        SettingsNavigationTile(
          title: 'Profile',
          leadingIcon: Icons.badge_outlined,
          onTap: () => context.push('/driver/profile'),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsNavigationTile(
          title: 'Vehicle details',
          leadingIcon: Icons.directions_car_outlined,
          onTap: () => context.push('/driver/vehicle'),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsNavigationTile(
          title: 'Documents',
          subtitle: 'License, insurance',
          leadingIcon: Icons.folder_outlined,
          onTap: () => context.push('/driver/documents'),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsNavigationTile(
          title: 'Payout & earnings',
          leadingIcon: Icons.account_balance_wallet_outlined,
          onTap: () => context.push('/driver/payout'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAppPreferencesSection(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return SettingsSectionCard(
      title: 'App Preferences',
      icon: Icons.tune,
      iconColor: Colors.teal,
      children: [
        SettingsDropdownTile<ThemeMode>(
          title: 'Theme',
          leadingIcon: Icons.palette_outlined,
          value: themeMode,
          items: const [
            DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
            DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
            DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
          ],
          onChanged: (v) => v != null ? ref.read(themeModeProvider.notifier).setMode(v) : null,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsNavigationTile(
          title: 'Privacy Policy',
          leadingIcon: Icons.privacy_tip_outlined,
          onTap: () => _showComingSoon(context),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsNavigationTile(
          title: 'Terms of Service',
          leadingIcon: Icons.description_outlined,
          onTap: () => _showComingSoon(context),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        SettingsNavigationTile(
          title: 'About',
          subtitle: 'Version 1.0.0',
          leadingIcon: Icons.info_outline,
          onTap: () => _showComingSoon(context),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDangerZone(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    
    return SettingsSectionCard(
      title: 'Danger Zone',
      icon: Icons.warning_amber_outlined,
      iconColor: scheme.error,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context, ref),
                  icon: const Icon(Icons.logout),
                  label: const Text('Log out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.error,
                    side: BorderSide(color: scheme.error),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _showDeleteAccountDialog(context),
                  child: Text('Delete account', style: TextStyle(color: scheme.error)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showQuietHoursDialog(BuildContext context, settings, notifier) {
    TimeOfDay? start = settings.quietHoursEnabled 
        ? TimeOfDay(hour: settings.quietStartMinutes ~/ 60, minute: settings.quietStartMinutes % 60)
        : const TimeOfDay(hour: 22, minute: 0);
    TimeOfDay? end = settings.quietHoursEnabled
        ? TimeOfDay(hour: settings.quietEndMinutes ~/ 60, minute: settings.quietEndMinutes % 60)
        : const TimeOfDay(hour: 7, minute: 0);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quiet Hours', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Mute notifications during these hours', 
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showTimePicker(context: ctx, initialTime: start!);
                        if (picked != null) setState(() => start = picked);
                      },
                      child: Text('Start: ${start!.format(ctx)}'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showTimePicker(context: ctx, initialTime: end!);
                        if (picked != null) setState(() => end = picked);
                      },
                      child: Text('End: ${end!.format(ctx)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        notifier.disableQuietHours();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Disable'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        notifier.setQuietHours(start, end);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmergencyContactDialog(BuildContext context, settings, notifier) {
    final nameController = TextEditingController(text: settings.emergencyName);
    final phoneController = TextEditingController(text: settings.emergencyPhone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              notifier.setEmergencyContact(nameController.text, phoneController.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Emergency Information', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Text('In case of emergency:\n\n'
                '1. Your emergency contact will be notified\n'
                '2. Your live location will be shared\n'
                '3. Local emergency services can be contacted\n\n'
                'Stay safe while delivering!'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/');
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This action cannot be undone. All your data will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion requested')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }
}
