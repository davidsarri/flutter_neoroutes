import 'dart:convert';
import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class PlacesService {
  static final String _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  Future<List<Map<String, dynamic>?>> searchPlaces(
      String query, LatLng userLocation, String openMode) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&location=${userLocation.latitude},${userLocation.longitude}&radius=5000&key=$_apiKey";

    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List results = data["results"];

      // Filtrar i garantir que no hi ha elements nulls
      List<Map<String, dynamic>?> places = results.map((place) {
        if (openMode == "all") {
          return {
            "id": place["place_id"],
            "name": place["name"],
            "address": place["formatted_address"],
            "lat": place["geometry"]["location"]["lat"],
            "lng": place["geometry"]["location"]["lng"],
            "rating": place["rating"],
            "open_now": place["opening_hours"]?["open_now"] ?? false
          };
        } else {
          if (place["opening_hours"]?["open_now"] == true) {
            return {
              "id": place["place_id"],
              "name": place["name"],
              "address": place["formatted_address"],
              "lat": place["geometry"]["location"]["lat"],
              "lng": place["geometry"]["location"]["lng"],
              "rating": place["rating"],
              "open_now": place["opening_hours"]?["open_now"] ?? false
            };
          }
        }
      }).toList();

      return places;
    } else {
      throw Exception("Error en obtenir els llocs: ${response.body}");
    }
  }

  double distanceCalculator(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Radi de la Terra en km
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distància en km
  }

  List<Map<String, dynamic>> orderPlaces(List<Map<String, dynamic>> llocs,
      double userLat, double userLon, String orDerMode) {
    // Si orDerMode és "rating", ordenar per la valoració (rating)
    if (orDerMode == "rating") {
      llocs.sort((a, b) => (b['rating'] ?? 0).compareTo(a['rating'] ?? 0));
    } else {
      // Ordenar per proximitat a l'usuari si orDerMode no és "rating"
      llocs.sort((a, b) => distanceCalculator(
              userLat, userLon, a['lat'], a['lng'])
          .compareTo(distanceCalculator(userLat, userLon, b['lat'], b['lng'])));
    }

    List<Map<String, dynamic>> ordenats = [];
    Set<int> visitats = {};

    if (llocs.isEmpty) return [];

    // Agafem el primer element (més proper a l'usuari)
    Map<String, dynamic> actual = llocs.first;
    ordenats.add(actual);
    visitats.add(llocs.indexOf(actual));

    while (visitats.length < llocs.length) {
      double minDist = double.infinity;
      int indexMin = -1;

      // Buscar el següent punt més proper al punt actual
      for (int i = 0; i < llocs.length; i++) {
        if (!visitats.contains(i)) {
          double dist = distanceCalculator(
              actual['lat'], actual['lng'], llocs[i]['lat'], llocs[i]['lng']);
          if (dist < minDist) {
            minDist = dist;
            indexMin = i;
          }
        }
      }

      if (indexMin != -1) {
        actual = llocs[indexMin];
        ordenats.add(actual);
        visitats.add(indexMin);
      }
    }

    return ordenats;
  }

  Future<List<LatLng>> getRoute(
      LatLng origin, LatLng destination, String mode) async {
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=$mode&key=$_apiKey";

    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["routes"].isNotEmpty) {
        final points = data["routes"][0]["overview_polyline"]["points"];
        return _decodePolyline(points);
      }
    }
    return [];
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += deltaLng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }
}
