import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/route_string.dart';
import '../../widgets/status_chip.dart';
import '../listing/create_listing_step_1_screen.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../services/booking_service.dart';
import '../../services/truck_service.dart';
import '../../models/booking_model.dart';
import '../../models/truck_model.dart';

import '../listing/my_listings_screen.dart';
import '../bookings/booking_requests_screen.dart';
import '../earnings/my_earnings_screen.dart';
import '../profile/truck_owner_profile_screen.dart';
import '../notifications/notifications_screen.dart';

String _formatCurrency(double amount) {
  if (amount >= 1000000) {
    return 'TZS ${(amount / 1000000).toStringAsFixed(1)}M';
  } else if (amount >= 1000) {
    return 'TZS ${(amount / 1000).toStringAsFixed(0)}K';
  }
  return 'TZS ${amount.toStringAsFixed(0)}';
}

class TruckOwnerHomeScreen extends StatefulWidget {
  const TruckOwnerHomeScreen({super.key});

  @override
  State<TruckOwnerHomeScreen> createState() => _TruckOwnerHomeScreenState();
}

class _TruckOwnerHomeScreenState extends State<TruckOwnerHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.surfaceContainerLow,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _HomeTab(
              onNewListing: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreateListingStep1Screen(),
                ),
              ),
            ),
            const MyListingsScreen(),
            const BookingRequestsScreen(),
            const MyEarningsScreen(),
            const TruckOwnerProfileScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt_rounded),
              label: 'Listings',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today_rounded),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Earnings',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Home Tab ───────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.onNewListing});
  final VoidCallback onNewListing;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookingModel>>(
      stream: BookingService().getCarrierBookings(),
      builder: (context, bookingSnapshot) {
        final bookings = bookingSnapshot.data ?? [];
        return FutureBuilder<List<TruckModel>>(
          future: TruckService().getMyTrucks(),
          builder: (context, truckSnapshot) {
            final trucks = truckSnapshot.data ?? [];
            
            double totalEarned = 0;
            double thisMonthEarned = 0;
            final now = DateTime.now();
            final pendingBookings = <BookingModel>[];
            BookingModel? activeBooking;
            int tripsThisMonth = 0;

            for (var b in bookings) {
              if (b.status == 'completed') {
                totalEarned += b.price;
                if (b.createdAt.year == now.year && b.createdAt.month == now.month) {
                  thisMonthEarned += b.price;
                  tripsThisMonth++;
                }
              } else if (b.status == 'pending') {
                pendingBookings.add(b);
              } else if (b.status == 'in_transit') {
                if (activeBooking == null) activeBooking = b;
              }
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _HeroHeader(
                    onNewListing: onNewListing,
                    totalEarned: _formatCurrency(totalEarned),
                    truckCount: trucks.length,
                    thisMonthEarned: _formatCurrency(thisMonthEarned),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const _PromoBanner(),
                      const SizedBox(height: 20),
                      _MetricGrid(
                        activeTripLabel: activeBooking != null ? 'Trip #${activeBooking.id.substring(0, 4)}' : 'No Trips',
                        activeTripStatus: activeBooking != null ? 'In Transit' : '-',
                        pendingCount: pendingBookings.length,
                        tripsThisMonth: tripsThisMonth,
                      ),
                      const SizedBox(height: 20),
                      _SectionHeader(title: 'Active Trip', action: 'View Details', onAction: () {}),
                      const SizedBox(height: 10),
                      if (activeBooking != null)
                        _ActiveTripCard(booking: activeBooking)
                      else
                        const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No active trips right now'))),
                      const SizedBox(height: 20),
                      _SectionHeader(title: 'Booking Requests', action: 'View All', onAction: () {}),
                      const SizedBox(height: 10),
                      if (pendingBookings.isEmpty)
                        const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No pending requests')))
                      else
                        ...pendingBookings.take(3).map((b) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _BookingRequestCard(booking: b))),
                      const SizedBox(height: 20),
                      _SectionHeader(title: 'Recent Activity', action: 'View All', onAction: () {}),
                      const SizedBox(height: 10),
                      ..._buildActivityItems(bookings),
                    ]),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> _buildActivityItems(List<BookingModel> bookings) {
    if (bookings.isEmpty) return [const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No recent activity')))];
    
    final sorted = List<BookingModel>.from(bookings)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return sorted.take(5).map((b) {
      String title = 'Update';
      String subtitle = 'Trip #${b.id.substring(0,4)}';
      IconData icon = Icons.info_outline;
      Color color = AppTheme.outline;
      
      if (b.status == 'completed') {
        title = 'Payment Received';
        subtitle = 'Trip #${b.id.substring(0,4)} — ${_formatCurrency(b.price)}';
        icon = Icons.check_circle_rounded;
        color = AppTheme.statusGreen;
      } else if (b.status == 'in_transit') {
        title = 'Trip Started';
        icon = Icons.local_shipping_rounded;
        color = AppTheme.primaryColor;
      } else if (b.status == 'pending') {
        title = 'New Request';
        subtitle = 'From Shipper';
        icon = Icons.pending_actions_rounded;
        color = AppTheme.statusAmber;
      }
      
      final diff = DateTime.now().difference(b.createdAt);
      String timeStr = '${diff.inHours}h ago';
      if (diff.inHours == 0) timeStr = '${diff.inMinutes}m ago';
      if (diff.inDays > 0) timeStr = '${diff.inDays}d ago';
      
      return _ActivityItem(
        title: title,
        subtitle: subtitle,
        time: timeStr,
        icon: icon,
        iconColor: color,
      );
    }).toList();
  }
}

// ─── Hero Header ─────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.onNewListing, required this.totalEarned, required this.truckCount, required this.thisMonthEarned});
  final VoidCallback onNewListing;
  final String totalEarned;
  final int truckCount;
  final String thisMonthEarned;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: AuthService().getCurrentUser(),
      builder: (context, snapshot) {
        final userName = snapshot.data?.name ?? '';
        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/home/scania_trucks.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.8),
                AppTheme.primaryColor,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                children: [
                  // Top bar
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Morning 👋',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userName,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification bell
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.secondaryContainer,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Avatar
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/images/home/unsplash_2.jpg',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Summary strip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _HeroStat(
                            label: 'Total Earned',
                            value: totalEarned,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        Expanded(
                          child: _HeroStat(
                            label: 'Active Trucks',
                            value: '$truckCount',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        Expanded(
                          child: _HeroStat(
                            label: 'This Month',
                            value: thisMonthEarned,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // New Listing button
                  GestureDetector(
                    onTap: onNewListing,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.secondaryContainer.withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Post New Listing',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
      }
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

// ─── Metric Grid ──────────────────────────────────────────────────────────────

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({
    required this.activeTripLabel,
    required this.activeTripStatus,
    required this.pendingCount,
    required this.tripsThisMonth,
  });

  final String activeTripLabel;
  final String activeTripStatus;
  final int pendingCount;
  final int tripsThisMonth;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricData(
        activeTripLabel,
        activeTripStatus,
        Icons.local_shipping_rounded,
        AppTheme.statusBlue,
        AppTheme.statusBlueContainer,
      ),
      _MetricData(
        '$pendingCount Requests',
        'Pending',
        Icons.pending_actions_rounded,
        AppTheme.statusAmber,
        AppTheme.statusAmberContainer,
      ),
      _MetricData(
        '4.8 ★',
        'My Rating',
        Icons.star_rounded,
        AppTheme.secondaryColor,
        AppTheme.secondaryContainer.withValues(alpha: 0.15),
      ),
      _MetricData(
        '$tripsThisMonth Trips',
        'This Month',
        Icons.route_rounded,
        AppTheme.statusGreen,
        AppTheme.statusGreenContainer,
      ),
    ];

    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: metrics.map((m) => _MetricCard(data: m)).toList(),
    );
  }
}

class _MetricData {
  const _MetricData(
    this.value,
    this.label,
    this.icon,
    this.iconColor,
    this.iconBg,
  );
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});
  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 18),
          ),
          const Spacer(),
          Text(
            data.value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Active Trip Card ─────────────────────────────────────────────────────────

class _ActiveTripCard extends StatelessWidget {
  const _ActiveTripCard({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            height: 90,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/home/africa_dev.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const StatusChip(
                      label: 'In Transit',
                      status: ChipStatus.info,
                    ),
                    const Spacer(),
                    Text(
                      'Trip #${booking.id.substring(0, 4)}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RouteString(
                  origin: booking.cargoDetails['origin'] ?? 'Origin',
                  destination: booking.cargoDetails['destination'] ?? 'Destination',
                  originLabel: 'PICKUP',
                  destinationLabel: 'DELIVERY',
                  lineHeight: 32,
                ),
                const SizedBox(height: 16),
                // Progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Trip Progress',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'In Progress',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.secondaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: null,
                        color: AppTheme.secondaryContainer,
                        backgroundColor: AppTheme.surfaceContainer,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _TripInfoChip(
                      icon: Icons.paid_outlined,
                      label: _formatCurrency(booking.price),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripInfoChip extends StatelessWidget {
  const _TripInfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Booking Request Card ─────────────────────────────────────────────────────

class _BookingRequestCard extends StatelessWidget {
  const _BookingRequestCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final shipperName = 'Shipper'; // Would be fetched from user profile in a real app, fallback to 'Shipper'
    final route = '${booking.cargoDetails['origin'] ?? ''} → ${booking.cargoDetails['destination'] ?? ''}';
    final cargo = booking.cargoDetails['type'] ?? 'Cargo';
    final weight = '${booking.cargoDetails['weight'] ?? 0} Tons';
    final price = _formatCurrency(booking.price);
    
    final diff = DateTime.now().difference(booking.createdAt);
    String timeAgo = '${diff.inHours}h ago';
    if (diff.inHours == 0) timeAgo = '${diff.inMinutes}m ago';
    if (diff.inDays > 0) timeAgo = '${diff.inDays}d ago';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.business_rounded,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shipperName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.route_rounded,
                size: 14,
                color: AppTheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  route,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.inventory_2_rounded,
                size: 14,
                color: AppTheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '$cargo · $weight',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 38),
                    side: const BorderSide(color: AppTheme.outlineVariant),
                    foregroundColor: AppTheme.onSurfaceVariant,
                  ),
                  child: const Text(
                    'Decline',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 38),
                    backgroundColor: AppTheme.secondaryContainer,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onAction,
  });
  final String title;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurface,
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            action,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.iconColor,
  });
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppTheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Placeholder tab ─────────────────────────────────────────────────────────

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 52, color: AppTheme.outlineVariant),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Coming soon',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppTheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        image: DecorationImage(
          image: const AssetImage('assets/images/home/global_trade.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.6),
            BlendMode.darken,
          ),
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: AppTheme.secondaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'FreightMatch Rewards',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.secondaryColor.withValues(alpha: 0.9),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Unlock Premium Benefits',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Complete 5 more trips this month to earn Priority Booking status.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
