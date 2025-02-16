import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:neoroutes/services/places_service.dart';

class RouteMapView extends StatefulWidget {
  final double userLat;
  final double userLng;
  final double placeLat;
  final double placeLng;
  final String travelMode;

  const RouteMapView({
    super.key,
    required this.userLat,
    required this.userLng,
    required this.placeLat,
    required this.placeLng,
    required this.travelMode,
  });

  @override
  _RouteMapViewState createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<RouteMapView> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _loadRoute(widget.travelMode);
  }

  Future<void> _loadRoute(String travelMode) async {
    PlacesService placesService = PlacesService();
    LatLng origin = LatLng(widget.userLat, widget.userLng);
    LatLng destination = LatLng(widget.placeLat, widget.placeLng);

    List<LatLng> route =
        await placesService.getRoute(origin, destination, travelMode);

    if (route.isNotEmpty) {
      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blue,
            width: 5,
            points: route,
          ),
        );

        _markers.clear();
        _markers.add(Marker(
          markerId: const MarkerId('origin'),
          position: LatLng(widget.userLat, widget.userLng),
          infoWindow: const InfoWindow(title: 'Inici'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));

        _markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: destination,
          infoWindow: const InfoWindow(title: 'Destinació'),
        ));

        _fitBounds(route);
      });
    } else {
      debugPrint("No s'ha pogut carregar la ruta.");
    }
  }

  void _fitBounds(List<LatLng> route) {
    if (route.isEmpty) return;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        route.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
        route.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        route.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
        route.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
      ),
    );
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ruta a la destinació")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.userLat, widget.userLng),
          zoom: 14,
        ),
        markers: _markers,
        polylines: _polylines,
        onMapCreated: _onMapCreated,
      ),
    );
  }
}
