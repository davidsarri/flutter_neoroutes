import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController with ChangeNotifier {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;

  Set<Polyline> get getPolylines {
    return _polylines;
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  void updateMarkers(List<Map<String, dynamic>> places) {
    _markers.clear();
    for (var place in places) {
      _markers.add(
        Marker(
          markerId: MarkerId(place["id"]),
          position: LatLng(place["lat"], place["lng"]),
          infoWindow: InfoWindow(
            title: place["name"],
            snippet: (place["open_now"] ?? false) ? "Obert ara" : "Tancat ara",
          ),
        ),
      );
    }
    notifyListeners();
  }

  void drawRoute(List<LatLng> route) {
    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId("route"),
        points: route,
        color: Colors.blue,
        width: 5,
      ),
    );
    notifyListeners();
  }

  void centerMap(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 15),
    );
  }
}
