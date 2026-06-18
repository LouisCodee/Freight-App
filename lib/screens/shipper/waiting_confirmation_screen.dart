import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'active_booking_tracker_screen.dart';

import '../../models/booking_model.dart';
import '../../services/booking_service.dart';

class WaitingConfirmationScreen extends StatefulWidget {
  const WaitingConfirmationScreen({super.key, required this.booking});
  final BookingModel booking;

  @override
  State<WaitingConfirmationScreen> createState() =>
      _WaitingConfirmationScreenState();
}

class _WaitingConfirmationScreenState extends State<WaitingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Simulate owner accepting the booking after 3 seconds
    Future.delayed(const Duration(seconds: 3), () async {
      await BookingService().updateBookingStatus(widget.booking.id, 'in_transit');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => ActiveBookingTrackerScreen(booking: widget.booking)),
        );
      }
    });
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  RotationTransition(
                    turns: _controller,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.secondaryContainer.withValues(alpha: 0.3),
                          width: 4,
                        ),
                      ),
                      child: const CircularProgressIndicator(
                        strokeWidth: 4,
                        color: AppTheme.secondaryContainer,
                      ),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryContainer.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_empty_rounded,
                      color: AppTheme.secondaryContainer,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Waiting for Confirmation',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your request has been sent to John Mwangi. We will notify you once they accept.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: AppTheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.statusRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text(
                  'Cancel Request',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
