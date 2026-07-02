import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/listing_model.dart';
import '../../models/truck_model.dart';
import '../../services/listing_service.dart';
import '../../services/truck_service.dart';

class EditListingScreen extends StatefulWidget {
  final ListingModel listing;
  const EditListingScreen({super.key, required this.listing});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rateController = TextEditingController();
  final _notesController = TextEditingController();

  String? _origin;
  String? _destination;
  DateTime? _availableDate;
  bool _isFlexible = false;
  List<String> _cargoPreferences = [];
  String _pricingModel = 'per_ton';
  bool _negotiable = true;
  bool _isLoading = true;
  bool _isSaving = false;
  TruckModel? _truck;

  final List<String> _regions = [
    'Dar es Salaam', 'Dodoma', 'Mwanza', 'Arusha',
    'Mbeya', 'Morogoro', 'Tanga', 'Zanzibar',
    'Iringa', 'Moshi', 'Tabora', 'Kigoma',
  ];

  final List<String> _cargoTypes = [
    'General Cargo', 'Electronics', 'Agriculture', 'Beverages',
    'Construction', 'Textiles', 'Chemicals', 'Livestock',
  ];

  @override
  void initState() {
    super.initState();
    _origin = widget.listing.origin;
    _destination = widget.listing.destination;
    _availableDate = widget.listing.availableDate;
    _isFlexible = widget.listing.isFlexible;
    _cargoPreferences = List.from(widget.listing.cargoPreferences);
    _pricingModel = widget.listing.pricingModel;
    _rateController.text = widget.listing.rate.toStringAsFixed(0);
    _negotiable = widget.listing.negotiable;
    _notesController.text = widget.listing.notes;
    _loadTruck();
  }

  Future<void> _loadTruck() async {
    final truck = await TruckService().getTruckById(widget.listing.truckId);
    if (mounted) setState(() { _truck = truck; _isLoading = false; });
  }

