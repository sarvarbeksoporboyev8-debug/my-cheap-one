import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sellingapp/models/delivery.dart';
import 'package:sellingapp/theme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Driver mode state
class DriverModeState {
  final bool isOnline;
  final Driver? currentDriver;
  final DeliveryRequest? activeDelivery;
  final List<DeliveryRequest> pendingRequests;
  
  const DriverModeState({
    this.isOnline = false,
    this.currentDriver,
    this.activeDelivery,
    this.pendingRequests = const [],
  });
  
  DriverModeState copyWith({
    bool? isOnline,
    Driver? currentDriver,
    DeliveryRequest? activeDelivery,
    List<DeliveryRequest>? pendingRequests,
  }) => DriverModeState(
    isOnline: isOnline ?? this.isOnline,
    currentDriver: currentDriver ?? this.currentDriver,
    activeDelivery: activeDelivery ?? this.activeDelivery,
    pendingRequests: pendingRequests ?? this.pendingRequests,
  );
}

class DriverModeNotifier extends Notifier<DriverModeState> {
  Timer? _simulationTimer;
  
  @override
  DriverModeState build() {
    // Mock driver profile
    final driver = Driver(
      id: 'driver_self',
      name: 'You (Driver Mode)',
      phone: '+1 555-0199',
      photoUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop',
      vehicleType: 'car',
      vehiclePlate: 'MY CAR',
      rating: 4.85,
      completedDeliveries: 127,
      currentLocation: const GeoLocation(latitude: 40.7128, longitude: -74.0060),
      isAvailable: false,
    );
    
    return DriverModeState(currentDriver: driver);
  }
  
  void toggleOnline() {
    final newOnlineState = !state.isOnline;
    state = state.copyWith(
      isOnline: newOnlineState,
      currentDriver: state.currentDriver?.copyWith(isAvailable: newOnlineState),
    );
    
    if (newOnlineState) {
      _startSimulatingRequests();
    } else {
      _simulationTimer?.cancel();
      state = state.copyWith(pendingRequests: []);
    }
  }
  
  void _startSimulatingRequests() {
    // Simulate incoming delivery requests
    _simulationTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!state.isOnline || state.activeDelivery != null) return;
      
      final request = _generateMockRequest();
      state = state.copyWith(
        pendingRequests: [...state.pendingRequests, request],
      );
      
      // Auto-remove after 30 seconds if not accepted
      Future.delayed(const Duration(seconds: 30), () {
        if (state.pendingRequests.contains(request)) {
          state = state.copyWith(
            pendingRequests: state.pendingRequests.where((r) => r.id != request.id).toList(),
          );
        }
      });
    });
  }
  
  DeliveryRequest _generateMockRequest() {
    final shops = [
      ('FreshBite Market', '123 Market St'),
      ('Green Valley Organics', '456 Farm Rd'),
      ('Urban Harvest Co-op', '789 City Ave'),
      ('Sunrise Bakery', '321 Baker St'),
    ];
    
    final customers = [
      ('John Smith', '100 Main St, Apt 5'),
      ('Emily Davis', '250 Oak Lane'),
      ('Michael Brown', '75 Pine Street'),
      ('Sarah Wilson', '500 Elm Drive'),
    ];
    
    final shopIndex = DateTime.now().millisecond % shops.length;
    final customerIndex = (DateTime.now().millisecond ~/ 10) % customers.length;
    
    return DeliveryRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      orderId: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      status: DeliveryStatus.pending,
      pickupLocation: GeoLocation(
        latitude: 40.7128 + (shopIndex * 0.005),
        longitude: -74.0060 + (shopIndex * 0.003),
      ),
      pickupAddress: shops[shopIndex].$2,
      pickupName: shops[shopIndex].$1,
      dropoffLocation: GeoLocation(
        latitude: 40.7200 + (customerIndex * 0.008),
        longitude: -74.0100 + (customerIndex * 0.005),
      ),
      dropoffAddress: customers[customerIndex].$2,
      customerName: customers[customerIndex].$1,
      customerPhone: '+1 555-${1000 + customerIndex}',
      createdAt: DateTime.now(),
      deliveryFee: 3.50 + (shopIndex * 0.5),
    );
  }
  
  void acceptDelivery(DeliveryRequest request) {
    state = state.copyWith(
      activeDelivery: request.copyWith(
        status: DeliveryStatus.driverAssigned,
        assignedDriver: state.currentDriver,
        estimatedPickupTime: DateTime.now().add(const Duration(minutes: 8)),
        estimatedDeliveryTime: DateTime.now().add(const Duration(minutes: 25)),
      ),
      pendingRequests: state.pendingRequests.where((r) => r.id != request.id).toList(),
    );
  }
  
  void declineDelivery(DeliveryRequest request) {
    state = state.copyWith(
      pendingRequests: state.pendingRequests.where((r) => r.id != request.id).toList(),
    );
  }
  
  void updateDeliveryStatus(DeliveryStatus newStatus) {
    if (state.activeDelivery == null) return;
    
    state = state.copyWith(
      activeDelivery: state.activeDelivery!.copyWith(
        status: newStatus,
        actualDeliveryTime: newStatus == DeliveryStatus.delivered ? DateTime.now() : null,
      ),
    );
    
    if (newStatus == DeliveryStatus.delivered) {
      // Clear active delivery after a delay
      Future.delayed(const Duration(seconds: 3), () {
        state = state.copyWith(activeDelivery: null);
      });
    }
  }
  
  @override
  void dispose() {
    _simulationTimer?.cancel();
  }
}

