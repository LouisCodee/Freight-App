import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';
import '../bookings/booking_history_shipper_screen.dart';
import '../profile/cargo_shipper_profile_screen.dart';
import 'enter_cargo_details_screen.dart';
import '../../widgets/route_string.dart';
import '../../widgets/status_chip.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'active_shipments_list_screen.dart';
import 'active_booking_tracker_screen.dart';

class CargoShipperHomeScreen extends StatefulWidget {
  const CargoShipperHomeScreen({super.key});

  @override
  State<CargoShipperHomeScreen> createState() => _CargoShipperHomeScreenState();
}

class _CargoShipperHomeScreenState extends State<CargoShipperHomeScreen> {
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
            _ShipperHomeTab(
              onBookTruck: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EnterCargoDetailsScreen(),
                ),
              ),
            ),
            const BookingHistoryShipperScreen(),
            const CargoShipperProfileScreen(),
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
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.business_outlined),
              selectedIcon: Icon(Icons.business_rounded),
              label: 'Company',
            ),
          ],
        ),
      ),
    );
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

class _ShipperHomeTab extends StatelessWidget {
  const _ShipperHomeTab({required this.onBookTruck});
  final VoidCallback onBookTruck;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookingModel>>(
      stream: BookingService().getShipperBookings(),
      builder: (context, snapshot) {
        final bookings = snapshot.data ?? [];
        final activeBookings = bookings
            .where((b) => b.status == 'in_transit' || b.status == 'confirmed')
            .toList();
        final recentActivity = bookings.take(5).toList();

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _ShipperHero(onBookTruck: onBookTruck)),
            SliverPadding(
              padding: const EdgeInsets.only(top: 20, bottom: 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _PromoBannerCarousel(),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active Shipments (${activeBookings.length})',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ActiveShipmentsListScreen(),
                              ),
                            );
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (activeBookings.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: const Center(
                          child: Text(
                            'No active shipments right now.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _ActiveShipmentCard(booking: activeBookings.first),
                    ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (recentActivity.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'No recent activity yet.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    ...recentActivity.map((b) {
                      IconData icon;
                      Color color;
                      String title;
                      String subtitle;

                      if (b.status == 'in_transit') {
                        icon = Icons.local_shipping_rounded;
                        color = AppTheme.primaryColor;
                        title = 'Shipment In Transit';
                        subtitle =
                            'Trip #${b.id.substring(0, 8).toUpperCase()} is on the way';
                      } else if (b.status == 'delivered') {
                        icon = Icons.inventory_2_rounded;
                        color = AppTheme.statusGreen;
                        title = 'Shipment Delivered';
                        subtitle =
                            'Trip #${b.id.substring(0, 8).toUpperCase()} arrived';
                      } else if (b.status == 'confirmed') {
                        icon = Icons.check_circle_rounded;
                        color = AppTheme.primaryColor;
                        title = 'Booking Confirmed';
                        subtitle = 'Your request was accepted';
                      } else if (b.status == 'cancelled') {
                        icon = Icons.cancel_rounded;
                        color = AppTheme.statusRed;
                        title = 'Booking Cancelled';
                        subtitle =
                            'Trip #${b.id.substring(0, 8).toUpperCase()} was cancelled';
                      } else {
                        icon = Icons.hourglass_top_rounded;
                        color = AppTheme.statusAmber;
                        title = 'Booking Pending';
                        subtitle = 'Waiting for carrier confirmation';
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _ActivityItem(
                          title: title,
                          subtitle: subtitle,
                          time: _timeAgo(b.createdAt),
                          icon: icon,
                          iconColor: color,
                        ),
                      );
                    }),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ShipperHero extends StatelessWidget {
  const _ShipperHero({required this.onBookTruck});
  final VoidCallback onBookTruck;

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
                'assets/images/home/speed_logistics.jpg',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.65),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Welcome back 👋',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                                  'assets/images/home/unsplash_3.jpg',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Ready to ship?',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Find reliable trucks for your cargo across Tanzania.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: onBookTruck,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: AppTheme.primaryColor,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Find a Truck Now',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryColor,
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
      },
    );
  }
}

class _ActiveShipmentCard extends StatelessWidget {
  const _ActiveShipmentCard({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(booking.carrierId)
          .get(),
      builder: (context, snapshot) {
        final carrierName = snapshot.hasData && snapshot.data!.exists
            ? snapshot.data!['name'] ?? 'Unknown Carrier'
            : 'Loading...';

        final routeLabel = booking.status == 'in_transit'
            ? 'In Transit'
            : 'Confirmed';
        final routeStatus = booking.status == 'in_transit'
            ? ChipStatus.info
            : ChipStatus.success;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  StatusChip(label: routeLabel, status: routeStatus),
                  const Spacer(),
                  Text(
                    '#${booking.id.substring(0, 8).toUpperCase()}',
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
                origin: booking.cargoDetails['origin'] ?? 'Unknown',
                destination: booking.cargoDetails['destination'] ?? 'Unknown',
                originLabel: 'Departed Oct 15',
                destinationLabel: 'ETA: Oct 16',
                lineHeight: 32,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      carrierName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ActiveBookingTrackerScreen(booking: booking),
                        ),
                      );
                    },
                    child: const Text('Track'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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

class _PromoBannerCarousel extends StatefulWidget {
  const _PromoBannerCarousel();

  @override
  State<_PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<_PromoBannerCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  final List<String> _banners = [
    'assets/images/home/global_trade.jpg',
    'assets/images/home/intermodal_train.jpg',
    'assets/images/home/olc_shipping.jpg',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  image: DecorationImage(
                    image: AssetImage(_banners[index]),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Exclusive\nShipping Rates\nThis Month',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentPage == index ? 20 : 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppTheme.primaryColor
                    : AppTheme.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
