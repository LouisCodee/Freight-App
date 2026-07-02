import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String apiKey = 'AIzaSyDw_s6EaW5D-bl06NCs-Q9LAnj2SuMqSt8';
  final origin = 'Dar es Salaam, Tanzania';
  final destination = 'Dodoma, Tanzania';

  final url = Uri.parse('https://routes.googleapis.com/directions/v2:computeRoutes');

  print('Calling Routes API...');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
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

  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
}
