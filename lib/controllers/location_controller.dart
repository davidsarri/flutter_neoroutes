import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:neoroutes/services/location_service.dart';

class LocationController with ChangeNotifier {
  final LocationService _locationService = LocationService();
  LatLng? _userLocation;
  String _userCity = "";
  bool isInitialized = false;

  LatLng? get userLocation => _userLocation;
  String get userCity => _userCity;

  Future<void> init() async {
    await _getUserLocation();
    await _getUserCity();

    isInitialized = true;
    notifyListeners();
  }

  Future<LatLng?> fetchUserLocation() async {
    await _getUserLocation();
    return _userLocation;
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    //_userLocation = LatLng(position.latitude, position.longitude);
    _userLocation = LatLng(41.3874, 2.1686);
    notifyListeners();
  }

  Future<void> _getUserCity() async {
    if (_userLocation == null) return;
    _userCity = await _locationService.getCityFromLocation(
        _userLocation!.latitude, _userLocation!.longitude);
    notifyListeners();
  }
}
