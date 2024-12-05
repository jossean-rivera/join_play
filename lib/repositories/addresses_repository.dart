import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';

import '../secrets.dart';

class AddressesRepository {
  final _placesApi = GoogleMapsPlaces(apiKey: googleApiKey);

  /// Searches for addresses that match the given search input.
  Future<List<PlacesSearchResult>> searchAddress(String searchInput) async {
    PlacesSearchResponse search = await _placesApi.searchByText(searchInput);
    if (search.status == "OK" && search.results.isNotEmpty) {
      return search.results;
    }
    debugPrint(
        'Did not get a successful response for address suggestions. Error: ${search.errorMessage}');
    return [];
  }

  /// Determines if the user has granted location permissions.
  /// If not, it will ask the user to grant access.
  /// Returns false if the user never granted access.
  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled. Please enable them.');
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied.');
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint(
          'Location permissions are permanently denied. Cannot request permissions.');
      return false;
    }
    return true;
  }

  /// Gets the current position of the device if the user has granted access.
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return null;
    return await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high));
  }

  /// Gets a placemark where you can retrieve address details from a position object.
  Future<Placemark?> getAddressFromPosition(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    return placemarks.isNotEmpty ? placemarks[0] : null;
  }

  /// Gets details for a place from the Google Places API using a place ID.
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    final placeDetails = await _placesApi.getDetailsByPlaceId(placeId);

    if (placeDetails.status == "OK" && placeDetails.result.geometry != null) {
      return placeDetails.result;
    }

    debugPrint(
        'Failure while getting place details from API. Error: ${placeDetails.errorMessage}');
    return null;
  }

  /// Calculates the distance between two coordinates using the Haversine formula.
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in km.
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  /// Converts degrees to radians.
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
