import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../services/listing_service.dart';
import '../../services/map_route_service.dart';
import '../../models/listing_model.dart';
import '../../models/truck_model.dart';
import 'browse_trucks_list_screen.dart';
import 'truck_detail_screen.dart';

class BrowseTrucksMapScreen extends StatefulWidget {
  final String? searchOrigin;
  final String? searchDestination;
  final String? searchCargoType;

  const BrowseTrucksMapScreen({
    super.key,
    this.searchOrigin,
    this.searchDestination,
    this.searchCargoType,
  });

  @override
  State<BrowseTrucksMapScreen> createState() => _BrowseTrucksMapScreenState();
}

class _BrowseTrucksMapScreenState extends State<BrowseTrucksMapScreen> {
  GoogleMapController? _mapController;
  final MapRouteService _routeService = MapRouteService();
  
  List<ListingModel> _listings = [];
  Map<String, LatLng> _truckLocations = {}; // Listing ID -> Location
  
  ListingModel? _selectedListing;
  TruckModel? _selectedTruck;
  
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoadingRoute = false;

  final LatLng _defaultCenter = const LatLng(-6.8045, 39.2831);

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    var listings = await ListingService().getAvailableListings().first;
    if (!mounted) return;

    if (widget.searchOrigin != null && widget.searchOrigin!.isNotEmpty) {
      listings = listings.where((l) => l.origin.toLowerCase().contains(widget.searchOrigin!.toLowerCase())).toList();
    }
    if (widget.searchDestination != null && widget.searchDestination!.isNotEmpty) {
      listings = listings.where((l) => l.destination.toLowerCase().contains(widget.searchDestination!.toLowerCase())).toList();
    }
    if (widget.searchCargoType != null && widget.searchCargoType!.isNotEmpty) {
      listings = listings.where((l) => l.cargoPreferences.isEmpty || l.cargoPreferences.any((pref) => pref.toLowerCase() == widget.searchCargoType!.toLowerCase())).toList();
    }

    final random = Random(42); // fixed seed for consistent dummy locations
    final Map<String, LatLng> locations = {};
    
    for (var listing in listings) {
      // Generate dummy location near Dar es Salaam for demo purposes
      final lat = -6.8045 + (random.nextDouble() - 0.5) * 0.08;
      final lng = 39.2831 + (random.nextDouble() - 0.5) * 0.08;
      locations[listing.id] = LatLng(lat, lng);
    }

    setState(() {
      _listings = listings;
      _truckLocations = locations;
    });
    
    _updateMarkers();
  }

  void _updateMarkers() {
    final Set<Marker> markers = {};
    
    for (var listing in _listings) {
      final loc = _truckLocations[listing.id];
      if (loc == null) continue;
      
      final isSelected = _selectedListing?.id == listing.id;
      
      markers.add(
        Marker(
          markerId: MarkerId(listing.id),
          position: loc,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSelected ? BitmapDescriptor.hueRed : BitmapDescriptor.hueAzure,
          ),
          onTap: () => _onListingSelected(listing),
        ),
      );
    }
    
    setState(() {
      _markers = markers;
    });
  }

  Future<void> _onListingSelected(ListingModel listing) async {
    setState(() {
      _selectedListing = listing;
      _selectedTruck = null;
      _isLoadingRoute = true;
      _polylines.clear();
    });
    _updateMarkers();

    // Fetch truck details
    final truckDoc = await FirebaseFirestore.instance.collection('trucks').doc(listing.truckId).get();
    if (mounted && truckDoc.exists) {
      setState(() {
        _selectedTruck = TruckModel.fromMap(truckDoc.data()!, truckDoc.id);
      });
    }

    // Fetch route points
    final points = await _routeService.getRoutePoints(listing.origin, listing.destination);
    
    if (mounted && _selectedListing?.id == listing.id) {
      setState(() {
        _isLoadingRoute = false;
        if (points.isNotEmpty) {
          _polylines = {
            Polyline(
              polylineId: PolylineId('route_${listing.id}'),
              points: points,
              color: AppTheme.primaryColor,
              width: 5,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            )
          };
        }
      });
      
      // Fit bounds to route + truck location
      if (_mapController != null && points.isNotEmpty) {
        final truckLoc = _truckLocations[listing.id];
        if (truckLoc != null) points.add(truckLoc);
        
        final bounds = MapRouteService.boundsFromPoints(points);
        _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainerLow,
      body: Stack(
        children: [
          // Google Map Background
          Positioned.fill(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _defaultCenter,
                zoom: 12.0,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onTap: (_) {
                // Deselect when tapping on empty map
                if (_selectedListing != null) {
                  setState(() {
                    _selectedListing = null;
                    _selectedTruck = null;
                    _polylines.clear();
                  });
                  _updateMarkers();
                }
              },
            ),
          ),
          
          // Route Loading Indicator
          if (_isLoadingRoute)
            const Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 12),
                        Text('Loading truck route...', style: TextStyle(fontFamily: 'Inter', fontSize: 13)),
                      ],
                    ),
                  ),
                ),
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
                      Expanded(
                        child: Text(
                          (widget.searchOrigin != null && widget.searchDestination != null && widget.searchOrigin!.isNotEmpty && widget.searchDestination!.isNotEmpty)
                              ? '${widget.searchOrigin} → ${widget.searchDestination}'
                              : (widget.searchOrigin != null && widget.searchOrigin!.isNotEmpty) ? '${widget.searchOrigin} → Anywhere' 
                              : (widget.searchDestination != null && widget.searchDestination!.isNotEmpty) ? 'Anywhere → ${widget.searchDestination}'
                              : 'All Available Trucks',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
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

          // Selected Truck Details Bottom Sheet overlay
          if (_selectedListing != null)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: _SelectedTruckPreview(
                listing: _selectedListing!,
                truck: _selectedTruck,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => BrowseTrucksListScreen(
            searchOrigin: widget.searchOrigin,
            searchDestination: widget.searchDestination,
            searchCargoType: widget.searchCargoType,
          )),
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

class _SelectedTruckPreview extends StatelessWidget {
  final ListingModel listing;
  final TruckModel? truck;
  
  const _SelectedTruckPreview({required this.listing, this.truck});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => TruckDetailScreen(listing: listing)),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    truck?.truckType ?? 'Loading...',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${listing.origin} → ${listing.destination}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'TZS ${listing.rate}',
                    style: const TextStyle(
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
