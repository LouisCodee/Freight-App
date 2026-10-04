import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/route_string.dart';
import '../../models/listing_model.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';

class ListingRequestsScreen extends StatelessWidget {
  const ListingRequestsScreen({super.key, required this.listing});
  final ListingModel listing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainerLowest,
        title: const Text(
          'Listing Requests',
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
        stream: BookingService().getBookingsForListing(listing.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allBookings = snapshot.data ?? [];
          final activeRequests = allBookings
              .where((b) => b.status != 'cancelled' && b.status != 'delivered')
              .toList();

          if (activeRequests.isEmpty) {
            return const Center(
              child: Text(
                'No active requests for this listing.',
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
            itemCount: activeRequests.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ListingRequestItemCard(booking: activeRequests[index]),
              );
            },
          );
        },
      ),
    );
  }
}

class _ListingRequestItemCard extends StatefulWidget {
  const _ListingRequestItemCard({required this.booking});
  final BookingModel booking;

  @override
  State<_ListingRequestItemCard> createState() => _ListingRequestItemCardState();
}

class _ListingRequestItemCardState extends State<_ListingRequestItemCard> {
  bool _isLoading = false;

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);
    try {
      await BookingService().updateBookingStatus(widget.booking.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request updated successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update request: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(widget.booking.shipperId).get(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final shipperName = data?['name'] ?? 'Loading Shipper...';

        ChipStatus chipStatus;
        String statusLabel;
        if (widget.booking.status == 'in_transit') {
          chipStatus = ChipStatus.info;
          statusLabel = 'In Transit';
        } else if (widget.booking.status == 'confirmed') {
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
                    '#${widget.booking.id.substring(0, 8).toUpperCase()}',
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
                origin: widget.booking.cargoDetails['origin'] ?? 'Unknown Origin',
                destination: widget.booking.cargoDetails['destination'] ?? 'Unknown Destination',
                originLabel: 'Pickup',
                destinationLabel: 'Drop-off',
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
                    child: const Icon(Icons.business_rounded, size: 18, color: AppTheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 12),
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
                          'Offer: TZS ${widget.booking.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (widget.booking.status == 'pending') ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => _updateStatus('cancelled'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.statusRed,
                          side: const BorderSide(color: AppTheme.outlineVariant),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isLoading ? null : () => _updateStatus('confirmed'),
                        child: _isLoading
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ] else if (widget.booking.status == 'confirmed') ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : () => _updateStatus('in_transit'),
                    child: _isLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Start Trip'),
                  ),
                ),
              ] else if (widget.booking.status == 'in_transit') ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : () => _updateStatus('delivered'),
                    style: FilledButton.styleFrom(backgroundColor: AppTheme.statusGreen),
                    child: _isLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Mark as Delivered'),
                  ),
                ),
              ],
            ],
          ),
        );
      }
    );
  }
}
