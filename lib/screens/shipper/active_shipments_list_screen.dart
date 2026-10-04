import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/route_string.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import 'active_booking_tracker_screen.dart';

class ActiveShipmentsListScreen extends StatelessWidget {
  const ActiveShipmentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainerLowest,
        title: const Text(
          'Active Shipments',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurface,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppTheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: BookingService().getShipperBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allBookings = snapshot.data ?? [];
          final activeBookings = allBookings
              .where((b) => b.status == 'pending' || b.status == 'in_transit' || b.status == 'confirmed')
              .toList();

          if (activeBookings.isEmpty) {
            return const Center(
              child: Text(
                'No active shipments at the moment.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeBookings.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ShipmentListItemCard(booking: activeBookings[index]),
              );
            },
          );
        },
      ),
    );
  }
}

class _ShipmentListItemCard extends StatelessWidget {
  const _ShipmentListItemCard({required this.booking});
  final BookingModel booking;

  Future<void> _cancelBooking(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Request', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to cancel this booking request?', style: TextStyle(fontFamily: 'Inter')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes, Cancel', style: TextStyle(color: AppTheme.statusRed)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await BookingService().updateBookingStatus(booking.id, 'cancelled');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking request cancelled successfully.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel booking: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(booking.carrierId).get(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final carrierName = data?['name'] ?? 'Pending Carrier';

        ChipStatus chipStatus;
        String statusLabel;
        if (booking.status == 'in_transit') {
          chipStatus = ChipStatus.info;
          statusLabel = 'In Transit';
        } else if (booking.status == 'confirmed') {
          chipStatus = ChipStatus.success;
          statusLabel = 'Confirmed';
        } else {
          chipStatus = ChipStatus.warning;
          statusLabel = 'Pending';
        }

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
                    '#${booking.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  StatusChip(label: statusLabel, status: chipStatus),
                ],
              ),
              const SizedBox(height: 16),
              RouteString(
                origin: booking.cargoDetails['origin'] ?? 'Unknown Origin',
                destination: booking.cargoDetails['destination'] ?? 'Unknown Destination',
                originLabel: 'Departure',
                destinationLabel: 'Destination',
                lineHeight: 32,
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppTheme.outlineVariant),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Icon(Icons.person_rounded, size: 18, color: AppTheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          carrierName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        Text(
                          'TZS ${booking.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (booking.status == 'pending') ...[
                    OutlinedButton(
                      onPressed: () => _cancelBooking(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.statusRed,
                        side: const BorderSide(color: AppTheme.statusRed),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ] else ...[
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ActiveBookingTrackerScreen(booking: booking),
                          ),
                        );
                      },
                      child: const Text('Track'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}
