import 'dart:convert';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapRouteService {
  static const String _apiKey = 'AIzaSyDw_s6EaW5D-bl06NCs-Q9LAnj2SuMqSt8';

  /// Fetches driving route polyline between two place-name strings.
  /// Returns an empty list on failure.
  Future<List<LatLng>> getRoutePoints(String origin, String destination) async {
    final url = Uri.parse('https://routes.googleapis.com/directions/v2:computeRoutes');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey,
          'X-Goog-FieldMask': 'routes.polyline.encodedPolyline',
        },
        body: json.encode({
          'origin': {
            'address': origin
          },
          'destination': {
            'address': destination
          },
          'travelMode': 'DRIVE'
        }),
      );

      if (response.statusCode != 200) {
        print('Routes API Error: ${response.body}');
        return [];
      }

      final data = json.decode(response.body);
      if (data['routes'] == null || data['routes'].isEmpty) return [];

      final String encoded = data['routes'][0]['polyline']['encodedPolyline'];
      return _decodePolyline(encoded);
    } catch (e) {
      print('Routes API Exception: $e');
      return [];
    }
  }

  /// Decodes a Google-encoded polyline string into a list of LatLng.
  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  /// Computes a camera-fitting LatLngBounds that contains all given points.
  static LatLngBounds boundsFromPoints(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      minLat = min(minLat, p.latitude);
      maxLat = max(maxLat, p.latitude);
      minLng = min(minLng, p.longitude);
      maxLng = max(maxLng, p.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
