import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:sellingapp/features/map/presentation/controllers/map_controller.dart';
import 'package:sellingapp/models/enterprise.dart';

class MapPage extends rp.ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  rp.ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends rp.ConsumerState<MapPage> {
  final TextEditingController _searchController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  static const _defaultCenter = (lat: 37.7749, lng: -122.4194); // San Francisco
  static const _defaultZoom = 13.0;

  String? _token;
  bool _loadingToken = true;
  Timer? _debounce;

  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointManager;
  Uint8List? _markerBytes;
  Uint8List? _markerSelectedBytes;
  final Map<String, Enterprise> _annotationIndex = {};
  bool _pointClickListenerAttached = false;
  OnPointAnnotationClickListener? _markerTapListener;

  void _onMarkerTap(PointAnnotation annotation) {
    try {
      final key = annotation.id; // nullable in some SDK versions
      if (key == null) return;
      final e = _annotationIndex[key];
      if (e != null) {
        ref.read(mapControllerProvider.notifier).setSelected(e);
        unawaited(_centerOnEnterprise(e));
        _showEnterpriseSheet(e);
      }
    } catch (e) {
      debugPrint('Marker tap handler failed: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _resolveToken();
    // Kick off data load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapControllerProvider.notifier).loadEnterprises();
      ref.listen<MapState>(mapControllerProvider, (prev, next) {
        _syncAnnotations();
      });
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(mapControllerProvider.notifier).setQuery(_searchController.text.trim());
    });
  }

  Future<void> _resolveToken() async {
    // Priority: MAPBOX_ACCESS_TOKEN -> ACCESS_TOKEN -> secure storage 'mapbox_access_token'
    const envPrimary = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
    const envLegacy = String.fromEnvironment('ACCESS_TOKEN');
    String? token;
    if (envPrimary.isNotEmpty) {
      token = envPrimary;
    } else if (envLegacy.isNotEmpty) {
      token = envLegacy;
    } else {
      try {
        final stored = await _storage.read(key: 'mapbox_access_token');
        if (stored != null && stored.isNotEmpty) token = stored;
      } catch (e) {
        debugPrint('Secure storage read failed: $e');
      }
    }
    
    // Set the token BEFORE creating the map widget
    if (token != null && token.isNotEmpty) {
      try {
        MapboxOptions.setAccessToken(token);
        debugPrint('Mapbox token set successfully');
      } catch (e) {
        debugPrint('Failed to set Mapbox token: $e');
      }
    }
    
    if (!mounted) return;
    setState(() { _token = token; _loadingToken = false; });
  }

  void _openEnterprise(Enterprise e) => context.push('/shops/${e.id}');

