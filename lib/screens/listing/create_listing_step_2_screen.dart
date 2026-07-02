import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/step_indicator.dart';
import 'create_listing_step_3_screen.dart';

class CreateListingStep2Screen extends StatefulWidget {
  final String? truckId;
  final String? truckPlate;
  final String? truckType;
  final double? payloadCapacity;
  final String? homeBase;
  final bool hasPhoto;

  const CreateListingStep2Screen({
    super.key,
    this.truckId,
    this.truckPlate,
    this.truckType,
    this.payloadCapacity,
    this.homeBase,
    this.hasPhoto = false,
  });

  @override
  State<CreateListingStep2Screen> createState() =>
      _CreateListingStep2ScreenState();
}

class _CreateListingStep2ScreenState extends State<CreateListingStep2Screen> {
  String? _selectedFrom;
  String? _selectedTo;
  DateTime? _availableFrom;
  bool _isFlexible = false;
  List<String> _selectedCargoTypes = [];
  bool _hasPhoto = false;

  final List<String> _regions = [
    'Dar es Salaam', 'Dodoma', 'Mwanza', 'Arusha',
    'Mbeya', 'Morogoro', 'Tanga', 'Zanzibar',
    'Iringa', 'Moshi', 'Tabora', 'Kigoma',
  ];

  @override
  void initState() {
    super.initState();
    _hasPhoto = widget.hasPhoto;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
    if (picked != null) setState(() => _availableFrom = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _ListingHeader(
            onBack: () => Navigator.of(context).pop(),
            step: 'Step 2 of 3 — Route Details',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StepIndicator(
                    currentStep: 2,
                    totalSteps: 3,
                    stepLabels: ['Vehicle', 'Route', 'Pricing'],
                  ),
                  const SizedBox(height: 20),

                  if (widget.truckType != null)
                    _buildTruckInfoBanner(),
                  if (widget.truckType != null)
                    const SizedBox(height: 20),

                  _SectionLabel(label: 'Route Details'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _selectedFrom,
                    decoration: const InputDecoration(
                      labelText: 'From (Origin)',
                      prefixIcon: Icon(Icons.my_location_rounded),
                    ),
                    items: _regions.map((r) =>
                        DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (v) => setState(() => _selectedFrom = v),
                    icon: const Icon(Icons.expand_more_rounded, color: AppTheme.outline),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _selectedTo,
                    decoration: const InputDecoration(
                      labelText: 'To (Destination)',
                      prefixIcon: Icon(Icons.location_on_rounded),
                    ),
                    items: _regions.map((r) =>
                        DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (v) => setState(() => _selectedTo = v),
                    icon: const Icon(Icons.expand_more_rounded, color: AppTheme.outline),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Stopping Points (Optional)',
                      prefixIcon: Icon(Icons.route_rounded),
                      hintText: 'e.g. Morogoro, Mikumi',
                    ),
                  ),
                  const SizedBox(height: 24),

                  _SectionLabel(label: 'Availability'),
                  const SizedBox(height: 12),
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
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 20,
                            color: _isFlexible
                                ? AppTheme.outlineVariant
                                : AppTheme.outline,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isFlexible
                                  ? 'Flexible (any date)'
                                  : _availableFrom != null
                                      ? 'Available from ${_availableFrom!.day}/${_availableFrom!.month}/${_availableFrom!.year}'
                                      : 'Select available date',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: _isFlexible
                                    ? AppTheme.outlineVariant
                                    : _availableFrom != null
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
                    onTap: () => setState(() => _isFlexible = !_isFlexible),
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
                  const SizedBox(height: 24),

                  _SectionLabel(label: 'Cargo Preferences'),
                  const SizedBox(height: 12),
                  _CargoTypeGrid(
                    onChanged: (selected) {
                      setState(() => _selectedCargoTypes = selected);
                    },
                  ),
                  const SizedBox(height: 24),

                  _SectionLabel(label: 'Truck Photos'),
                  const SizedBox(height: 12),
                  _PhotoUploadZone(
                    hasPhoto: _hasPhoto,
                    onTap: () =>
                        setState(() => _hasPhoto = !_hasPhoto),
                  ),
                  const SizedBox(height: 32),

                  _GradientButton(
                    label: 'Continue to Pricing',
                    icon: Icons.arrow_forward_rounded,
                    onTap: () {
                      if (_selectedFrom == null || _selectedTo == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select origin and destination')),
                        );
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => CreateListingStep3Screen(
                                  truckId: widget.truckId,
                                  truckPlate: widget.truckPlate,
                                  truckType: widget.truckType,
                                  payloadCapacity: widget.payloadCapacity,
                                  homeBase: widget.homeBase,
                                  hasPhoto: _hasPhoto,
                                  origin: _selectedFrom!,
                                  destination: _selectedTo!,
                                  availableDate: _availableFrom,
                                  isFlexible: _isFlexible,
                                  cargoPreferences: _selectedCargoTypes,
                                )),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTruckInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(Icons.local_shipping_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.truckType} \u2014 ${widget.payloadCapacity?.toStringAsFixed(0) ?? '0'} Tons',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.pin_rounded, size: 11, color: Colors.white70),
                    const SizedBox(width: 3),
                    Text(
                      widget.truckPlate ?? '',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.home_rounded, size: 11, color: Colors.white70),
                    const SizedBox(width: 3),
                    Text(
                      widget.homeBase ?? '',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CargoTypeGrid extends StatefulWidget {
  final ValueChanged<List<String>> onChanged;
  const _CargoTypeGrid({required this.onChanged});

  @override
  State<_CargoTypeGrid> createState() => _CargoTypeGridState();
}

class _CargoTypeGridState extends State<_CargoTypeGrid> {
  final List<String> _types = [
    'General Cargo', 'Electronics', 'Agriculture', 'Beverages',
    'Construction', 'Textiles', 'Chemicals', 'Livestock',
  ];
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _types.map((t) {
        final isSelected = _selected.contains(t);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selected.remove(t);
              } else {
                _selected.add(t);
              }
            });
            widget.onChanged(_selected.toList());
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
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
                color: isSelected ? Colors.white : AppTheme.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PhotoUploadZone extends StatelessWidget {
  const _PhotoUploadZone({required this.hasPhoto, required this.onTap});
  final bool hasPhoto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 100,
        decoration: BoxDecoration(
          color: hasPhoto
              ? AppTheme.statusGreenContainer
              : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: hasPhoto ? AppTheme.statusGreen : AppTheme.outlineVariant,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasPhoto
                    ? Icons.check_circle_rounded
                    : Icons.add_photo_alternate_rounded,
                size: 28,
                color: hasPhoto
                    ? AppTheme.statusGreen
                    : AppTheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                hasPhoto ? 'Photo Added \u2713' : 'Tap to Upload Truck Photo',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: hasPhoto
                      ? AppTheme.statusGreen
                      : AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared helpers ──────────────────────────────────────────────────────────

class _ListingHeader extends StatelessWidget {
  const _ListingHeader({required this.onBack, required this.step});
  final VoidCallback onBack;
  final String step;

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create Listing',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    Text(
                      step,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  backgroundColor: AppTheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSm)),
                ),
                child: const Text(
                  'Save Draft',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceVariant,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton(
      {required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: AppTheme.accentGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppTheme.secondaryContainer.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                )),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
