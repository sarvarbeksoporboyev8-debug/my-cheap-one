import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sellingapp/models/delivery.dart';
import 'package:sellingapp/features/delivery/services/delivery_service.dart';
import 'package:sellingapp/theme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DeliveryTrackingPage extends ConsumerStatefulWidget {
  final String deliveryId;
  
  const DeliveryTrackingPage({super.key, required this.deliveryId});
  
  @override
  ConsumerState<DeliveryTrackingPage> createState() => _DeliveryTrackingPageState();
}

class _DeliveryTrackingPageState extends ConsumerState<DeliveryTrackingPage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final MapController _mapController = MapController();
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Set active delivery
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeDeliveryStateProvider.notifier).setActiveDelivery(widget.deliveryId);
    });
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final deliveryState = ref.watch(activeDeliveryStateProvider);
    final delivery = deliveryState.delivery;
    final scheme = Theme.of(context).colorScheme;
    
    if (delivery == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tracking')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      body: Stack(
        children: [
          // Map
          _buildMap(delivery, scheme),
          
          // Top bar with back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: CircleAvatar(
              backgroundColor: scheme.surface,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          
          // Bottom sheet with delivery info
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomSheet(delivery, scheme),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMap(DeliveryRequest delivery, ColorScheme scheme) {
    final pickupLatLng = LatLng(
      delivery.pickupLocation.latitude,
      delivery.pickupLocation.longitude,
    );
    final dropoffLatLng = LatLng(
      delivery.dropoffLocation.latitude,
      delivery.dropoffLocation.longitude,
    );
    
    // Calculate center between pickup and dropoff
    final centerLat = (pickupLatLng.latitude + dropoffLatLng.latitude) / 2;
    final centerLng = (pickupLatLng.longitude + dropoffLatLng.longitude) / 2;
    
    final markers = <Marker>[
      // Pickup marker (shop)
      Marker(
        point: pickupLatLng,
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            shape: BoxShape.circle,
            border: Border.all(color: scheme.primary, width: 2),
          ),
          child: Icon(Icons.store, color: scheme.primary, size: 24),
        ),
      ),
      // Dropoff marker (customer)
      Marker(
        point: dropoffLatLng,
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: scheme.tertiaryContainer,
            shape: BoxShape.circle,
            border: Border.all(color: scheme.tertiary, width: 2),
          ),
          child: Icon(Icons.home, color: scheme.tertiary, size: 24),
        ),
      ),
    ];
    
    // Add driver marker if assigned
    if (delivery.assignedDriver != null) {
      final driverLatLng = LatLng(
        delivery.assignedDriver!.currentLocation.latitude,
        delivery.assignedDriver!.currentLocation.longitude,
      );
      
      markers.add(
        Marker(
          point: driverLatLng,
          width: 50,
          height: 50,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.secondary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: scheme.secondary.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    _getVehicleIcon(delivery.assignedDriver!.vehicleType),
                    color: scheme.onSecondary,
                    size: 28,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(centerLat, centerLng),
        initialZoom: 14,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.sellingapp',
        ),
        // Route line
        PolylineLayer(
          polylines: [
            Polyline(
              points: [pickupLatLng, dropoffLatLng],
              color: scheme.primary.withOpacity(0.6),
              strokeWidth: 4,
              pattern: const StrokePattern.dotted(),
            ),
          ],
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
  
  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType) {
      case 'car':
        return Icons.directions_car;
      case 'bike':
        return Icons.directions_bike;
      case 'scooter':
        return Icons.electric_scooter;
      default:
        return Icons.local_shipping;
    }
  }
  
  Widget _buildBottomSheet(DeliveryRequest delivery, ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Status indicator
              _buildStatusSection(delivery, scheme),
              
              const SizedBox(height: 20),
              
              // Driver info (if assigned)
              if (delivery.assignedDriver != null) ...[
                _buildDriverCard(delivery.assignedDriver!, scheme),
                const SizedBox(height: 16),
              ],
              
              // Delivery progress
              _buildProgressIndicator(delivery, scheme),
              
              const SizedBox(height: 16),
              
              // Action buttons
              _buildActionButtons(delivery, scheme),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusSection(DeliveryRequest delivery, ColorScheme scheme) {
    final isSearching = delivery.status == DeliveryStatus.pending;
    
    return Row(
      children: [
        if (isSearching)
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: scheme.primary,
            ),
          )
        else
          Icon(
            _getStatusIcon(delivery.status),
            color: scheme.primary,
            size: 24,
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                delivery.statusText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (delivery.estimatedMinutesRemaining != null)
                Text(
                  'Estimated arrival: ${delivery.estimatedMinutesRemaining} min',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  IconData _getStatusIcon(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return Icons.search;
      case DeliveryStatus.driverAssigned:
        return Icons.directions_car;
      case DeliveryStatus.arrivedAtPickup:
        return Icons.store;
      case DeliveryStatus.pickedUp:
        return Icons.inventory_2;
      case DeliveryStatus.arrivedAtDropoff:
        return Icons.location_on;
      case DeliveryStatus.delivered:
        return Icons.check_circle;
      case DeliveryStatus.cancelled:
        return Icons.cancel;
    }
  }
  
  Widget _buildDriverCard(Driver driver, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Driver photo
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(driver.photoUrl),
          ),
          const SizedBox(width: 12),
          // Driver info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber[700]),
                    const SizedBox(width: 4),
                    Text(
                      '${driver.rating}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${driver.completedDeliveries} deliveries',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${driver.vehiclePlate} • ${driver.vehicleType.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Call button
          IconButton(
            onPressed: () {
              // In real app: launch phone dialer
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling ${driver.phone}...')),
              );
            },
            icon: CircleAvatar(
              backgroundColor: scheme.primary,
              child: Icon(Icons.phone, color: scheme.onPrimary, size: 20),
            ),
          ),
          // Message button
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening chat...')),
              );
            },
            icon: CircleAvatar(
              backgroundColor: scheme.secondary,
              child: Icon(Icons.chat, color: scheme.onSecondary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressIndicator(DeliveryRequest delivery, ColorScheme scheme) {
    final stages = [
      ('Order placed', DeliveryStatus.pending),
      ('Driver assigned', DeliveryStatus.driverAssigned),
      ('Picked up', DeliveryStatus.pickedUp),
      ('Delivered', DeliveryStatus.delivered),
    ];
    
    final currentIndex = stages.indexWhere((s) => s.$2 == delivery.status);
    
    return Row(
      children: List.generate(stages.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final stageIndex = index ~/ 2;
          final isCompleted = stageIndex < currentIndex;
          return Expanded(
            child: Container(
              height: 3,
              color: isCompleted ? scheme.primary : scheme.outlineVariant,
            ),
          );
        } else {
          // Stage dot
          final stageIndex = index ~/ 2;
          final isCompleted = stageIndex <= currentIndex;
          final isCurrent = stageIndex == currentIndex;
          
          return Column(
            children: [
              Container(
                width: isCurrent ? 16 : 12,
                height: isCurrent ? 16 : 12,
                decoration: BoxDecoration(
                  color: isCompleted ? scheme.primary : scheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? scheme.primary : scheme.outlineVariant,
                    width: 2,
                  ),
                ),
                child: isCompleted && !isCurrent
                    ? Icon(Icons.check, size: 8, color: scheme.onPrimary)
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                stages[stageIndex].$1,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isCompleted ? scheme.primary : scheme.onSurfaceVariant,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }
      }),
    );
  }
  
  Widget _buildActionButtons(DeliveryRequest delivery, ColorScheme scheme) {
    if (delivery.status == DeliveryStatus.delivered) {
      return FilledButton.icon(
        onPressed: () => context.go('/'),
        icon: const Icon(Icons.home),
        label: const Text('Back to Home'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
      );
    }
    
    if (delivery.status == DeliveryStatus.arrivedAtDropoff) {
      return FilledButton.icon(
        onPressed: () {
          ref.read(deliveryServiceProvider).confirmDelivery(delivery.id);
        },
        icon: const Icon(Icons.check_circle),
        label: const Text('Confirm Delivery'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          backgroundColor: Colors.green,
        ),
      );
    }
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _showCancelDialog(delivery);
            },
            icon: const Icon(Icons.close),
            label: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contacting support...')),
              );
            },
            icon: const Icon(Icons.support_agent),
            label: const Text('Help'),
          ),
        ),
      ],
    );
  }
  
  void _showCancelDialog(DeliveryRequest delivery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Delivery?'),
        content: const Text(
          'Are you sure you want to cancel this delivery? '
          'Cancellation fees may apply.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Order'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(deliveryServiceProvider).cancelDelivery(
                delivery.id,
                'Customer cancelled',
              );
              Navigator.pop(context);
              context.go('/');
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Delivery'),
          ),
        ],
      ),
    );
  }
}