  Future<Uint8List> _buildMarker({required Color color, required Color border, double size = 40, IconData? icon}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final radius = size / 2;
    final center = Offset(radius, radius);
    final paint = Paint()..color = color;
    final borderPaint = Paint()
      ..color = border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius - 1.5, paint);
    canvas.drawCircle(center, radius - 1.5, borderPaint);
    if (icon != null) {
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      final iconStr = String.fromCharCode(icon.codePoint);
      final textStyle = TextStyle(color: Colors.white, fontSize: radius, fontFamily: icon.fontFamily, package: icon.fontPackage);
      textPainter.text = TextSpan(text: iconStr, style: textStyle);
      textPainter.layout();
      final offset = Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2);
      textPainter.paint(canvas, offset);
    }
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  Future<void> _ensureMarkerImages(BuildContext context) async {
    if (_markerBytes != null && _markerSelectedBytes != null) return;
    final cs = Theme.of(context).colorScheme;
    _markerBytes = await _buildMarker(color: cs.primary, border: cs.onPrimary.withValues(alpha: 0.2), icon: Icons.store);
    _markerSelectedBytes = await _buildMarker(color: cs.secondary, border: cs.onSecondary.withValues(alpha: 0.2), icon: Icons.store);
  }

  Future<void> _onMapCreated(MapboxMap controller) async {
    _mapboxMap = controller;
    // Try to set access token if API is available at runtime
    try {
      if (_token != null && _token!.isNotEmpty) {
        MapboxOptions.setAccessToken(_token!);
      }
    } catch (e) {
      debugPrint('MapboxOptions.setAccessToken not available: $e');
    }
  }

  Future<void> _setInitialCameraIfNeeded() async {
    if (_mapboxMap == null) return;
    try {
      final is3D = ref.read(mapControllerProvider).is3D;
      final zoom = is3D ? 16.0 : _defaultZoom;
      final pitch = is3D ? 60.0 : 0.0;
      final bearing = is3D ? 20.0 : 0.0;
      await _mapboxMap!.setCamera(CameraOptions(center: Point(coordinates: Position(_defaultCenter.lng, _defaultCenter.lat)), zoom: zoom, pitch: pitch, bearing: bearing));
    } catch (e) {
      debugPrint('Failed to set initial camera: $e');
    }
  }

  Future<void> _verifyOrAdd3DBuildingsLayer() async {
    if (_mapboxMap == null) return;
    try {
      final exists = await _mapboxMap!.style.styleLayerExists('3d-buildings');
      if (exists) return;
      const jsonLayer = '{"id":"3d-buildings","type":"fill-extrusion","source":"composite","source-layer":"building","filter":["==",["get","extrude"],"true"],"minzoom":15,"paint":{"fill-extrusion-color":"#AAAAAA","fill-extrusion-height":["get","height"],"fill-extrusion-base":["get","min_height"],"fill-extrusion-opacity":0.6}}';
      await _mapboxMap!.style.addStyleLayer(jsonLayer, null);
    } catch (e) {
      debugPrint('3D buildings layer ensure failed: $e');
    }
  }

  Future<void> _syncAnnotations() async {
    if (_mapboxMap == null) return;
    final items = ref.read(mapControllerProvider).visibleItems;
    try {
      _pointManager ??= await _mapboxMap!.annotations.createPointAnnotationManager();
      // Attach click listener once per manager
      if (!_pointClickListenerAttached && _pointManager != null) {
        try {
          _markerTapListener ??= _InlinePointAnnotationClickListener(_onMarkerTap);
          _pointManager!.addOnPointAnnotationClickListener(_markerTapListener!);
          _pointClickListenerAttached = true;
        } catch (e) {
          debugPrint('Failed to attach marker tap listener: $e');
        }
      }

      await _pointManager!.deleteAll();
      await _ensureMarkerImages(context);
      final selected = ref.read(mapControllerProvider).selected;
      final opts = <PointAnnotationOptions>[];
      for (final e in items) {
        final isSelected = selected?.id == e.id;
        final bytes = isSelected ? _markerSelectedBytes! : _markerBytes!;
        opts.add(PointAnnotationOptions(
          geometry: Point(coordinates: Position(e.lng!, e.lat!)),
          image: bytes,
          iconSize: 1.0,
          textField: e.name,
          textOffset: [0, 1.2],
          textSize: 10,
        ));
      }
      // Create annotations and build index for reverse lookup on tap
      final anns = await _pointManager!.createMulti(opts);
      _annotationIndex.clear();
      for (var i = 0; i < anns.length && i < items.length; i++) {
        final ann = anns[i];
        if (ann == null) continue;
        final key = ann.id;
        if (key != null) {
          _annotationIndex[key] = items[i];
        }
      }
    } catch (e) {
      debugPrint('Failed to sync annotations: $e');
    }
  }

  Future<void> _centerOnEnterprise(Enterprise e, {bool jump = false}) async {
    if (_mapboxMap == null || e.lat == null || e.lng == null) return;
    final is3D = ref.read(mapControllerProvider).is3D;
    final pitch = is3D ? 60.0 : 0.0;
    final zoom = is3D ? 16.0 : 14.0;
    final bearing = is3D ? 20.0 : 0.0;
    final cam = CameraOptions(center: Point(coordinates: Position(e.lng!, e.lat!)), zoom: zoom, pitch: pitch, bearing: bearing);
    try {
      if (jump) {
        await _mapboxMap!.setCamera(cam);
      } else {
        await _mapboxMap!.flyTo(cam, MapAnimationOptions(duration: 750));
      }
    } catch (e) {
      debugPrint('Failed to move camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapControllerProvider);
    if (_loadingToken) return const Center(child: CircularProgressIndicator());
    if ((_token == null || _token!.isEmpty) && !kIsWeb) {
      return _MissingTokenState(onOpenSettings: () => context.go('/account/settings'));
    }

    return Stack(children: [
      Positioned.fill(child: _buildPlatformMap(context, mapState)),
      SafeArea(child: _TopOverlay(searchController: _searchController, mode: mapState.mode, onModeChanged: (m) => ref.read(mapControllerProvider.notifier).toggleMode(m))),
      _BottomSellersPanel(onTapItem: (e) async {
        ref.read(mapControllerProvider.notifier).setSelected(e);
        await _centerOnEnterprise(e);
        _showEnterpriseSheet(e);
      }),
      Positioned(right: 16, bottom: 24, child: _MapControls(is3D: mapState.is3D, onRecenter: () async => await _setInitialCameraIfNeeded(), onZoomIn: () async {
        try {
          final cam = await _mapboxMap?.getCameraState();
          if (cam != null) {
            await _mapboxMap?.easeTo(CameraOptions(zoom: (cam.zoom ?? _defaultZoom) + 1), MapAnimationOptions(duration: 200));
          }
        } catch (e) { debugPrint('zoom in fail: $e'); }
      }, onZoomOut: () async {
        try {
          final cam = await _mapboxMap?.getCameraState();
          if (cam != null) {
            await _mapboxMap?.easeTo(CameraOptions(zoom: (cam.zoom ?? _defaultZoom) - 1), MapAnimationOptions(duration: 200));
          }
        } catch (e) { debugPrint('zoom out fail: $e'); }
      }, onToggle3D: () async {
        // Toggle state first
        ref.read(mapControllerProvider.notifier).toggle3D();
        final is3D = ref.read(mapControllerProvider).is3D;
        try {
          // If something is selected, prefer centering on it with appropriate camera
          final sel = ref.read(mapControllerProvider).selected;
          if (sel != null) {
            await _centerOnEnterprise(sel);
            return;
          }
          // Otherwise, adjust current camera in place: raise zoom for 3D and tilt
          final cam = await _mapboxMap?.getCameraState();
          final currentZoom = cam?.zoom ?? _defaultZoom;
          final targetZoom = is3D ? (currentZoom < 16.0 ? 16.0 : currentZoom) : currentZoom; // 3D buildings visible >= 15
          await _mapboxMap?.easeTo(
            CameraOptions(zoom: targetZoom, pitch: is3D ? 60.0 : 0.0, bearing: is3D ? 20.0 : 0.0),
            MapAnimationOptions(duration: 300),
          );
        } catch (e) {
          debugPrint('toggle 3D fail: $e');
          // Fallback: set to default camera respecting 3D
          await _setInitialCameraIfNeeded();
        }
      })),
    ]);
  }

  void _showEnterpriseSheet(Enterprise e) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.store_mall_directory, color: cs.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(e.name, style: Theme.of(context).textTheme.titleLarge)),
            ]),
            if ((e.shortDescription ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(e.shortDescription!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Shop'),
                onPressed: () {
                  context.pop();
                  _openEnterprise(e);
                },
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _buildPlatformMap(BuildContext context, MapState mapState) {
    if (kIsWeb) {
      return const _WebMapFallback();
    }
    if (_token == null || _token!.isEmpty) {
      return _MissingTokenState(onOpenSettings: () => context.go('/account/settings'));
    }
    return MapWidget(
      key: const ValueKey('mapbox-map'),
      cameraOptions: CameraOptions(center: Point(coordinates: Position(_defaultCenter.lng, _defaultCenter.lat)), zoom: _defaultZoom, pitch: mapState.is3D ? 60 : 0, bearing: mapState.is3D ? 20 : 0),
      styleUri: MapboxStyles.MAPBOX_STREETS,
      onMapCreated: _onMapCreated,
      onStyleLoadedListener: (event) async {
        await _verifyOrAdd3DBuildingsLayer();
        await _syncAnnotations();
        await _setInitialCameraIfNeeded();
      },
    );
  }
}

class _InlinePointAnnotationClickListener extends OnPointAnnotationClickListener {
  final void Function(PointAnnotation) onTap;
  _InlinePointAnnotationClickListener(this.onTap);
  @override
  void onPointAnnotationClick(PointAnnotation annotation) => onTap(annotation);
}

class _TopOverlay extends rp.ConsumerWidget {
  final TextEditingController searchController;
  final SellerMode mode;
  final ValueChanged<SellerMode> onModeChanged;
  const _TopOverlay({required this.searchController, required this.mode, required this.onModeChanged});

  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          decoration: BoxDecoration(color: cs.surface.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.outline.withValues(alpha: 0.12))),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            Icon(Icons.search, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: searchController, decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search on map...'), textInputAction: TextInputAction.search)),
          ]),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ChoiceChip(label: const Text('Shops'), selected: mode == SellerMode.shops, onSelected: (v) => onModeChanged(SellerMode.shops)),
          const SizedBox(width: 8),
          ChoiceChip(label: const Text('Producers'), selected: mode == SellerMode.producers, onSelected: (v) => onModeChanged(SellerMode.producers)),
        ]),
      ]),
    );
  }
}