final driverModeProvider = NotifierProvider<DriverModeNotifier, DriverModeState>(
  () => DriverModeNotifier(),
);

/// Driver Mode Page
class DriverModePage extends ConsumerStatefulWidget {
  const DriverModePage({super.key});
  
  @override
  ConsumerState<DriverModePage> createState() => _DriverModePageState();
}

class _DriverModePageState extends ConsumerState<DriverModePage> {
  final MapController _mapController = MapController();
  
  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final driverState = ref.watch(driverModeProvider);
    final scheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: Stack(
        children: [
          // Map background
          _buildMap(driverState, scheme),
          
          // Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: _buildTopBar(driverState, scheme),
          ),
          
          // Pending requests
          if (driverState.pendingRequests.isNotEmpty && driverState.activeDelivery == null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 100,
              child: _buildPendingRequestCard(driverState.pendingRequests.first, scheme),
            ),
          
          // Active delivery panel
          if (driverState.activeDelivery != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildActiveDeliveryPanel(driverState.activeDelivery!, scheme),
            ),
          
          // Online/Offline toggle
          if (driverState.activeDelivery == null)
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: _buildOnlineToggle(driverState, scheme),
            ),
        ],
      ),
    );
  }
  
  Widget _buildMap(DriverModeState driverState, ColorScheme scheme) {
    final markers = <Marker>[];
    
    // Driver location
    if (driverState.currentDriver != null) {
      markers.add(
        Marker(
          point: LatLng(
            driverState.currentDriver!.currentLocation.latitude,
            driverState.currentDriver!.currentLocation.longitude,
          ),
          width: 50,
          height: 50,
          child: Container(
            decoration: BoxDecoration(
              color: driverState.isOnline ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      );
    }
    
    // Active delivery markers
    if (driverState.activeDelivery != null) {
      final delivery = driverState.activeDelivery!;
      
      // Pickup
      markers.add(
        Marker(
          point: LatLng(
            delivery.pickupLocation.latitude,
            delivery.pickupLocation.longitude,
          ),
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
      );
      
      // Dropoff
      markers.add(
        Marker(
          point: LatLng(
            delivery.dropoffLocation.latitude,
            delivery.dropoffLocation.longitude,
          ),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.tertiary, width: 2),
            ),
            child: Icon(Icons.location_on, color: scheme.tertiary, size: 24),
          ),
        ),
      );
    }
    
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(40.7128, -74.0060),
        initialZoom: 14,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.sellingapp',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
  
  Widget _buildTopBar(DriverModeState driverState, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundImage: NetworkImage(driverState.currentDriver?.photoUrl ?? ''),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Driver Mode',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: driverState.isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      driverState.isOnline ? 'Online' : 'Offline',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Earnings indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: scheme.primary),
                Text(
                  '24.50',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Settings button
          IconButton(
            icon: Icon(Icons.settings_outlined, color: scheme.onSurfaceVariant),
            onPressed: () => context.push('/driver/settings'),
            tooltip: 'Driver Settings',
          ),
        ],
      ),
    );
  }
  
  Widget _buildPendingRequestCard(DeliveryRequest request, ColorScheme scheme) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.delivery_dining, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Delivery Request',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${request.deliveryFee.toStringAsFixed(2)} delivery fee',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Timer
              _CountdownTimer(
                duration: const Duration(seconds: 30),
                onComplete: () {
                  ref.read(driverModeProvider.notifier).declineDelivery(request);
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Pickup info
          _buildLocationRow(
            icon: Icons.store,
            iconColor: scheme.primary,
            title: request.pickupName,
            subtitle: request.pickupAddress,
          ),
          
          const SizedBox(height: 8),
          
          // Arrow
          Icon(Icons.arrow_downward, color: scheme.outlineVariant),
          
          const SizedBox(height: 8),
          
          // Dropoff info
          _buildLocationRow(
            icon: Icons.location_on,
            iconColor: scheme.tertiary,
            title: request.customerName,
            subtitle: request.dropoffAddress,
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(driverModeProvider.notifier).declineDelivery(request);
                  },
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () {
                    ref.read(driverModeProvider.notifier).acceptDelivery(request);
                  },
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildActiveDeliveryPanel(DeliveryRequest delivery, ColorScheme scheme) {
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
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              
              // Status
              Text(
                delivery.statusText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Current destination
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      delivery.status.index < DeliveryStatus.pickedUp.index
                          ? Icons.store
                          : Icons.location_on,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            delivery.status.index < DeliveryStatus.pickedUp.index
                                ? 'Pickup from'
                                : 'Deliver to',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            delivery.status.index < DeliveryStatus.pickedUp.index
                                ? delivery.pickupName
                                : delivery.customerName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            delivery.status.index < DeliveryStatus.pickedUp.index
                                ? delivery.pickupAddress
                                : delivery.dropoffAddress,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opening navigation...')),
                        );
                      },
                      icon: CircleAvatar(
                        backgroundColor: scheme.primary,
                        child: Icon(Icons.navigation, color: scheme.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Action button based on status
              _buildStatusActionButton(delivery, scheme),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusActionButton(DeliveryRequest delivery, ColorScheme scheme) {
    switch (delivery.status) {
      case DeliveryStatus.driverAssigned:
        return FilledButton.icon(
          onPressed: () {
            ref.read(driverModeProvider.notifier).updateDeliveryStatus(
              DeliveryStatus.arrivedAtPickup,
            );
          },
          icon: const Icon(Icons.store),
          label: const Text('Arrived at Pickup'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        );
      
      case DeliveryStatus.arrivedAtPickup:
        return FilledButton.icon(
          onPressed: () {
            ref.read(driverModeProvider.notifier).updateDeliveryStatus(
              DeliveryStatus.pickedUp,
            );
          },
          icon: const Icon(Icons.inventory_2),
          label: const Text('Picked Up - Start Delivery'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: Colors.orange,
          ),
        );
      
      case DeliveryStatus.pickedUp:
        return FilledButton.icon(
          onPressed: () {
            ref.read(driverModeProvider.notifier).updateDeliveryStatus(
              DeliveryStatus.arrivedAtDropoff,
            );
          },
          icon: const Icon(Icons.location_on),
          label: const Text('Arrived at Customer'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        );
      
      case DeliveryStatus.arrivedAtDropoff:
        return FilledButton.icon(
          onPressed: () {
            ref.read(driverModeProvider.notifier).updateDeliveryStatus(
              DeliveryStatus.delivered,
            );
          },
          icon: const Icon(Icons.check_circle),
          label: const Text('Complete Delivery'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: Colors.green,
          ),
        );
      
      case DeliveryStatus.delivered:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'Delivery Complete! +\$${delivery.deliveryFee.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildOnlineToggle(DriverModeState driverState, ColorScheme scheme) {
    return GestureDetector(
      onTap: () {
        ref.read(driverModeProvider.notifier).toggleOnline();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: driverState.isOnline ? Colors.red : Colors.green,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (driverState.isOnline ? Colors.red : Colors.green).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              driverState.isOnline ? Icons.stop_circle : Icons.play_circle,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              driverState.isOnline ? 'Go Offline' : 'Go Online',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Countdown timer widget
class _CountdownTimer extends StatefulWidget {
  final Duration duration;
  final VoidCallback onComplete;
  
  const _CountdownTimer({
    required this.duration,
    required this.onComplete,
  });
  
  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late int _secondsRemaining;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.duration.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        widget.onComplete();
      }
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final progress = _secondsRemaining / widget.duration.inSeconds;
    final scheme = Theme.of(context).colorScheme;
    
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            backgroundColor: scheme.outlineVariant,
            color: progress > 0.3 ? scheme.primary : Colors.red,
          ),
          Text(
            '$_secondsRemaining',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: progress > 0.3 ? scheme.onSurface : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
