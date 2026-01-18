import 'package:flutter/material.dart';
import 'package:sellingapp/models/enterprise.dart';

// Unified height for the Popular preview carousel - increased for larger cards
const double kPopularCardHeight = 260;

class HorizontalListingCarousel extends StatelessWidget {
  final List<Enterprise> items;
  final void Function(Enterprise) onTap;
  const HorizontalListingCarousel({super.key, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    // Calculate card width to fit ~2.5 cards on screen (showing partial 3rd)
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48) / 2.5; // 48 = padding (12*2) + gaps
    
    return SizedBox(
      height: kPopularCardHeight,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final e = items[i];
          return InkWell(
            onTap: () => onTap(e),
            child: SizedBox(
              width: cardWidth,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    height: 140,
                    width: double.infinity,
                    child: e.logoUrl == null
                        ? Icon(Icons.image, size: 48, color: scheme.onSurfaceVariant)
                        : Image.network(e.logoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, size: 48, color: scheme.onSurfaceVariant)),
                  ),
                ),
                const SizedBox(height: 10),
                Text(e.name.isNotEmpty ? e.name : 'Listing', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis, softWrap: true),
                const SizedBox(height: 2),
                Text(e.shortDescription ?? 'Unknown seller', style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: true),
                const SizedBox(height: 6),
                // Keep chips on a single horizontal line to prevent vertical growth
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: const [
                    _MiniChip(icon: Icons.place, label: 'Near me'),
                    SizedBox(width: 8),
                    _MiniChip(icon: Icons.timer, label: 'Ends soon'),
                  ]),
                )
              ]),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: items.length,
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon; final String label;
  const _MiniChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: scheme.onSurfaceVariant), const SizedBox(width: 5), Text(label, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant))]),
    );
  }
}
