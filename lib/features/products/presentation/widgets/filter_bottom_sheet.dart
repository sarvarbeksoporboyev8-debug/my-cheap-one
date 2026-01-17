import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:sellingapp/models/filters.dart';
import 'package:sellingapp/theme.dart';

typedef OnApply = void Function(Set<String> taxonIds, Set<String> propertyIds);

class FilterModalBottomSheet extends rp.ConsumerStatefulWidget {
  final List<Taxon> taxons;
  final List<PropertyTag> properties;
  final Set<String> selectedTaxons;
  final Set<String> selectedProperties;
  final OnApply onApply;
  const FilterModalBottomSheet({super.key, required this.taxons, required this.properties, required this.selectedTaxons, required this.selectedProperties, required this.onApply});

  @override
  rp.ConsumerState<FilterModalBottomSheet> createState() => _FilterModalBottomSheetState();
}

class _FilterModalBottomSheetState extends rp.ConsumerState<FilterModalBottomSheet> {
  late Set<String> _taxonIds;
  late Set<String> _propertyIds;

  @override
  void initState() {
    super.initState();
    _taxonIds = {...widget.selectedTaxons};
    _propertyIds = {...widget.selectedProperties};
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Filters', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text('Categories', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final t in widget.taxons)
              FilterChip(
                label: Text(t.name),
                selected: _taxonIds.contains(t.id),
                onSelected: (_) => setState(() {
                  if (_taxonIds.contains(t.id)) {
                    _taxonIds.remove(t.id);
                  } else {
                    _taxonIds.add(t.id);
                  }
                }),
              ),
          ]),
          const SizedBox(height: 16),
          Text('Properties', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final p in widget.properties)
              FilterChip(
                label: Text(p.name),
                selected: _propertyIds.contains(p.id),
                onSelected: (_) => setState(() {
                  if (_propertyIds.contains(p.id)) {
                    _propertyIds.remove(p.id);
                  } else {
                    _propertyIds.add(p.id);
                  }
                }),
              ),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            OutlinedButton.icon(
              onPressed: () => setState(() {
                _taxonIds.clear();
                _propertyIds.clear();
              }),
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear'),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () {
                widget.onApply(_taxonIds, _propertyIds);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('Apply'),
            ),
          ])
        ]),
      ),
    );
  }
}
