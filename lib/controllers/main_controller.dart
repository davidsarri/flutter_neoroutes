import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:neoroutes/services/places_service.dart';

class MainController with ChangeNotifier {
  final PlacesService _placesService = PlacesService();
  GoogleMapController? _mapController;
  LatLng? _userLocation; // Ubicació de l'usuari (pot ser null al principi)
  final Set<Marker> _markers = {};
  List<Map<String, dynamic>?> _places = [];
  final Set<Polyline> _polylines = {}; // Nova variable per emmagatzemar la ruta
  bool isLoading = false;
  bool searchedPlaces = false;
  bool drawedmap = false;

  LatLng? get userLocation => _userLocation;
  Set<Marker> get markers => _markers;
  List<Map<String, dynamic>?> get places => _places;

  MainController() {
    _getUserLocation();
  }

  Set<Polyline> get getPolylines {
    return _polylines;
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    if (_userLocation != null) {
      centerMap();
    }
  }

  // Obtenir ubicació de l'usuari i centrar el mapa
  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("El servei de localització no està activat.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("Permís de localització denegat.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint(
          "Els permisos de localització estan bloquejats permanentment.");
      return;
    }

    // ignore: unused_local_variable
    Position position = await Geolocator.getCurrentPosition();
    //LatLng newLocation = LatLng(position.latitude, position.longitude);

    LatLng newLocation = LatLng(41.3874, 2.1686);
    _userLocation = LatLng(41.3874,
        2.1686); // ubicacio per defecte a barcelona per evitar problemes amb l'emulador

    if (_userLocation == null || _userLocation != newLocation) {
      _userLocation = newLocation;
      _setUserMarker();
      notifyListeners(); // Només notifica si realment ha canviat
    }

    if (_mapController != null) {
      centerMap();
    }
  }

  // Centrar la càmera a la ubicació de l'usuari
  void centerMap() {
    if (_mapController != null && _userLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_userLocation!, 15),
      );
    }
  }

  // Buscar llocs amb Google Places API
  Future<void> searchPlaces(
      String query, String travelMode, String openMode) async {
    if (_userLocation == null) {
      debugPrint("Encara no tenim la ubicació de l'usuari, esperant...");
      await _getUserLocation();
    }

    if (_userLocation == null) {
      debugPrint("Error: No s'ha pogut obtenir la ubicació de l'usuari.");
      return;
    }

    isLoading = true;
    searchedPlaces = true;

    try {
      _places =
          await _placesService.searchPlaces(query, _userLocation!, openMode);
      if (_places.isNotEmpty) {
        _places = _placesService.orderPlaces(
            _places
                .where((place) => place != null)
                .cast<Map<String, dynamic>>()
                .toList(), // Filtrar els valors null
            _userLocation!.latitude,
            _userLocation!.longitude);
        _updateMarkers();
        _drawRouteToFirstPlace(travelMode);
      }
    } catch (e) {
      debugPrint("Error buscant llocs: $e");
    }

    isLoading = false;
    searchedPlaces = false;
    notifyListeners();
  }

  // Afegir marcadors al mapa
  void _updateMarkers() {
    if (_userLocation == null) return;

    _markers.clear();

    // Afegir el marcador de la ubicació de l'usuari
    _setUserMarker();

    // Afegir marcadors dels llocs trobats
    for (var place in _places) {
      _markers.add(
        Marker(
          markerId: MarkerId(place?["id"]),
          position: LatLng(place?["lat"], place?["lng"]),
          infoWindow: InfoWindow(
            title: place?["name"],
            snippet: place?["open_now"] ? "Obert ara" : "Tancat ara",
          ),
        ),
      );
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(_markers.first.position),
    );
  }

  void _setUserMarker() {
    _markers.add(
      Marker(
        markerId: const MarkerId("user_location"),
        position: _userLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: "Tu estàs aquí"),
      ),
    );
  }

  Future<void> _drawRouteToFirstPlace(String travelMode) async {
    if (_places.isEmpty || _userLocation == null) return;
    drawedmap = false;

    LatLng destination = LatLng(_places[0]?["lat"], _places[0]?["lng"]);
    List<LatLng> route =
        await _placesService.getRoute(_userLocation!, destination, travelMode);

    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId("route"),
        points: route,
        color: Colors.blue,
        width: 5,
      ),
    );
    drawedmap = true;
    notifyListeners();
  }
}
