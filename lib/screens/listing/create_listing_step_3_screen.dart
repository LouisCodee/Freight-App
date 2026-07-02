import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/step_indicator.dart';
import '../../services/listing_service.dart';
import 'listing_published_screen.dart';

String _pricingLabel(String model) {
  switch (model) {
    case 'per_ton':
      return 'Per Ton';
    case 'per_trip':
      return 'Per Trip';
    case 'per_day':
      return 'Per Day';
    default:
      return 'Per Ton';
  }
}

String _formatCurrency(double amount) {
  if (amount >= 1000000) {
    return 'TZS ${(amount / 1000000).toStringAsFixed(1)}M';
  } else if (amount >= 1000) {
    return 'TZS ${(amount / 1000).toStringAsFixed(0)}K';
  }
  return 'TZS ${amount.toStringAsFixed(0)}';
}

class CreateListingStep3Screen extends StatefulWidget {
  final String? truckId;
  final String? truckPlate;
  final String? truckType;
  final double? payloadCapacity;
  final String? homeBase;
  final bool hasPhoto;
  final String? origin;
  final String? destination;
  final DateTime? availableDate;
  final bool? isFlexible;
  final List<String>? cargoPreferences;

  const CreateListingStep3Screen({
    super.key,
    this.truckId,
    this.truckPlate,
    this.truckType,
    this.payloadCapacity,
    this.homeBase,
    this.hasPhoto = false,
    this.origin,
    this.destination,
    this.availableDate,
    this.isFlexible,
    this.cargoPreferences,
  });

  @override
  State<CreateListingStep3Screen> createState() =>
      _CreateListingStep3ScreenState();
}

class _CreateListingStep3ScreenState extends State<CreateListingStep3Screen> {
  String _pricingModel = 'per_ton';
  bool _negotiable = true;
  final _rateController = TextEditingController();
  final _notesController = TextEditingController();
  bool _hasPhoto = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _hasPhoto = widget.hasPhoto;
  }

  @override
  void dispose() {
    _rateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String get _formattedDate {
    if (widget.isFlexible == true) return 'Flexible';
    if (widget.availableDate == null) return 'Not set';
    final d = widget.availableDate!;
    return '${d.day}/${d.month}/${d.year}';
  }

  String get _formattedCapacity {
    return '${widget.payloadCapacity?.toStringAsFixed(0) ?? '0'} Tons';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _ListingHeader(
            onBack: () => Navigator.of(context).pop(),
            step: 'Step 3 of 3 \u2014 Pricing',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StepIndicator(
                    currentStep: 3,
                    totalSteps: 3,
                    stepLabels: ['Vehicle', 'Route', 'Pricing'],
                  ),
                  const SizedBox(height: 20),

                  if (widget.truckType != null)
                    _buildTruckInfoBanner(),
                  if (widget.truckType != null)
                    const SizedBox(height: 16),

                  _SectionLabel(label: 'Pricing Model'),
                  const SizedBox(height: 12),
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
                    decoration: InputDecoration(
                      labelText: 'Rate (TZS)',
                      prefixIcon:
                          const Icon(Icons.account_balance_wallet_outlined),
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
                  const SizedBox(height: 24),

                  _SectionLabel(label: 'Additional Information'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Special Instructions / Notes',
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: Icon(Icons.notes_rounded),
                      ),
                      hintText:
                          'Any special requirements, loading instructions, or conditions...',
                    ),
                  ),
                  const SizedBox(height: 24),

                  _SectionLabel(label: 'Truck Photos'),
                  const SizedBox(height: 12),
                  _PhotoUploadZone(
                    hasPhoto: _hasPhoto,
                    onTap: () =>
                        setState(() => _hasPhoto = !_hasPhoto),
                  ),
                  const SizedBox(height: 24),

                  _SectionLabel(label: 'Listing Summary'),
                  const SizedBox(height: 12),
                  _buildSummaryCard(),
                  const SizedBox(height: 32),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _GradientButton(
                          label: 'Publish Listing',
                          icon: Icons.rocket_launch_rounded,
                          onTap: () async {
                            if (widget.truckId == null) return;
                            setState(() => _isLoading = true);
                            try {
                              final newListing = await ListingService().addListing(
                                truckId: widget.truckId!,
                                origin: widget.origin ?? '',
                                destination: widget.destination ?? '',
                                availableDate: widget.availableDate,
                                isFlexible: widget.isFlexible ?? false,
                                cargoPreferences: widget.cargoPreferences ?? [],
                                pricingModel: _pricingModel,
                                rate: double.tryParse(_rateController.text) ?? 0.0,
                                negotiable: _negotiable,
                                notes: _notesController.text.trim(),
                              );
                              if (!context.mounted) return;
                              setState(() => _isLoading = false);
                              if (newListing != null) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (_) => ListingPublishedScreen(listing: newListing)),
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
                  '${widget.truckType} \u2014 ${
                    widget.payloadCapacity?.toStringAsFixed(0) ?? '0'
                  } Tons',
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
                    const Icon(Icons.route_rounded, size: 11, color: Colors.white70),
                    const SizedBox(width: 3),
                    Text(
                      '${widget.origin ?? ''} \u2192 ${widget.destination ?? ''}',
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

  Widget _buildSummaryCard() {
    final route = '${widget.origin ?? '-'} \u2192 ${widget.destination ?? '-'}';
    final rateAmount = double.tryParse(_rateController.text) ?? 0.0;
    final rateDisplay = rateAmount > 0
        ? '${_formatCurrency(rateAmount)} / ${_pricingLabel(_pricingModel)}'
        : 'Not set';
    final cargoDisplay = (widget.cargoPreferences ?? []).isEmpty
        ? 'None selected'
        : (widget.cargoPreferences ?? []).join(', ');
    final negotiableDisplay = _negotiable ? 'Yes' : 'No';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Truck', value: '${widget.truckType ?? '-'} \u2014 $_formattedCapacity'),
          const Divider(height: 20),
          _SummaryRow(label: 'Plate', value: widget.truckPlate ?? '-'),
          const Divider(height: 20),
          _SummaryRow(label: 'Route', value: route),
          const Divider(height: 20),
          _SummaryRow(label: 'Cargo', value: cargoDisplay),
          const Divider(height: 20),
          _SummaryRow(label: 'Available', value: _formattedDate),
          const Divider(height: 20),
          _SummaryRow(label: 'Rate', value: rateDisplay),
          const Divider(height: 20),
          _SummaryRow(label: 'Negotiable', value: negotiableDisplay),
        ],
      ),
    );
  }
}

class _PricingModelChip extends StatelessWidget {
  const _PricingModelChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryColor : AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: selected ? AppTheme.primaryColor : AppTheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20,
                  color: selected ? Colors.white : AppTheme.onSurfaceVariant),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppTheme.onSurfaceVariant,
            )),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurface,
              )),
        ),
      ],
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

// Shared helpers
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
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppTheme.onSurface, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Create Listing',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                        )),
                    Text(step,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppTheme.onSurfaceVariant,
                        )),
                  ],
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
    return Row(children: [
      Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
              color: AppTheme.secondaryContainer,
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(label.toUpperCase(),
          style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurfaceVariant,
              letterSpacing: 1.0)),
    ]);
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
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.white, size: 18),
        ]),
      ),
    );
  }
}
