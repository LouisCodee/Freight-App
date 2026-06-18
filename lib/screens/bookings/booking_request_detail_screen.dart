import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../widgets/route_string.dart';
import '../../widgets/status_chip.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';

String _formatCurrency(double amount) {
  if (amount >= 1000000) {
    return 'TZS ${(amount / 1000000).toStringAsFixed(1)}M';
  } else if (amount >= 1000) {
    return 'TZS ${(amount / 1000).toStringAsFixed(0)}K';
  }
  return 'TZS ${amount.toStringAsFixed(0)}';
}

class BookingRequestDetailScreen extends StatelessWidget {
  const BookingRequestDetailScreen({super.key, required this.booking});
  final BookingModel booking;

  ChipStatus get _chipStatus {
    switch (booking.status) {
      case 'pending':
        return ChipStatus.warning;
      case 'confirmed':
      case 'in_transit':
      case 'delivered':
        return ChipStatus.success;
      default:
        return ChipStatus.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShipperProfileCard(shipperId: booking.shipperId),
                  const SizedBox(height: 16),
                  _RouteAndCargoDetails(booking: booking),
                  const SizedBox(height: 16),
                  _FinancialSummary(price: booking.price),
                  const SizedBox(height: 32),
                  if (booking.status == 'pending')
                    _ActionButtons(booking: booking),
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
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: AppTheme.onSurface),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Request Details',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppTheme.onSurface,
        ),
      ),
      centerTitle: true,
      actions: [
        StatusChip(label: booking.status.toUpperCase(), status: _chipStatus),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _ShipperProfileCard extends StatelessWidget {
  const _ShipperProfileCard({required this.shipperId});
  final String shipperId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(shipperId).get(),
      builder: (context, snapshot) {
        final name = snapshot.hasData && snapshot.data!.exists
            ? snapshot.data!['name'] ?? 'Unknown Shipper'
            : 'Loading...';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.business_rounded,
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
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 16, color: AppTheme.secondaryColor),
                        const SizedBox(width: 4),
                        const Text(
                          'Verified Shipper',
                          style: TextStyle(
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
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chat_bubble_outline_rounded,
                    color: AppTheme.primaryColor),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RouteAndCargoDetails extends StatelessWidget {
  const _RouteAndCargoDetails({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final cargo = booking.cargoDetails;
    final origin = cargo['origin'] ?? '';
    final destination = cargo['destination'] ?? '';
    final cargoType = cargo['type'] ?? 'General';
    final weight = cargo['weight']?.toString() ?? '—';
    final pickupDate = cargo['pickupDate'] ?? booking.createdAt.toString().split(' ')[0];
    final notes = cargo['notes'] ?? 'None';

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
            'Route Information',
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
            originLabel: 'PICKUP',
            destinationLabel: 'DELIVERY',
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: AppTheme.outlineVariant),
          const SizedBox(height: 20),
          const Text(
            'Cargo Details',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(label: 'Cargo Type', value: cargoType),
          const SizedBox(height: 8),
          _DetailRow(label: 'Weight', value: '$weight Tons'),
          const SizedBox(height: 8),
          _DetailRow(label: 'Pickup Date', value: pickupDate),
          const SizedBox(height: 8),
          _DetailRow(label: 'Special Notes', value: notes),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _FinancialSummary extends StatelessWidget {
  const _FinancialSummary({required this.price});
  final double price;

  @override
  Widget build(BuildContext context) {
    final fee = price * 0.05;
    final earned = price - fee;

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
            'Payment Details',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Offer',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              Text(
                _formatCurrency(price),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Platform Fee (5%)',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              Text(
                '- ${_formatCurrency(fee)}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppTheme.statusRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.outlineVariant),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'You Earn',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
              Text(
                _formatCurrency(earned),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.statusGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              BookingService().updateBookingStatus(booking.id, 'cancelled');
              Navigator.of(context).pop();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppTheme.statusRed),
              foregroundColor: AppTheme.statusRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
            child: const Text(
              'Decline',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              BookingService().updateBookingStatus(booking.id, 'confirmed');
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.secondaryContainer,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              elevation: 4,
            ),
            child: const Text(
              'Accept Request',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
