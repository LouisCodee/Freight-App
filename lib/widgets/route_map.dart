import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/map_route_service.dart';
import '../theme/app_theme.dart';

/// A full-featured map widget that:
/// - Calls Directions API to get the route polyline
/// - Draws origin & destination markers
/// - Draws the driving route as a polyline
/// - Fits the camera to the route bounds
class RouteMap extends StatefulWidget {
  final String origin;
  final String destination;
  final double height;
  final bool roundedCorners;
  final bool fullScreen;

  const RouteMap({
    super.key,
    required this.origin,
    required this.destination,
    this.height = 220,
    this.roundedCorners = true,
    this.fullScreen = false,
  });

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  GoogleMapController? _mapController;
  final MapRouteService _routeService = MapRouteService();

  List<LatLng> _routePoints = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  bool _loading = true;
  bool _error = false;

  // Default Tanzania center while route loads
  static const LatLng _defaultCenter = LatLng(-6.8045, 39.2831);

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  @override
  void didUpdateWidget(RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.origin != widget.origin ||
        oldWidget.destination != widget.destination) {
      _loadRoute();
    }
  }

  Future<void> _loadRoute() async {
    if (widget.origin.isEmpty || widget.destination.isEmpty) return;

    setState(() {
      _loading = true;
      _error = false;
    });

    final points =
        await _routeService.getRoutePoints(widget.origin, widget.destination);

    if (!mounted) return;

    if (points.isEmpty) {
      setState(() {
        _loading = false;
        _error = true;
      });
      return;
    }

    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: points,
      color: AppTheme.primaryColor,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    final originMarker = Marker(
      markerId: const MarkerId('origin'),
      position: points.first,
      infoWindow: InfoWindow(title: widget.origin),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    final destMarker = Marker(
      markerId: const MarkerId('destination'),
      position: points.last,
      infoWindow: InfoWindow(title: widget.destination),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      _routePoints = points;
      _polylines = {polyline};
      _markers = {originMarker, destMarker};
      _loading = false;
    });

    // Fit camera to the route bounds after map is ready
    _fitCameraToBounds();
  }

  Future<void> _fitCameraToBounds() async {
    if (_mapController == null || _routePoints.isEmpty) return;
    final bounds = MapRouteService.boundsFromPoints(_routePoints);
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 60),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_routePoints.isNotEmpty) {
      _fitCameraToBounds();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build the map stack
    final Widget mapStack = Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: _defaultCenter,
            zoom: 7,
          ),
          polylines: _polylines,
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),

        // Loading overlay
        if (_loading)
          Container(
            color: AppTheme.surfaceContainerLowest.withValues(alpha: 0.85),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'Loading route…',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Error overlay
        if (_error)
          Container(
            color: AppTheme.surfaceContainerLowest.withValues(alpha: 0.9),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.map_outlined,
                      size: 36, color: AppTheme.onSurfaceVariant),
                  const SizedBox(height: 8),
                  const Text(
                    'Route unavailable',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _loadRoute,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),

        // Route labels at top — only shown when not fullScreen
        if (!widget.fullScreen && !_loading && !_error)
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location_rounded,
                      size: 14, color: AppTheme.primaryColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.origin,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward_rounded,
                        size: 14, color: AppTheme.onSurfaceVariant),
                  ),
                  const Icon(Icons.location_on_rounded,
                      size: 14, color: AppTheme.secondaryColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.destination,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    // Full-screen mode: no wrapping container, just the raw stack
    if (widget.fullScreen) return mapStack;

    final Widget sizedStack = SizedBox(height: widget.height, child: mapStack);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: sizedStack,
      ),
    );
  }
}
