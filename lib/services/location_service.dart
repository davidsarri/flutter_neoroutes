import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static final String _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  Future<String> getCityFromLocation(double latitude, double longitude) async {
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_apiKey";

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
