import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import 'rate_truck_owner_screen.dart';

import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../services/truck_service.dart';

class BookingCompletedScreen extends StatefulWidget {
  const BookingCompletedScreen({super.key, required this.booking});
  final BookingModel booking;

  @override
  State<BookingCompletedScreen> createState() => _BookingCompletedScreenState();
}

class _BookingCompletedScreenState extends State<BookingCompletedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    // Mark booking as delivered
    BookingService().updateBookingStatus(widget.booking.id, 'delivered');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              children: [
                const Spacer(),
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.statusGreen, Color(0xFF1B5E20)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.statusGreen.withValues(alpha: 0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Shipment Delivered!',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your cargo has arrived safely at its destination.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: AppTheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                FutureBuilder<List<dynamic>>(
                  future: Future.wait([
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.booking.carrierId)
                        .get(),
                    TruckService().getTruckByOwnerId(widget.booking.carrierId),
                  ]),
                  builder: (context, snapshot) {
                    final carrierName =
                        snapshot.hasData && snapshot.data![0].exists
                        ? snapshot.data![0]['name']
                        : 'Unknown Carrier';
                    final truckName =
                        snapshot.hasData && snapshot.data![1] != null
                        ? snapshot.data![1].truckType
                        : 'Unknown Truck';
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
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  carrierName,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  truckName,
                                  style: const TextStyle(
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
                    );
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) =>
                          RateTruckOwnerScreen(booking: widget.booking),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: const Text(
                    'Rate Truck Owner',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
