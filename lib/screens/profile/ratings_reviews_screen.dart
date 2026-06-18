import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RatingsReviewsScreen extends StatelessWidget {
  const RatingsReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainerLow,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _OverallRatingCard(),
                  const SizedBox(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Reviews',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      Text(
                        'Most Recent',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ReviewCard(
                  name: 'Coastal Traders Ltd',
                  date: 'Oct 10, 2026',
                  rating: 5,
                  comment:
                      'Excellent service. The driver was very professional and the cargo arrived on time without any issues.',
                ),
                const SizedBox(height: 12),
                _ReviewCard(
                  name: 'Tanzania Breweries',
                  date: 'Sep 25, 2026',
                  rating: 4,
                  comment:
                      'Good experience overall. Slight delay at the weighbridge but communication was clear throughout the trip.',
                ),
                const SizedBox(height: 12),
                _ReviewCard(
                  name: 'Apex Agri Ltd',
                  date: 'Sep 10, 2026',
                  rating: 5,
                  comment:
                      'Very reliable truck owner. The flatbed was in great condition. Will definitely book again.',
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppTheme.surfaceContainerLowest,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: AppTheme.onSurface),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Ratings & Reviews',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppTheme.onSurface,
        ),
      ),
      centerTitle: true,
    );
  }
}

class _OverallRatingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Column(
            children: [
              const Text(
                '4.8',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                    color: AppTheme.secondaryColor,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Based on 124 reviews',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              children: [
                _RatingBar(stars: 5, percentage: 0.8),
                const SizedBox(height: 4),
                _RatingBar(stars: 4, percentage: 0.15),
                const SizedBox(height: 4),
                _RatingBar(stars: 3, percentage: 0.05),
                const SizedBox(height: 4),
                _RatingBar(stars: 2, percentage: 0.0),
                const SizedBox(height: 4),
                _RatingBar(stars: 1, percentage: 0.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({required this.stars, required this.percentage});
  final int stars;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          stars.toString(),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.star_rounded, size: 10, color: AppTheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: AppTheme.surfaceContainerLow,
              color: AppTheme.secondaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.name,
    required this.date,
    required this.rating,
    required this.comment,
  });

  final String name;
  final String date;
  final int rating;
  final String comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: AppTheme.secondaryColor,
                size: 16,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppTheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
