import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../widgets/step_indicator.dart';
import '../../services/truck_service.dart';
import 'create_listing_step_2_screen.dart';

class CreateListingStep1Screen extends StatefulWidget {
  const CreateListingStep1Screen({super.key});

  @override
  State<CreateListingStep1Screen> createState() =>
      _CreateListingStep1ScreenState();
}

class _CreateListingStep1ScreenState extends State<CreateListingStep1Screen> {
  String? _selectedTruckType;
  File? _truckImage;
  final _plateController = TextEditingController();
  final _capacityController = TextEditingController();
  final _homeBaseController = TextEditingController();
  final _routesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _plateController.dispose();
    _capacityController.dispose();
    _homeBaseController.dispose();
    _routesController.dispose();
    super.dispose();
  }

  final List<String> _truckTypes = [
    'Flatbed',
    'Box Truck',
    'Refrigerated',
    'Tanker',
    'Tipper / Dump Truck',
    'Lowbed',
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Column(
          children: [
            _ListingHeader(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StepIndicator(
                      currentStep: 1,
                      totalSteps: 3,
                      stepLabels: ['Vehicle', 'Route', 'Pricing'],
                    ),
                    const SizedBox(height: 28),

                    _SectionLabel(label: 'Vehicle Identity'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _plateController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Truck License Plate',
                        prefixIcon: Icon(Icons.pin_rounded),
                        hintText: 'e.g. T 123 ABC',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _selectedTruckType,
                      decoration: const InputDecoration(
                        labelText: 'Truck Type',
                        prefixIcon: Icon(Icons.local_shipping_rounded),
                      ),
                      items: _truckTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedTruckType = v),
                      icon: const Icon(
                        Icons.expand_more_rounded,
                        color: AppTheme.outline,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Maximum Payload Capacity',
                        prefixIcon: Icon(Icons.scale_rounded),
                        suffixText: 'Tons',
                        hintText: 'e.g. 20',
                      ),
                    ),
                    const SizedBox(height: 24),

                    _SectionLabel(label: 'Truck Photos'),
                    const SizedBox(height: 12),
                    _PhotoUploadZone(
                      image: _truckImage,
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() => _truckImage = File(pickedFile.path));
                        }
                      },
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Upload at least one clear photo of your truck. JPG, PNG up to 10MB.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _SectionLabel(label: 'Service Area'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _homeBaseController,
                      decoration: const InputDecoration(
                        labelText: 'Home Base / Depot Location',
                        prefixIcon: Icon(Icons.location_on_rounded),
                        hintText: 'e.g. Dar es Salaam',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _routesController,
                      decoration: const InputDecoration(
                        labelText: 'Preferred Routes (Optional)',
                        prefixIcon: Icon(Icons.route_rounded),
                        hintText: 'e.g. DSM → Dodoma, DSM → Mwanza',
                      ),
                    ),
                    const SizedBox(height: 32),

                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _GradientButton(
                            label: 'Continue to Route Details',
                            icon: Icons.arrow_forward_rounded,
                            onTap: () async {
                              if (_selectedTruckType == null) return;
                              setState(() => _isLoading = true);
                              try {
                                final truck = await TruckService().addTruck(
                                  licensePlate: _plateController.text.trim(),
                                  truckType: _selectedTruckType!,
                                  payloadCapacity: double.tryParse(_capacityController.text) ?? 0.0,
                                  homeBase: _homeBaseController.text.trim(),
                                  preferredRoutes: _routesController.text.trim(),
                                  imageFile: _truckImage,
                                );
                                if (!context.mounted) return;
                                setState(() => _isLoading = false);
                                if (truck != null) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => CreateListingStep2Screen(
                                              truckId: truck.id,
                                              truckPlate: truck.licensePlate,
                                              truckType: truck.truckType,
                                              payloadCapacity: truck.payloadCapacity,
                                              homeBase: truck.homeBase,
                                              hasPhoto: _truckImage != null,
                                            )),
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
      ),
    );
  }
}

class _ListingHeader extends StatelessWidget {
  const _ListingHeader({required this.onBack});
  final VoidCallback onBack;

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
                    const Text(
                      'Step 1 of 3 — Vehicle Details',
                      style: TextStyle(
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
                    horizontal: 10,
                    vertical: 6,
                  ),
                  backgroundColor: AppTheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
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

class _PhotoUploadZone extends StatelessWidget {
  const _PhotoUploadZone({required this.image, required this.onTap});
  final File? image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = image != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 140,
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
          image: hasPhoto
              ? DecorationImage(
                  image: FileImage(image!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.2),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasPhoto
                    ? Icons.check_circle_rounded
                    : Icons.add_photo_alternate_rounded,
                size: 36,
                color: hasPhoto
                    ? Colors.white
                    : AppTheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                hasPhoto ? 'Photo Added \u2713' : 'Tap to Upload Truck Photo',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: hasPhoto
                      ? Colors.white
                      : AppTheme.onSurfaceVariant,
                ),
              ),
              if (!hasPhoto) ...[
                const SizedBox(height: 4),
                const Text(
                  'or drag and drop here',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppTheme.outline,
                  ),
                ),
              ],
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
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
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
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
