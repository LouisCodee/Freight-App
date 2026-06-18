import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'waiting_confirmation_screen.dart';
import '../../widgets/route_string.dart';

import '../../models/listing_model.dart';
import '../../services/booking_service.dart';

class ConfirmBookingScreen extends StatefulWidget {
  final ListingModel listing;
  const ConfirmBookingScreen({super.key, required this.listing});

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  bool _isLoading = false;

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
                  _SummaryCard(),
                  const SizedBox(height: 16),
                  _PaymentMethodCard(),
                  const SizedBox(height: 32),
                  const Text(
                    'By tapping Confirm Booking, you agree to our Terms of Service and Cancellation Policy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            try {
                              final newBooking = await BookingService().createBooking(
                                listingId: widget.listing.id,
                                carrierId: widget.listing.ownerId,
                                price: widget.listing.rate,
                                cargoDetails: {
                                  'origin': widget.listing.origin,
                                  'destination': widget.listing.destination,
                                  'type': 'General Merchandise',
                                  'weight': 10.0,
                                },
                              );
                              if (!context.mounted) return;
                              setState(() => _isLoading = false);
                              if (newBooking != null) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (_) => WaitingConfirmationScreen(booking: newBooking)),
                                );
                              }
                            } catch (e) {
                              if (!context.mounted) return;
                              setState(() => _isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                          ),
                          child: const Text(
                            'Confirm Booking',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
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
        'Confirm Booking',
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

class _SummaryCard extends StatelessWidget {
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
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(Icons.local_shipping_rounded,
                    color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scania R450 (Flatbed)',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'John Mwangi • T 123 ABC',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.outlineVariant),
          const SizedBox(height: 16),
          const RouteString(
            origin: 'Dar es Salaam Port',
            destination: 'Dodoma City Center',
            originLabel: 'Oct 15, 2026',
            destinationLabel: 'Oct 16, 2026',
            lineHeight: 32,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.outlineVariant),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
              const Text(
                'TZS 850,000',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
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
          const Text(
            'Payment Method',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.secondaryContainer, width: 2),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_rounded,
                    color: AppTheme.secondaryContainer),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FreightMatch Wallet',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Balance: TZS 1,500,000',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle_rounded,
                    color: AppTheme.secondaryContainer),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
