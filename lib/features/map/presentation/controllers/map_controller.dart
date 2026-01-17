import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sellingapp/core/providers.dart';
import 'package:sellingapp/models/enterprise.dart';

enum SellerMode { shops, producers }

class MapState {
  final SellerMode mode;
  final String query;
  final Enterprise? selected;
  final bool is3D;
  final List<Enterprise> shops;
  final List<Enterprise> producers;

  const MapState({this.mode = SellerMode.shops, this.query = '', this.selected, this.is3D = false, this.shops = const [], this.producers = const []});

  MapState copyWith({SellerMode? mode, String? query, Enterprise? selected, bool? is3D, List<Enterprise>? shops, List<Enterprise>? producers, bool clearSelected = false}) => MapState(
        mode: mode ?? this.mode,
        query: query ?? this.query,
        selected: clearSelected ? null : (selected ?? this.selected),
        is3D: is3D ?? this.is3D,
        shops: shops ?? this.shops,
        producers: producers ?? this.producers,
      );

  List<Enterprise> get visibleItems {
    final base = mode == SellerMode.shops ? shops : producers;
    final filtered = base.where((e) => e.lat != null && e.lng != null).toList();
    if (query.isEmpty) return filtered;
    final q = query.toLowerCase();
    return filtered.where((e) => e.name.toLowerCase().contains(q) || (e.shortDescription ?? '').toLowerCase().contains(q)).toList();
  }
}

class MapController extends Notifier<MapState> {
  @override
  MapState build() => const MapState();

  Future<void> loadEnterprises() async {
    try {
      final repo = ref.read(shopRepositoryProvider);
      final results = await Future.wait([repo.listShops(), repo.listProducers()]);
      state = state.copyWith(shops: results[0], producers: results[1]);
    } catch (e) {
      debugPrint('Failed to load enterprises: $e');
    }
  }

  void setQuery(String q) => state = state.copyWith(query: q, clearSelected: true);
  void toggleMode(SellerMode m) => state = state.copyWith(mode: m, clearSelected: true);
  void setSelected(Enterprise? e) => state = state.copyWith(selected: e);
  void toggle3D() => state = state.copyWith(is3D: !state.is3D);
}

final mapControllerProvider = NotifierProvider<MapController, MapState>(MapController.new);
