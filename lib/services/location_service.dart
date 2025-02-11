import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class LocationService {
  final String _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  final String _apiUrl = dotenv.env['GOOGLE_GEOLOCATION_API_URL'] ?? '';

  Future<String> getCityFromLocation(double latitude, double longitude) async {
    String url = _apiUrl
        .replaceAll("[LATITUT]", latitude.toString())
        .replaceAll("[LONGITUD]", longitude.toString())
        .replaceAll("[APIKEY]", _apiKey);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["status"] == "OK") {
        for (var result in data["results"]) {
          for (var component in result["address_components"]) {
            if (component["types"].contains("locality")) {
              return component["long_name"];
            }
          }
        }
      }
    }
    throw Exception("No s'ha pogut obtenir la ciutat.");
  }
}
