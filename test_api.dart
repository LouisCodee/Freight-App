import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String apiKey = 'AIzaSyDw_s6EaW5D-bl06NCs-Q9LAnj2SuMqSt8';
  final origin = 'Dar es Salaam';
  final destination = 'Dodoma';

  final url = Uri.parse(
    'https://maps.googleapis.com/maps/api/directions/json'
    '?origin=${Uri.encodeComponent(origin)}'
    '&destination=${Uri.encodeComponent(destination)}'
    '&mode=driving'
    '&key=$apiKey',
  );

  print('Calling API...');
  final response = await http.get(url);
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
}
