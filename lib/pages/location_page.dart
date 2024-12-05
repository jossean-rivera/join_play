import 'package:flutter/cupertino.dart';
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
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Location Page"),
      ),
      child: SafeArea(
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
                CupertinoButton.filled(
                  onPressed: _getCurrentPosition,
                  child: const Text("Get Current Location"),
                ),
                const SizedBox(height: 32),
                CupertinoSearchTextField(
                  controller: _addressController,
                  placeholder: "Enter address",
                  onSubmitted: (input) async {
                    final suggestions =
                        await _fetchAddressSuggestionsFromPlacesApi(input);
                    if (suggestions.isNotEmpty) {
                      _addressController.text =
                          suggestions.first.formattedAddress ??
                              suggestions.first.name;
                      _getLatLngFromPlaceId(suggestions.first.placeId);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text('ADDR LAT: ${_addressLat ?? ''}'),
                Text('ADDR LNG: ${_addressLon ?? ''}'),
                Text(
                  'Distance: ${_distance?.toStringAsFixed(2) ?? '?'} km',
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<PlacesSearchResult>> _fetchAddressSuggestionsFromPlacesApi(
      String input) async {
    try {
      return _addressesRepository.searchAddress(input);
    } catch (e) {
      debugPrint('Failed to get address suggestions $e');
      return [];
    }
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
      CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text('Failed to fetch location from address. $e'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
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
