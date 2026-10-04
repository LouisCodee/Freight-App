import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'browse_trucks_list_screen.dart';

class EnterCargoDetailsScreen extends StatefulWidget {
  const EnterCargoDetailsScreen({super.key});

  @override
  State<EnterCargoDetailsScreen> createState() => _EnterCargoDetailsScreenState();
}

class _EnterCargoDetailsScreenState extends State<EnterCargoDetailsScreen> {
  String? _pickupLocation;
  String? _deliveryLocation;
  DateTime? _pickupDate;
  String? _cargoType;
  String _weightUnit = 'Tons';

  final List<String> _tanzaniaRegions = [
    'Dar es Salaam', 'Dodoma', 'Arusha', 'Mwanza', 'Mbeya', 
    'Morogoro', 'Tanga', 'Kilimanjaro', 'Kigoma', 'Tabora', 
    'Zanzibar', 'Mtwara', 'Lindi', 'Ruvuma', 'Singida'
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _pickupDate) {
      setState(() {
        _pickupDate = picked;
      });
    }
  }

  void _onSearchTrucks() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BrowseTrucksListScreen(
          searchOrigin: _pickupLocation,
          searchDestination: _deliveryLocation,
          searchCargoType: _cargoType,
          searchDate: _pickupDate,
        ),
      ),
    );
  }

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
                _buildRouteSelectionCard(),
                const SizedBox(height: 16),
                _buildCargoSpecCard(),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _onSearchTrucks,
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

  Widget _buildRouteSelectionCard() {
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
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Pickup Location',
              prefixIcon: const Icon(Icons.circle_outlined, color: AppTheme.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                borderSide: const BorderSide(color: AppTheme.outlineVariant),
              ),
            ),
            value: _pickupLocation,
            items: _tanzaniaRegions.map((region) {
              return DropdownMenuItem(value: region, child: Text(region));
            }).toList(),
            onChanged: (val) => setState(() => _pickupLocation = val),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Delivery Location',
              prefixIcon: const Icon(Icons.location_on_rounded, color: AppTheme.secondaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                borderSide: const BorderSide(color: AppTheme.outlineVariant),
              ),
            ),
            value: _deliveryLocation,
            items: _tanzaniaRegions.map((region) {
              return DropdownMenuItem(value: region, child: Text(region));
            }).toList(),
            onChanged: (val) => setState(() => _deliveryLocation = val),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _selectDate(context),
            child: IgnorePointer(
              child: TextFormField(
                key: ValueKey(_pickupDate),
                initialValue: _pickupDate != null 
                    ? "\${_pickupDate!.day}/\${_pickupDate!.month}/\${_pickupDate!.year}"
                    : null,
                decoration: InputDecoration(
                  labelText: 'Pickup Date',
                  hintText: 'Select Date',
                  prefixIcon: const Icon(Icons.calendar_month_rounded, color: AppTheme.onSurfaceVariant),
                  suffixIcon: const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide: const BorderSide(color: AppTheme.outlineVariant),
                  ),
                ),
                readOnly: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCargoSpecCard() {
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
              labelText: 'Cargo Type (Optional)',
              prefixIcon: const Icon(Icons.inventory_2_rounded, color: AppTheme.onSurfaceVariant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
            ),
            value: _cargoType,
            items: const [
              DropdownMenuItem(value: 'General', child: Text('General Merchandise')),
              DropdownMenuItem(value: 'Perishable', child: Text('Perishable Goods')),
              DropdownMenuItem(value: 'Construction', child: Text('Construction Material')),
            ],
            onChanged: (val) => setState(() => _cargoType = val),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Weight (Optional)',
                    prefixIcon: const Icon(Icons.scale_rounded, color: AppTheme.onSurfaceVariant),
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
                  value: _weightUnit,
                  items: const [
                    DropdownMenuItem(value: 'Tons', child: Text('Tons')),
                    DropdownMenuItem(value: 'Kg', child: Text('Kilograms')),
                  ],
                  onChanged: (val) => setState(() => _weightUnit = val ?? 'Tons'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
