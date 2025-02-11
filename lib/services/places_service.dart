import 'dart:convert';
import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class PlacesService {
  static final String _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  Future<List<Map<String, dynamic>>> searchPlaces(
      String query, LatLng userLocation, String openMode) async {
    final String url =
        "https://maps.googleapis.com/maps/api/place/textsearch/json?"
        "query=$query&location=${userLocation.latitude},${userLocation.longitude}"
        "&radius=5000&key=$_apiKey";

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data["results"];

        return results
            .map((place) => _parsePlace(place, openMode))
            .where((place) => place != null)
            .cast<Map<String, dynamic>>()
            .toList();
      } else {
        throw Exception("Error en obtenir els llocs: ${response.body}");
      }
    } catch (e) {
      print("Error en searchPlaces: $e");
      return [];
    }
  }

  Map<String, dynamic>? _parsePlace(
      Map<String, dynamic> place, String openMode) {
    final bool isOpen = place["opening_hours"]?["open_now"] ?? false;

    if (openMode == "open" && !isOpen) return null;

    return {
      "id": place["place_id"],
      "name": place["name"],
      "address": place["formatted_address"],
      "lat": place["geometry"]["location"]["lat"],
      "lng": place["geometry"]["location"]["lng"],
      "rating": place["rating"] ?? 0.0,
      "open_now": isOpen
    };
  }

  double _distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Radi de la Terra en km
    final double dLat = (lat2 - lat1) * pi / 180;
    final double dLon = (lon2 - lon1) * pi / 180;

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  List<Map<String, dynamic>> orderPlaces(List<Map<String, dynamic>> places,
      double userLat, double userLon, String orderMode) {
    if (places.isEmpty) return [];

    if (orderMode == "rating") {
      places.sort((a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0));
    } else {
      places.sort((a, b) => _distanceBetween(
              userLat, userLon, a['lat'], a['lng'])
          .compareTo(_distanceBetween(userLat, userLon, b['lat'], b['lng'])));
    }

    return _nearestNeighborOrdering(places);
  }

  List<Map<String, dynamic>> _nearestNeighborOrdering(
      List<Map<String, dynamic>> places) {
    List<Map<String, dynamic>> ordered = [];
    Set<int> visited = {};
    if (places.isEmpty) return [];

    ordered.add(places.first);
    visited.add(0);

    while (visited.length < places.length) {
      int indexMin = -1;
      double minDist = double.infinity;

      for (int i = 0; i < places.length; i++) {
        if (!visited.contains(i)) {
          double dist = _distanceBetween(ordered.last['lat'],
              ordered.last['lng'], places[i]['lat'], places[i]['lng']);
          if (dist < minDist) {
            minDist = dist;
            indexMin = i;
          }
        }
      }

      if (indexMin != -1) {
        ordered.add(places[indexMin]);
        visited.add(indexMin);
      }
    }

    return ordered;
  }

  Future<List<LatLng>> getRoute(
      LatLng origin, LatLng destination, String mode) async {
    final String url = "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${origin.latitude},${origin.longitude}"
        "&destination=${destination.latitude},${destination.longitude}"
        "&mode=$mode&key=$_apiKey";

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["routes"].isNotEmpty) {
          final points = data["routes"][0]["overview_polyline"]["points"];
          return _decodePolyline(points);
        }
      }
    } catch (e) {
      print("Error en getRoute: $e");
    }
    return [];
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      lat += _decodeNext(encoded, index);
      index = _nextIndex(encoded, index);
      lng += _decodeNext(encoded, index);
      index = _nextIndex(encoded, index);

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }

  int _decodeNext(String encoded, int index) {
    int shift = 0, result = 0;
    int byte;
    do {
      if (index >= encoded.length) break;
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1F) << shift;
      shift += 5;
    } while (byte >= 0x20);
    return (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
  }

  int _nextIndex(String encoded, int index) {
    int len = encoded.length;
    while (index < len && encoded.codeUnitAt(index) >= 0x20) {
      index++;
    }
    return index + 1;
  }
}