  @override
  void dispose() {
    _rateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _availableDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primaryColor,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _availableDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_origin == null || _destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select origin and destination')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ListingService().updateListing(
        listingId: widget.listing.id,
        origin: _origin!,
        destination: _destination!,
        availableDate: _availableDate,
        isFlexible: _isFlexible,
        cargoPreferences: _cargoPreferences,
        pricingModel: _pricingModel,
        rate: double.tryParse(_rateController.text) ?? 0.0,
        negotiable: _negotiable,
        notes: _notesController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing updated successfully')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _EditHeader(
            onBack: () => Navigator.of(context).pop(),
            onSave: _save,
            isSaving: _isSaving,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTruckInfo(),
                          const SizedBox(height: 20),
                          _SectionCard(
                            label: 'Route Details',
                            icon: Icons.route_rounded,
                            children: [
                              DropdownButtonFormField<String>(
                                // ignore: deprecated_member_use
                                value: _origin,
                                decoration: const InputDecoration(
                                  labelText: 'From (Origin)',
                                  prefixIcon: Icon(Icons.my_location_rounded),
                                ),
                                items: _regions
                                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                                    .toList(),
                                onChanged: (v) => setState(() => _origin = v),
                                icon: const Icon(Icons.expand_more_rounded,
                                    color: AppTheme.outline),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                // ignore: deprecated_member_use
                                value: _destination,
                                decoration: const InputDecoration(
                                  labelText: 'To (Destination)',
                                  prefixIcon: Icon(Icons.location_on_rounded),
                                ),
                                items: _regions
                                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                                    .toList(),
                                onChanged: (v) => setState(() => _destination = v),
                                icon: const Icon(Icons.expand_more_rounded,
                                    color: AppTheme.outline),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _SectionCard(
                            label: 'Availability',
                            icon: Icons.calendar_today_rounded,
                            children: [
                              GestureDetector(
                                onTap: _isFlexible ? null : _pickDate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: _isFlexible
                                        ? AppTheme.surfaceContainer
                                        : AppTheme.surfaceContainerLow,
                                    borderRadius:
                                        BorderRadius.circular(AppTheme.radiusMd),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.event_rounded,
                                          size: 20,
                                          color: _isFlexible
                                              ? AppTheme.outlineVariant
                                              : AppTheme.outline),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _isFlexible
                                              ? 'Flexible (any date)'
                                              : _availableDate != null
                                                  ? 'Available from ${_availableDate!.day}/${_availableDate!.month}/${_availableDate!.year}'
                                                  : 'Select available date',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            color: _isFlexible
                                                ? AppTheme.outlineVariant
                                                : _availableDate != null
                                                    ? AppTheme.onSurface
                                                    : AppTheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      if (!_isFlexible)
                                        const Icon(Icons.chevron_right_rounded,
                                            color: AppTheme.outline),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _isFlexible = !_isFlexible),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: _isFlexible
                                            ? AppTheme.secondaryContainer
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: _isFlexible
                                              ? AppTheme.secondaryContainer
                                              : AppTheme.outlineVariant,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: _isFlexible
                                          ? const Icon(Icons.check_rounded,
                                              color: Colors.white, size: 14)
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'I\'m flexible on dates',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        color: AppTheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _SectionCard(
                            label: 'Cargo Preferences',
                            icon: Icons.inventory_2_rounded,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _cargoTypes.map((t) {
                                  final isSelected = _cargoPreferences.contains(t);
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          _cargoPreferences.remove(t);
                                        } else {
                                          _cargoPreferences.add(t);
                                        }
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.primaryColor
                                            : AppTheme.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.radiusFull),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.primaryColor
                                              : AppTheme.outlineVariant,
                                        ),
                                      ),
                                      child: Text(
                                        t,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : AppTheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _SectionCard(
                            label: 'Pricing',
                            icon: Icons.account_balance_wallet_outlined,
                            children: [
                              Row(
                                children: [
                                  _PricingModelChip(
                                    label: 'Per Ton',
                                    icon: Icons.scale_rounded,
                                    selected: _pricingModel == 'per_ton',
                                    onTap: () =>
                                        setState(() => _pricingModel = 'per_ton'),
                                  ),
                                  const SizedBox(width: 10),
                                  _PricingModelChip(
                                    label: 'Per Trip',
                                    icon: Icons.route_rounded,
                                    selected: _pricingModel == 'per_trip',
                                    onTap: () =>
                                        setState(() => _pricingModel = 'per_trip'),
                                  ),
                                  const SizedBox(width: 10),
                                  _PricingModelChip(
                                    label: 'Per Day',
                                    icon: Icons.calendar_today_rounded,
                                    selected: _pricingModel == 'per_day',
                                    onTap: () =>
                                        setState(() => _pricingModel = 'per_day'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _rateController,
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Please enter a rate';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Rate (TZS)',
                                  prefixIcon: const Icon(
                                      Icons.account_balance_wallet_outlined),
                                  hintText: _pricingModel == 'per_ton'
                                      ? 'e.g. 50,000 per ton'
                                      : _pricingModel == 'per_trip'
                                          ? 'e.g. 850,000 per trip'
                                          : 'e.g. 250,000 per day',
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _negotiable = !_negotiable),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: _negotiable
                                            ? AppTheme.secondaryContainer
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: _negotiable
                                              ? AppTheme.secondaryContainer
                                              : AppTheme.outlineVariant,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: _negotiable
                                          ? const Icon(Icons.check_rounded,
                                              color: Colors.white, size: 14)
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Price is negotiable',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        color: AppTheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _SectionCard(
                            label: 'Additional Information',
                            icon: Icons.notes_rounded,
                            children: [
                              TextFormField(
                                controller: _notesController,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  labelText: 'Special Instructions / Notes',
                                  alignLabelWithHint: true,
                                  hintText:
                                      'Any special requirements, loading instructions, or conditions...',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _isLoading
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryContainer,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
    );
  }

  Widget _buildTruckInfo() {
    if (_truck == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(Icons.local_shipping_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_truck!.truckType} — ${_truck!.payloadCapacity} Tons',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.pin_rounded,
                        size: 12, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      _truck!.licensePlate,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.home_rounded,
                        size: 12, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      _truck!.homeBase,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: const Text(
              'Live',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSave;
  final bool isSaving;
  const _EditHeader({
    required this.onBack,
    required this.onSave,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceContainerLowest,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.onSurface,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Edit Listing',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                  ),
                ),
              ),
              GestureDetector(
                onTap: isSaving ? null : onSave,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text(
                          'Save',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
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

class _SectionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Widget> children;
  const _SectionCard({
    required this.label,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 15, color: AppTheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _PricingModelChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _PricingModelChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primaryColor
                : AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: selected
                  ? AppTheme.primaryColor
                  : AppTheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20,
                  color:
                      selected ? Colors.white : AppTheme.onSurfaceVariant),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppTheme.onSurfaceVariant,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
