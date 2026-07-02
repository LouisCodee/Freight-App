import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../services/listing_service.dart';
import '../../models/listing_model.dart';
import 'browse_trucks_map_screen.dart';
import 'truck_detail_screen.dart';

class BrowseTrucksListScreen extends StatelessWidget {
  final String? searchOrigin;
  final String? searchDestination;
  final String? searchCargoType;
  final DateTime? searchDate;

  const BrowseTrucksListScreen({
    super.key,
    this.searchOrigin,
    this.searchDestination,
    this.searchCargoType,
    this.searchDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainerLow,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: _SearchBar(),
          ),
          StreamBuilder<List<ListingModel>>(
            stream: ListingService().getAvailableListings(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load listings.\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              var listings = snapshot.data ?? [];
              
              // Filter based on search parameters
              if (searchOrigin != null && searchOrigin!.isNotEmpty) {
                listings = listings.where((l) => l.origin.toLowerCase().contains(searchOrigin!.toLowerCase())).toList();
              }
              if (searchDestination != null && searchDestination!.isNotEmpty) {
                listings = listings.where((l) => l.destination.toLowerCase().contains(searchDestination!.toLowerCase())).toList();
              }
              // Basic cargo type filter matching if provided
              if (searchCargoType != null && searchCargoType!.isNotEmpty) {
                // If ListingModel has cargoPreferences, we can check if it matches
                listings = listings.where((l) => l.cargoPreferences.isEmpty || l.cargoPreferences.any((pref) => pref.toLowerCase() == searchCargoType!.toLowerCase())).toList();
              }
              
              if (listings.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No trucks available right now.',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Check back soon — truck owners are adding listings.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            '${listings.length} Truck${listings.length == 1 ? '' : 's'} Available',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurface,
                            ),
                          ),
                        );
                      }
                      final listing = listings[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TruckCard(
                          listing: listing,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => TruckDetailScreen(listing: listing)),
                          ),
                        ),
                      );
                    },
                    childCount: listings.length + 1,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => BrowseTrucksMapScreen(
            searchOrigin: searchOrigin,
            searchDestination: searchDestination,
            searchCargoType: searchCargoType,
          )),
        ),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.map_rounded, color: Colors.white),
        label: const Text(
          'Map View',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppTheme.surfaceContainerLowest,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: AppTheme.onSurface),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        (searchOrigin != null && searchDestination != null && searchOrigin!.isNotEmpty && searchDestination!.isNotEmpty)
            ? '$searchOrigin → $searchDestination'
            : (searchOrigin != null && searchOrigin!.isNotEmpty) ? '$searchOrigin → Anywhere' 
            : (searchDestination != null && searchDestination!.isNotEmpty) ? 'Anywhere → $searchDestination'
            : 'All Available Trucks',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppTheme.onSurface,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list_rounded, color: AppTheme.onSurface),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceContainerLowest,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Search by truck type, owner...',
            hintStyle: TextStyle(
              fontFamily: 'Inter',
              color: AppTheme.outline,
            ),
            border: InputBorder.none,
            icon: Icon(Icons.search_rounded, color: AppTheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

class _TruckCard extends StatelessWidget {
  const _TruckCard({
    required this.listing,
    required this.onTap,
  });

  final ListingModel listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: Future.wait([
        FirebaseFirestore.instance.collection('trucks').doc(listing.truckId).get(),
        FirebaseFirestore.instance.collection('users').doc(listing.ownerId).get(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final truckDoc = snapshot.data![0];
        final userDoc = snapshot.data![1];
        final type = truckDoc.exists ? truckDoc['truckType'] : 'Unknown';
        final capacity = truckDoc.exists ? '${truckDoc['payloadCapacity']} Tons' : 'Unknown';
        final name = truckDoc.exists ? truckDoc['licensePlate'] : 'Unknown Truck';
        final owner = userDoc.exists ? userDoc['name'] : 'Unknown Owner';
        const rating = 4.8;
        const reviews = 124;
        final price = 'TZS ${listing.rate}';
        const eta = 'Available Now';

        return GestureDetector(
          onTap: onTap,
          child: Container(
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
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: const Icon(Icons.local_shipping_rounded,
                          color: AppTheme.primaryColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            owner,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 14, color: AppTheme.secondaryColor),
                              const SizedBox(width: 4),
                              Text(
                                '$rating ($reviews)',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SpecChip(icon: Icons.category_rounded, label: type),
                    _SpecChip(icon: Icons.scale_rounded, label: capacity),
                    _SpecChip(icon: Icons.schedule_rounded, label: eta),
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
                          'Estimated Price',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          price,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: const Text(
                        'Book',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SpecChip extends StatelessWidget {
  const _SpecChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}


