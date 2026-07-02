import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_chip.dart';
import 'create_listing_step_1_screen.dart';
import 'edit_listing_screen.dart';
import '../../models/listing_model.dart';
import '../../models/truck_model.dart';
import '../../services/listing_service.dart';
import '../../services/truck_service.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  late Future<List<ListingModel>> _listingsFuture;

  @override
  void initState() {
    super.initState();
    _listingsFuture = ListingService().getMyListings();
  }

  void _refreshListings() {
    setState(() {
      _listingsFuture = ListingService().getMyListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainerLow,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: FutureBuilder<List<ListingModel>>(
              future: _listingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    )),
                  );
                }
                final listings = snapshot.data ?? [];
                if (listings.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No listings found. Create one!'),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ListingCard(
                          listing: listings[index],
                          onEdit: _refreshListings,
                        ),
                      );
                    },
                    childCount: listings.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateListingStep1Screen()),
        ),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'New Listing',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
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
        'My Listings',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppTheme.onSurface,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: AppTheme.onSurface),
          onPressed: () {},
        ),
      ],
    );
  }
}

String _formatCurrency(double amount) {
  if (amount >= 1000000) {
    return 'TZS ${(amount / 1000000).toStringAsFixed(1)}M';
  } else if (amount >= 1000) {
    return 'TZS ${(amount / 1000).toStringAsFixed(0)}K';
  }
  return 'TZS ${amount.toStringAsFixed(0)}';
}

String _pricingLabel(String model) {
  switch (model) {
    case 'per_ton':
      return 'Ton';
    case 'per_trip':
      return 'Trip';
    case 'per_day':
      return 'Day';
    default:
      return 'Ton';
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing, required this.onEdit});

  final ListingModel listing;
  final VoidCallback onEdit;

  ChipStatus get _statusType {
    // Determine status from dates or hardcoded for now
    return ChipStatus.success;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TruckModel?>(
      future: TruckService().getTruckById(listing.truckId),
      builder: (context, snapshot) {
        final truck = snapshot.data;
        final title = truck != null ? '${truck.truckType} — ${truck.payloadCapacity} Tons' : 'Loading Truck...';
        final route = '${listing.origin} → ${listing.destination}';
        final price = '${_formatCurrency(listing.rate)} / ${_pricingLabel(listing.pricingModel)}';
        
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.route_rounded,
                                size: 14, color: AppTheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              route,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  StatusChip(label: 'Active', status: _statusType),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppTheme.outlineVariant),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rate',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        price,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _StatIndicator(icon: Icons.visibility_rounded, count: 0),
                      const SizedBox(width: 16),
                      _StatIndicator(
                        icon: Icons.local_shipping_rounded,
                        count: 0,
                        highlight: false,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final result = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                              builder: (_) => EditListingScreen(listing: listing)),
                        );
                        if (result == true) onEdit();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.outlineVariant),
                        foregroundColor: AppTheme.onSurface,
                      ),
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('View Requests'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}

class _StatIndicator extends StatelessWidget {
  const _StatIndicator({
    required this.icon,
    required this.count,
    this.highlight = false,
  });

  final IconData icon;
  final int count;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlight
            ? AppTheme.statusAmberContainer
            : AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: highlight ? AppTheme.statusAmber : AppTheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: highlight ? AppTheme.statusAmber : AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
