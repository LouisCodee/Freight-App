import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/route_string.dart';
import '../../widgets/status_chip.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';

class ActiveTripScreen extends StatefulWidget {
  final BookingModel booking;
  const ActiveTripScreen({super.key, required this.booking});

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.booking.status;
  }

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
                  _MapPlaceholder(),
                  const SizedBox(height: 16),
                  _TripStatusCard(),
                  const SizedBox(height: 16),
                  _DriverAndTruckCard(),
                  const SizedBox(height: 32),
                  _ActionButton(
                    onUpdate: (newStatus) async {
                      try {
                        await BookingService().updateBookingStatus(widget.booking.id, newStatus);
                        if (!context.mounted) return;
                        setState(() {
                          _currentStatus = newStatus;
                        });
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: AppTheme.onSurface),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Active Trip',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppTheme.onSurface,
        ),
      ),
      centerTitle: true,
      actions: [
        StatusChip(
          label: _currentStatus == 'in_transit' ? 'In Transit' : _currentStatus == 'delivered' ? 'Delivered' : 'Confirmed', 
          status: _currentStatus == 'delivered' ? ChipStatus.success : ChipStatus.info
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
        image: const DecorationImage(
          image: NetworkImage(
              'https://maps.googleapis.com/maps/api/staticmap?center=-6.8045,39.2831&zoom=10&size=600x300&maptype=roadmap&key=AIzaSyAOVYRIgupAurZup5y1PRh8Ismb1A3lLao'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_rounded, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                'Map View Integration',
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
    );
  }
}

class _TripStatusCard extends StatelessWidget {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trip Progress',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
              const Text(
                '60%',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.secondaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.6,
              color: AppTheme.secondaryContainer,
              backgroundColor: AppTheme.surfaceContainer,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 20),
          const RouteString(
            origin: 'Dar es Salaam Port',
            destination: 'Dodoma City Center',
            originLabel: 'Departed: Oct 15, 08:00 AM',
            destinationLabel: 'ETA: Oct 16, 14:00 PM',
            lineHeight: 40,
          ),
        ],
      ),
    );
  }
}

class _DriverAndTruckCard extends StatelessWidget {
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
                    const Text(
                      'Juma Ali (Driver)',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '+255 712 345 678',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
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
          Row(
            children: [
              const Icon(Icons.local_shipping_rounded,
                  color: AppTheme.onSurfaceVariant, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Scania R450 (Flatbed)',
                  style: TextStyle(
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
                child: const Text(
                  'T 123 ABC',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

class _ActionButton extends StatelessWidget {
  final ValueChanged<String> onUpdate;
  const _ActionButton({required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Update Trip Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_shipping_rounded, color: AppTheme.statusBlue),
                    title: const Text('In Transit'),
                    onTap: () {
                      onUpdate('in_transit');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.check_circle_rounded, color: AppTheme.statusGreen),
                    title: const Text('Delivered'),
                    onTap: () {
                      onUpdate('delivered');
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
      icon: const Icon(Icons.update_rounded, size: 20),
      label: const Text(
        'Update Trip Status',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