class _MissingTokenState extends StatelessWidget {
  final VoidCallback onOpenSettings;
  const _MissingTokenState({required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.map_outlined, size: 48),
          const SizedBox(height: 12),
          Text('Map requires a Mapbox access token', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('Run with:\nflutter run --dart-define MAPBOX_ACCESS_TOKEN=YOUR_TOKEN', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton.icon(onPressed: onOpenSettings, icon: const Icon(Icons.settings), label: const Text('Open Settings')),
        ]),
      ),
    );
  }
}

class _WebMapFallback extends StatelessWidget {
  const _WebMapFallback();
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: const [
            Icon(Icons.public, size: 48),
            SizedBox(height: 12),
            Text('Map view limited on web', textAlign: TextAlign.center),
            SizedBox(height: 4),
            Text('3D available on mobile only', textAlign: TextAlign.center),
          ]),
        ),
      );
}

class _BottomSellersPanel extends rp.ConsumerWidget {
  final ValueChanged<Enterprise> onTapItem;
  const _BottomSellersPanel({required this.onTapItem});
  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    final items = ref.watch(mapControllerProvider).visibleItems;
    final isWide = MediaQuery.of(context).size.width > 900;
    final list = ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final e = items[i];
        return _SellerCard(enterprise: e, onTap: () => onTapItem(e));
      },
    );
    if (isWide) {
      return Positioned(right: 12, top: 100, bottom: 24, width: 360, child: _PanelFrame(title: 'Available sellers', child: list));
    }
    return DraggableScrollableSheet(
      minChildSize: 0.15,
      initialChildSize: 0.24,
      maxChildSize: 0.6,
      builder: (context, scrollController) => _PanelFrame(
        title: 'Available sellers',
        child: ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _SellerCard(enterprise: items[i], onTap: () => onTapItem(items[i])),
        ),
      ),
    );
  }
}

