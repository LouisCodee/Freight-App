import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_chip.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import 'booking_request_detail_screen.dart';

class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({super.key});
  @override
  State<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainerLow,
      body: Column(
        children: [
          // Header
          Container(
            color: AppTheme.surfaceContainerLowest,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerLow,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: AppTheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Booking Requests',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.statusAmberContainer,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: const Text('5 New',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.statusAmber,
                              )),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: AppTheme.onSurfaceVariant,
                    indicatorColor: AppTheme.secondaryContainer,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'Pending'),
                      Tab(text: 'Accepted'),
                      Tab(text: 'Declined'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: StreamBuilder<List<BookingModel>>(
              stream: BookingService().getCarrierBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final bookings = snapshot.data ?? [];
                final pending = bookings.where((b) => b.status == 'pending').toList();
                final accepted = bookings.where((b) => b.status == 'confirmed' || b.status == 'in_transit' || b.status == 'delivered').toList();
                final declined = bookings.where((b) => b.status == 'cancelled').toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _RequestList(
                      requests: pending,
                      emptyMessage: 'No pending requests',
                    ),
                    _RequestList(
                      requests: accepted,
                      emptyMessage: 'No accepted bookings yet',
                    ),
                    _RequestList(
                      requests: declined,
                      emptyMessage: 'No declined requests',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  const _RequestList({required this.requests, required this.emptyMessage});
  final List<BookingModel> requests;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return _EmptyState(icon: Icons.inbox_rounded, message: emptyMessage);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final b = requests[i];
        return _RequestCard(
          booking: b,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => BookingRequestDetailScreen(booking: b)),
          ),
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.booking, required this.onTap});
  final BookingModel booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(booking.shipperId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
        final userDoc = snapshot.data!;
        final shipperName = userDoc.exists ? userDoc['name'] : 'Unknown Shipper';
        final price = 'TZS ${booking.price}';
        final statusLabel = booking.status.toUpperCase();
        final status = booking.status == 'pending' ? ChipStatus.warning : booking.status == 'cancelled' ? ChipStatus.error : ChipStatus.success;

        return GestureDetector(
          onTap: onTap,
          child: Container(
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.business_rounded,
                      color: AppTheme.primaryColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shipperName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurface,
                          )),
                      Text('Just now',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppTheme.onSurfaceVariant,
                          )),
                    ],
                  ),
                ),
                StatusChip(label: statusLabel, status: status),
              ],
            ),
            const SizedBox(height: 10),
            _InfoRow(icon: Icons.route_rounded, text: '${booking.cargoDetails['origin'] ?? ''} → ${booking.cargoDetails['destination'] ?? ''}'),
            const SizedBox(height: 4),
            _InfoRow(icon: Icons.inventory_2_rounded, text: '${booking.cargoDetails['type'] ?? 'Cargo'} — ${booking.cargoDetails['weight'] ?? 0} Tons'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(price,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.secondaryColor,
                    )),
                if (status == ChipStatus.warning)
                  Row(
                    children: [
                      _SmallButton(
                        label: 'Decline',
                        outlined: true,
                        onTap: () {
                          BookingService().updateBookingStatus(booking.id, 'cancelled');
                        },
                      ),
                      const SizedBox(width: 8),
                      _SmallButton(
                        label: 'Accept', 
                        onTap: () {
                          BookingService().updateBookingStatus(booking.id, 'confirmed');
                        }
                      ),
                    ],
                  )
                else
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppTheme.outline),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppTheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppTheme.onSurface,
              )),
        ),
      ],
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton(
      {required this.label, required this.onTap, this.outlined = false});
  final String label;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : AppTheme.secondaryContainer,
          border: Border.all(
            color: outlined
                ? AppTheme.outlineVariant
                : AppTheme.secondaryContainer,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Text(label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: outlined ? AppTheme.onSurfaceVariant : Colors.white,
            )),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppTheme.outlineVariant),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: AppTheme.onSurfaceVariant,
              )),
        ],
      ),
    );
  }
}
