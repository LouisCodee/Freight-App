import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'browse_trucks_list_screen.dart';

class EnterCargoDetailsScreen extends StatelessWidget {
  const EnterCargoDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppTheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Cargo Details',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _RouteSelectionCard(),
                const SizedBox(height: 16),
                _CargoSpecCard(),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const BrowseTrucksListScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  icon: const Icon(Icons.search_rounded, size: 20),
                  label: const Text(
                    'Search Trucks',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteSelectionCard extends StatelessWidget {
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
            'Route Information',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Pickup Location',
              prefixIcon:
                  const Icon(Icons.circle_outlined, color: AppTheme.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                borderSide: const BorderSide(color: AppTheme.outlineVariant),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Delivery Location',
              prefixIcon: const Icon(Icons.location_on_rounded,
                  color: AppTheme.secondaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                borderSide: const BorderSide(color: AppTheme.outlineVariant),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Pickup Date',
              prefixIcon: const Icon(Icons.calendar_month_rounded,
                  color: AppTheme.onSurfaceVariant),
              suffixIcon: const Icon(Icons.arrow_drop_down_rounded,
                  color: AppTheme.onSurfaceVariant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                borderSide: const BorderSide(color: AppTheme.outlineVariant),
              ),
            ),
            readOnly: true,
          ),
        ],
      ),
    );
  }
}

class _CargoSpecCard extends StatelessWidget {
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
            'Cargo Specifications',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Cargo Type',
              prefixIcon: const Icon(Icons.inventory_2_rounded,
                  color: AppTheme.onSurfaceVariant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'General', child: Text('General Merchandise')),
              DropdownMenuItem(value: 'Perishable', child: Text('Perishable Goods')),
              DropdownMenuItem(value: 'Construction', child: Text('Construction Material')),
            ],
            onChanged: (val) {},
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Weight',
                    prefixIcon: const Icon(Icons.scale_rounded,
                        color: AppTheme.onSurfaceVariant),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  ),
                  initialValue: 'Tons',
                  items: const [
                    DropdownMenuItem(value: 'Tons', child: Text('Tons')),
                    DropdownMenuItem(value: 'Kg', child: Text('Kilograms')),
                  ],
                  onChanged: (val) {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