class _PanelFrame extends StatelessWidget {
  final String title;
  final Widget child;
  const _PanelFrame({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      elevation: 2,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      color: cs.surface,
      child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: Row(children: [Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)), const SizedBox(width: 8), const Icon(Icons.storefront)])),
        Expanded(child: child),
      ]),
    );
  }
}

class _SellerCard extends StatelessWidget {
  final Enterprise enterprise;
  final VoidCallback onTap;
  const _SellerCard({required this.enterprise, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.outline.withValues(alpha: 0.08))),
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          CircleAvatar(child: Icon(Icons.store, color: cs.primary)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(enterprise.name, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis), if ((enterprise.shortDescription ?? '').isNotEmpty) Text(enterprise.shortDescription!, style: Theme.of(context).textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis)])),
          const Icon(Icons.chevron_right),
        ]),
      ),
    );
  }
}

class _MapControls extends StatelessWidget {
  final VoidCallback onRecenter;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onToggle3D;
  final bool is3D;
  const _MapControls({required this.onRecenter, required this.onZoomIn, required this.onZoomOut, required this.onToggle3D, required this.is3D});
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      _ControlButton(icon: Icons.my_location, onPressed: onRecenter),
      const SizedBox(height: 8),
      _ControlButton(icon: Icons.add, onPressed: onZoomIn),
      const SizedBox(height: 8),
      _ControlButton(icon: Icons.remove, onPressed: onZoomOut),
      const SizedBox(height: 8),
      _ControlButton(icon: is3D ? Icons.view_in_ar : Icons.threed_rotation, label: is3D ? '2D' : '3D', onPressed: onToggle3D),
    ];
    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onPressed;
  const _ControlButton({required this.icon, required this.onPressed, this.label});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: cs.outline.withValues(alpha: 0.12))),
      child: InkWell(onTap: onPressed, borderRadius: BorderRadius.circular(10), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: cs.primary), if (label != null) ...[const SizedBox(width: 6), Text(label!, style: Theme.of(context).textTheme.labelLarge)],]))),
    );
  }
}
