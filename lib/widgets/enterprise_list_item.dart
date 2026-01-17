import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sellingapp/models/enterprise.dart';
import 'package:sellingapp/theme.dart';

/// Google Classroom-style card with scale animation and haptic feedback.
class EnterpriseListItem extends StatefulWidget {
  final Enterprise e;
  final VoidCallback? onTap;
  const EnterpriseListItem({super.key, required this.e, this.onTap});

  @override
  State<EnterpriseListItem> createState() => _EnterpriseListItemState();
}

class _EnterpriseListItemState extends State<EnterpriseListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _elevationAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();
  void _onTapUp(TapUpDetails _) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  void _onTap() {
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final e = widget.e;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              color: scheme.surface,
              elevation: _elevationAnimation.value,
              shadowColor: scheme.shadow.withOpacity(0.2),
              borderRadius: AppRadius.cardRadius,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _onTap,
                splashColor: scheme.primary.withOpacity(0.12),
                highlightColor: scheme.primary.withOpacity(0.06),
                splashFactory: InkSparkle.splashFactory,
                borderRadius: AppRadius.cardRadius,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.cardRadius,
                    border: Border.all(
                      color: scheme.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: _getAccentColor(e.id),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            child: e.bannerUrl != null
                                ? ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                    child: Image.network(
                                      e.bannerUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _buildPlaceholder(e.id),
                                    ),
                                  )
                                : _buildPlaceholder(e.id),
                          ),
                          // Gradient
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.4),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Avatar
                          Positioned(
                            left: 16,
                            bottom: -28,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: scheme.surface, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: scheme.primaryContainer,
                                backgroundImage: e.logoUrl != null
                                    ? NetworkImage(e.logoUrl!)
                                    : null,
                                child: e.logoUrl == null
                                    ? Icon(Icons.storefront_rounded,
                                        color: scheme.onPrimaryContainer, size: 28)
                                    : null,
                              ),
                            ),
                          ),
                          // Rating
                          if (e.rating != null)
                            Positioned(
                              right: 12,
                              top: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: scheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_rounded,
                                        size: 18, color: Colors.amber[700]),
                                    const SizedBox(width: 4),
                                    Text(
                                      e.rating!.toStringAsFixed(1),
                                      style: textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.name,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              e.shortDescription ?? 'Fresh products available',
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (e.pickupAvailable)
                                  _Chip(
                                    icon: Icons.store_rounded,
                                    label: 'Pickup',
                                    color: scheme.secondary,
                                  ),
                                if (e.deliveryAvailable)
                                  _Chip(
                                    icon: Icons.local_shipping_rounded,
                                    label: 'Delivery',
                                    color: scheme.tertiary,
                                  ),
                                if (e.reviewCount != null && e.reviewCount! > 0)
                                  _Chip(
                                    icon: Icons.reviews_rounded,
                                    label: '${e.reviewCount} reviews',
                                    color: scheme.primary,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder(String id) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getAccentColor(id),
            _getAccentColor(id).withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.storefront_rounded,
          size: 48,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Color _getAccentColor(String id) {
    final colors = [
      const Color(0xFF1A73E8),
      const Color(0xFF00796B),
      const Color(0xFF7B1FA2),
      const Color(0xFFE8710A),
      const Color(0xFF1E8E3E),
      const Color(0xFFC2185B),
      const Color(0xFF5C6BC0),
      const Color(0xFF00ACC1),
    ];
    return colors[id.hashCode.abs() % colors.length];
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
