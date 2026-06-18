import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../models/booking_model.dart';
import '../../models/truck_model.dart';
import '../../services/truck_service.dart';

class RateTruckOwnerScreen extends StatefulWidget {
  const RateTruckOwnerScreen({super.key, required this.booking});
  final BookingModel booking;

  @override
  State<RateTruckOwnerScreen> createState() => _RateTruckOwnerScreenState();
}

class _RateTruckOwnerScreenState extends State<RateTruckOwnerScreen> {
  int _rating = 0;

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
                children: [
                  _DriverProfile(booking: widget.booking),
                  const SizedBox(height: 32),
                  const Text(
                    'How was your experience?',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your feedback helps us improve our service.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: AppTheme.secondaryColor,
                          size: 48,
                        ),
                        onPressed: () => setState(() => _rating = index + 1),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: TextField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Write a review (optional)',
                        hintStyle: const TextStyle(
                          fontFamily: 'Inter',
                          color: AppTheme.outline,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _rating > 0
                        ? () => Navigator.of(context).popUntil((route) => route.isFirst)
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.surfaceContainerLow,
                      disabledForegroundColor: AppTheme.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    child: const Text(
                      'Submit Feedback',
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
        icon: const Icon(Icons.close_rounded,
            size: 24, color: AppTheme.onSurface),
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
      ),
      title: const Text(
        'Rate Driver',
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

class _DriverProfile extends StatelessWidget {
  const _DriverProfile({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        FirebaseFirestore.instance.collection('users').doc(booking.carrierId).get(),
        TruckService().getTruckByOwnerId(booking.carrierId),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userDoc = snapshot.data![0];
        final truck = snapshot.data![1];
        final name = userDoc.exists ? userDoc['name'] : 'Unknown Carrier';
        final truckDesc = truck != null ? '${truck.type} (${truck.plateNumber})' : 'Unknown Truck';

        return Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded,
                  color: AppTheme.primaryColor, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              truckDesc,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      }
    );
  }
}
