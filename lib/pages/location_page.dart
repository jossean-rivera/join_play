
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_webservice/places.dart' hide Location;
import 'package:geolocator/geolocator.dart';
import 'package:join_play/repositories/addresses_repository.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String? _currentAddress;
  Position? _currentPosition;
  Location? _addressLocation;
  double? _addressLat;
  double? _addressLon;
  double? _distance;
  final TextEditingController _addressController = TextEditingController();
  final AddressesRepository _addressesRepository = AddressesRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Location Page")),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('LAT: ${_currentPosition?.latitude ?? ''}'),
                  Text('LNG: ${_currentPosition?.longitude ?? ''}'),
                  Text('ADDRESS: ${_currentAddress ?? ''}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _getCurrentPosition,
                    child: const Text("Get Current Location"),
                  ),
                  const SizedBox(height: 32),
                  TypeAheadField<PlacesSearchResult>(
                    controller: _addressController,
                    builder: (context, controller, focusNode) {
                      return TextField(
                          enabled: _currentPosition != null,
                          controller: controller,
                          focusNode: focusNode,
                          autofocus: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter address',
                          ));
                    },
                    suggestionsCallback: (pattern) async {
                      return await _fetchAddressSuggestionsFromPlacesApi(
                          pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(
                            suggestion.formattedAddress ?? suggestion.name),
                      );
                    },
                    onSelected: (suggestion) {
                      _addressController.text =
                          suggestion.formattedAddress ?? suggestion.name;
                      _getLatLngFromPlaceId(suggestion.placeId);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('ADDR LAT: ${_addressLat ?? ''}'),
                  Text('ADDR LNG: ${_addressLon ?? ''}'),
                  Text(
                    'Distance: ${_distance?.toStringAsFixed(2) ?? '?'} km',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    'Distance: ${_distance?.toStringAsFixed(2) ?? '?'} km',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Future<List<PlacesSearchResult>> _fetchAddressSuggestionsFromPlacesApi(
      String input) async {
    try {
      return _addressesRepository.SearchAddress(input);
    } catch (e) {
      debugPrint('Failed to get address suggestions $e');
      return [];
    }
  }

  Future<bool> _handleLocationPermission() {
    return _addressesRepository.handleLocationPermission();
  }

  Future<void> _getCurrentPosition() async {
    Position? position = await _addressesRepository.getCurrentPosition();
    if (position != null) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng(position);
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      Placemark? place =
          await _addressesRepository.getAddressFromPosition(position);

      if (place != null) {
        setState(() {
          _currentAddress =
              '${place.street},\n${place.subLocality},\n${place.subAdministrativeArea},\n${place.postalCode}';
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location addressLocation = locations[0];
        double selectedLat = addressLocation.latitude;
        double selectedLon = addressLocation.longitude;

        if (_currentPosition != null) {
          double distance = _addressesRepository.calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            selectedLat,
            selectedLon,
          );
          setState(() {
            _distance = distance;
            _addressLocation = addressLocation;
            _addressLat = selectedLat;
            _addressLon = selectedLon;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch location from address. $e')),
      );
    }
  }

  Future<void> _getLatLngFromPlaceId(String placeId) async {
    final details = await _addressesRepository.getPlaceDetails(placeId);

    if (details != null &&
        details.geometry != null &&
        _currentPosition != null) {
      final double lat = details.geometry!.location.lat;
      final double lng = details.geometry!.location.lng;

      double distance = _addressesRepository.calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        lat,
        lng,
      );

      setState(() {
        _distance = distance;
        _addressLat = lat;
        _addressLon = lng;
      });
    }
  }
}
