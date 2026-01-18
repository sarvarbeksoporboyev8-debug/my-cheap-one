import 'package:flutter/material.dart';

class HomeCategory {
  final String slug;
  final String title;
  final IconData icon;
  const HomeCategory({required this.slug, required this.title, required this.icon});
}

/// Predefined generic marketplace categories
const homeCategories = <HomeCategory>[
  HomeCategory(slug: 'popular', title: 'Popular', icon: Icons.star_rate_rounded),
  HomeCategory(slug: 'food', title: 'Food', icon: Icons.restaurant_menu),
  HomeCategory(slug: 'retail', title: 'Retail', icon: Icons.store),
  HomeCategory(slug: 'agriculture', title: 'Agriculture', icon: Icons.eco),
  HomeCategory(slug: 'supplies', title: 'Supplies', icon: Icons.inventory_2),
  HomeCategory(slug: 'services', title: 'Services', icon: Icons.home_repair_service),
  HomeCategory(slug: 'pharmacy', title: 'Pharmacy', icon: Icons.medical_services),
  HomeCategory(slug: 'other', title: 'Other', icon: Icons.more_horiz),
];

class CategoryStrip extends StatefulWidget {
  final ValueChanged<HomeCategory> onCategoryTap;
  const CategoryStrip({super.key, required this.onCategoryTap});

  @override
  State<CategoryStrip> createState() => _CategoryStripState();
}

class _CategoryStripState extends State<CategoryStrip> {
  String selected = 'popular';
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemBuilder: (_, i) {
          final c = homeCategories[i];
          final isSel = c.slug == selected;
          final bg = isSel ? scheme.primaryContainer : scheme.surfaceContainerHigh;
          final iconColor = isSel ? scheme.primary : scheme.onSurfaceVariant;
          final labelStyle = textTheme.bodyMedium!.copyWith(
            fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
            color: isSel ? scheme.primary : scheme.onSurface,
          );
          return InkWell(
            onTap: () {
              setState(() => selected = c.slug);
              widget.onCategoryTap(c);
            },
            borderRadius: BorderRadius.circular(48),
            child: Column(children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(c.icon, color: iconColor, size: 30),
              ),
              const SizedBox(height: 8),
              SizedBox(width: 80, child: Text(c.title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: labelStyle)),
            ]),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: homeCategories.length,
      ),
    );
  }
}
