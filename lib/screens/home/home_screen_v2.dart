import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:go_router/go_router.dart';
import 'package:sellingapp/nav.dart';
import 'package:sellingapp/core/strings.dart';
import 'package:sellingapp/screens/home/home_providers.dart';
import 'package:sellingapp/screens/home/widgets/category_strip.dart';
import 'package:sellingapp/screens/home/widgets/featured_listing_carousel.dart';
import 'package:sellingapp/screens/home/widgets/home_top_bar.dart';
import 'package:sellingapp/screens/home/widgets/horizontal_listing_carousel.dart';
import 'package:sellingapp/screens/home/widgets/section_header_row.dart';
import 'package:sellingapp/screens/home/widgets/urgency_summary_card.dart';

class HomeScreenV2 extends rp.ConsumerWidget {
  const HomeScreenV2({super.key});

  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    final popularAsync = ref.watch(homePopularListingsProvider);
    final featuredAsync = ref.watch(homeFeaturedListingsProvider);
    final padding = const EdgeInsets.symmetric(vertical: 12);
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: HomeTopBar(
                locationName: 'Near me',
                infoText: '20 km',
                onLocationTap: () {
                  // Placeholder: open a bottom sheet in the future
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Location picker coming soon'), backgroundColor: scheme.primary));
                },
                onInfoTap: () {},
                onBellTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications coming soon'))),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(padding: padding, child: CategoryStrip(onCategoryTap: (c) {
              if (c.slug == 'popular') return; // stay on home
              context.push(AppRoutes.categoryBrowsePath(c.slug), extra: {'title': c.title});
            })),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 4)),
          SliverToBoxAdapter(
            child: SectionHeaderRow(title: 'Popular', actionText: 'All', onAction: () => context.push(AppRoutes.categoryBrowsePath('popular'), extra: {'title': 'Popular'})),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: popularAsync.when(
                data: (items) => HorizontalListingCarousel(items: items, onTap: (e) => context.push('/shops/${e.id}')),
                loading: () => SizedBox(
                  height: kPopularCardHeight,
                  child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), itemBuilder: (_, __) => _cardSkeleton(context), separatorBuilder: (_, __) => const SizedBox(width: 12), itemCount: 5),
                ),
                error: (e, st) => Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('Failed to load: $e')),
              ),
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 8)),
          SliverToBoxAdapter(child: SectionHeaderRow(title: 'Urgent Sale')),
          SliverToBoxAdapter(child: const SizedBox(height: 6)),
          SliverToBoxAdapter(child: const UrgencySummaryCard()),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(child: SectionHeaderRow(title: AppStrings.featuredSectionTitle)),
          SliverToBoxAdapter(
            child: featuredAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(AppStrings.noFeaturedDeals, style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: FeaturedListingCarousel(items: items, onTap: (e) => context.push('/shops/${e.id}')),
                );
              },
              loading: () => _featuredSkeleton(context),
              error: (e, st) => Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('Failed to load: $e')),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ]),
      ),
    );
  }

  Widget _cardSkeleton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48) / 2.5;
    return SizedBox(
        width: cardWidth,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(borderRadius: BorderRadius.circular(14), child: Container(height: 140, color: Theme.of(context).colorScheme.surfaceContainerHighest)),
          const SizedBox(height: 10),
          Container(height: 14, width: cardWidth * 0.8, color: Theme.of(context).colorScheme.surfaceContainerHighest),
          const SizedBox(height: 6),
          Container(height: 12, width: cardWidth * 0.6, color: Theme.of(context).colorScheme.surfaceContainerHighest),
        ]),
      );
  }

  Widget _featuredSkeleton(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(children: [
          ClipRRect(borderRadius: BorderRadius.circular(16), child: Container(height: 250, color: Theme.of(context).colorScheme.surfaceContainerHighest)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => Container(margin: const EdgeInsets.symmetric(horizontal: 3), width: 6, height: 6, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(3))))),
        ]),
      );
}
