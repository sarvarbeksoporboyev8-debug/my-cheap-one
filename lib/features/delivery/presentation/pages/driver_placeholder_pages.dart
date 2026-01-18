import 'package:flutter/material.dart';

/// Placeholder page for driver profile editing
class DriverProfilePage extends StatelessWidget {
  const DriverProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _PlaceholderPage(
      title: 'Profile',
      icon: Icons.badge_outlined,
      description: 'Edit your driver profile, photo, and personal information.',
    );
  }
}

/// Placeholder page for vehicle details
class DriverVehiclePage extends StatelessWidget {
  const DriverVehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _PlaceholderPage(
      title: 'Vehicle Details',
      icon: Icons.directions_car_outlined,
      description: 'Manage your vehicle information, type, and license plate.',
    );
  }
}

/// Placeholder page for documents
class DriverDocumentsPage extends StatelessWidget {
  const DriverDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _PlaceholderPage(
      title: 'Documents',
      icon: Icons.folder_outlined,
      description: 'Upload and manage your driver\'s license, insurance, and other required documents.',
    );
  }
}

/// Placeholder page for payout and earnings
class DriverPayoutPage extends StatelessWidget {
  const DriverPayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _PlaceholderPage(
      title: 'Payout & Earnings',
      icon: Icons.account_balance_wallet_outlined,
      description: 'View your earnings history and manage payout settings.',
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;

  const _PlaceholderPage({
    required this.title,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: scheme.primary),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.construction, size: 20, color: scheme.onTertiaryContainer),
                    const SizedBox(width: 8),
                    Text(
                      'Coming Soon',
                      style: TextStyle(
                        color: scheme.onTertiaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
