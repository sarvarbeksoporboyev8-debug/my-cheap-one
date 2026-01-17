import 'package:flutter/material.dart';
import 'package:sellingapp/models/enterprise.dart';

/// Reusable list item for displaying an Enterprise in lists.
class EnterpriseListItem extends StatelessWidget {
  final Enterprise e;
  final VoidCallback? onTap;
  const EnterpriseListItem({super.key, required this.e, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: scheme.surfaceContainerHighest,
                width: 64,
                height: 64,
                child: e.logoUrl == null
                    ? Icon(Icons.store, color: scheme.onSurfaceVariant)
                    : Image.network(e.logoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: scheme.onSurfaceVariant)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.name.isNotEmpty ? e.name : 'Listing', style: textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(e.shortDescription ?? 'Unknown seller', style: textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Wrap(spacing: 6, children: [
                  _Chip(icon: Icons.place, label: 'Near me'),
                  if (e.pickupAvailable) _Chip(icon: Icons.store_mall_directory, label: 'Pickup'),
                  if (e.deliveryAvailable) _Chip(icon: Icons.local_shipping, label: 'Delivery'),
                ])
              ]),
            )
          ]),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon; final String label;
  const _Chip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: scheme.onSurfaceVariant), const SizedBox(width: 4), Text(label, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant))]),
    );
  }
}
