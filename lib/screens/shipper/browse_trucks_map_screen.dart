import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'browse_trucks_list_screen.dart';

class BrowseTrucksMapScreen extends StatelessWidget {
  const BrowseTrucksMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainerLow,
      body: Stack(
        children: [
          // Dummy map background
          Positioned.fill(
            child: Image.network(
              'https://maps.googleapis.com/maps/api/staticmap?center=-6.8045,39.2831&zoom=12&size=800x800&maptype=roadmap&key=AIzaSyAOVYRIgupAurZup5y1PRh8Ismb1A3lLao',
              fit: BoxFit.cover,
            ),
          ),
          // Custom App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppTheme.surfaceContainerLowest.withValues(alpha: 0.95),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: AppTheme.onSurface),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Expanded(
                        child: Text(
                          'Dar es Salaam → Dodoma',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.filter_list_rounded,
                            color: AppTheme.onSurface),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Map Marker Overlays (Dummy)
          Positioned(
            top: 300,
            left: 150,
            child: _MapPin(price: '850K', isSelected: true),
          ),
          Positioned(
            top: 450,
            left: 200,
            child: _MapPin(price: '1.2M', isSelected: false),
          ),
          Positioned(
            top: 250,
            left: 280,
            child: _MapPin(price: '650K', isSelected: false),
          ),
          // Selected Truck Details Bottom Sheet overlay
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: _SelectedTruckPreview(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BrowseTrucksListScreen()),
        ),
        backgroundColor: AppTheme.onSurface,
        icon: const Icon(Icons.list_rounded, color: Colors.white),
        label: const Text(
          'List View',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.price, required this.isSelected});
  final String price;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : AppTheme.outlineVariant,
        ),
      ),
      child: Text(
        price,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isSelected ? Colors.white : AppTheme.onSurface,
        ),
      ),
    );
  }
}

class _SelectedTruckPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BrowseTrucksListScreen()),
      ),
      child: Container(
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
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Icon(Icons.local_shipping_rounded,
                  color: AppTheme.primaryColor, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scania R450',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'John Mwangi • Flatbed',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'TZS 850,000',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.outline),
          ],
        ),
      ),
    );
  }
}
