import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../widgets/route_string.dart';
import '../../widgets/status_chip.dart';
import 'booking_completed_screen.dart';
import '../../models/booking_model.dart';
import '../../models/truck_model.dart';
import '../../services/truck_service.dart';

class ActiveBookingTrackerScreen extends StatelessWidget {
  const ActiveBookingTrackerScreen({super.key, required this.booking});
  final BookingModel booking;

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
                  _MapPlaceholder(context: context, booking: booking),
                  const SizedBox(height: 16),
                  _TrackerStatusCard(booking: booking),
                  const SizedBox(height: 16),
                  _TruckDriverCard(booking: booking),
                  const SizedBox(height: 32),
                ],
              ),
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
        'Track Shipment',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppTheme.onSurface,
        ),
      ),
      centerTitle: true,
      actions: const [
        StatusChip(label: 'In Transit', status: ChipStatus.info),
        SizedBox(width: 16),
      ],
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.context, required this.booking});
  final BuildContext context;
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => BookingCompletedScreen(booking: booking)),
      ),
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppTheme.cardShadow,
          image: const DecorationImage(
            image: NetworkImage(
                'https://maps.googleapis.com/maps/api/staticmap?center=-6.8045,39.2831&zoom=10&size=600x400&maptype=roadmap&key=AIzaSyAOVYRIgupAurZup5y1PRh8Ismb1A3lLao'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_rounded, color: AppTheme.secondaryColor),
                SizedBox(width: 8),
                Text(
                  'Tap Map to Complete Trip',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackerStatusCard extends StatelessWidget {
  const _TrackerStatusCard({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final origin = booking.cargoDetails['origin'] ?? 'Unknown Origin';
    final destination = booking.cargoDetails['destination'] ?? 'Unknown Destination';

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
          const Text(
            'Shipment Progress',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          RouteString(
            origin: origin,
            destination: destination,
            originLabel: 'Picked up recently',
            destinationLabel: 'ETA: Pending',
            lineHeight: 40,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimated Arrival',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Pending update',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
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

class _TruckDriverCard extends StatelessWidget {
  const _TruckDriverCard({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: Future.wait([
        FirebaseFirestore.instance.collection('users').doc(booking.carrierId).get(),
        FirebaseFirestore.instance.collection('trucks').doc(booking.listingId).get(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final driverDoc = snapshot.data![0];
        final driverName = driverDoc.exists ? driverDoc['name'] : 'Unknown Driver';
        final driverPhone = driverDoc.exists ? driverDoc['phoneNumber'] : '';

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
              const Text(
                'Vehicle & Driver',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: AppTheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driverName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        if (driverPhone.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            driverPhone,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.phone_rounded,
                        color: AppTheme.primaryColor),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppTheme.outlineVariant),
              const SizedBox(height: 16),
              FutureBuilder<TruckModel?>(
                future: TruckService().getTruckByOwnerId(booking.carrierId),
                builder: (context, truckSnapshot) {
                  final truckName = truckSnapshot.data?.truckType ?? 'Unknown Truck';
                  final truckPlate = truckSnapshot.data?.licensePlate ?? 'N/A';
                  return Row(
                    children: [
                      const Icon(Icons.local_shipping_rounded,
                          color: AppTheme.onSurfaceVariant, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          truckName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          truckPlate,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  );
                }
              ),
            ],
          ),
        );
      }
    );
  }
}
