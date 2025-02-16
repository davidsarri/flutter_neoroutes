import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:neoroutes/controllers/location_controller.dart';
import 'package:neoroutes/controllers/map_controller.dart';
import 'package:neoroutes/services/chatgpt_service.dart';
import 'package:neoroutes/services/places_service.dart';

class MainController with ChangeNotifier {
  final LocationController _locationController = LocationController();
  final MapController _mapController = MapController();
  final PlacesService _placesService = PlacesService();
  final ChatGPTService _chatGptService = ChatGPTService();

  bool isLoading = false;
  List<Map<String, dynamic>> _places = [];

  List<Map<String, dynamic>> get places => _places;
  LocationController get locationController => _locationController;
  MapController get mapController => _mapController;

  LatLng? _userLocation;

  LatLng? get userLocation => _userLocation;

  MainController() {
    _init();
  }

  Future<void> _init() async {
    await _locationController.init();
  }

  Future<LatLng?> getUserLocation() async {
    _userLocation = await _locationController.fetchUserLocation();
    return _userLocation;
  }

  Future<void> searchPlaces(String query, String travelMode, String openMode,
      String orderMode, String searchMode) async {
    if (!_locationController.isInitialized) {
      debugPrint("LocationController no està inicialitzat.");
      await _locationController.fetchUserLocation();
    }

    if (_locationController.userLocation == null) return;

    isLoading = true;

    try {
      if (searchMode == "google") {
        _places = (await _placesService.searchPlaces(
                query, _locationController.userLocation!, openMode))
            .whereType<Map<String, dynamic>>()
            .toList();
      } else if (searchMode == "chatGpt") {
        _places = await _chatGptService.queryChatGPT(
            query, _locationController.userCity);
      }

      if (_places.isEmpty == false) {
        _places = _placesService.orderPlaces(
            _places,
            _locationController.userLocation!.latitude,
            _locationController.userLocation!.longitude,
            orderMode);
      }
    } catch (e) {
      debugPrint("Error cercant llocs: $e");
    }

    isLoading = false;

    // Crida notifyListeners al final, fora del procés de construcció
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<List<LatLng>> getRouteTo(
      LatLng destination, LatLng userLocationActual) async {
    return await _placesService.getRoute(
      userLocationActual,
      destination,
      "driving",
    );
  }

  Future<void> drawRouteTo(
      LatLng destination, LatLng userLocationActual) async {
    List<LatLng> route = await _placesService.getRoute(
        userLocationActual, destination, "driving");

    _mapController.drawRoute(route);
  }

  double distanciaEnMetres(
      double latObjectiu, double lonObjectiu, LatLng userLocationActual) {
    return _placesService.distanciaEnMetres(
        userLocationActual, latObjectiu, lonObjectiu);
  }

  String getImageUrl(String photoReference) {
    return _placesService.getImageUrl(photoReference);
  }
}
