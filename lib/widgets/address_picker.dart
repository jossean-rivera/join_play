import 'package:flutter/cupertino.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_webservice/places.dart';

import '../custom_theme_data.dart';
import '../repositories/addresses_repository.dart';

/// Reusable widget for a text field to select an address.
class AddressPicker extends StatefulWidget {
  final TextEditingController addressController;
  final AddressesRepository addressesRepository;
  final void Function(String? errorMessage)? onError;
  final void Function(String locationTitle, String location, double latitude,
      double longitude) onSuccess;

  AddressPicker({
    super.key,
    required this.addressesRepository,
    TextEditingController? addressController,
    required this.onSuccess,
    this.onError,
  }) : addressController = addressController ?? TextEditingController();

  @override
  State<AddressPicker> createState() => _AddressPickerState();
}

class _AddressPickerState extends State<AddressPicker> {
  double? _addressLat;
  double? _addressLon;
  String? _location;
  String? _locationTitle;

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<PlacesSearchResult>(
      controller: widget.addressController,
      builder: (context, controller, focusNode) {
        return CupertinoTextFormFieldRow(
          controller: controller,
          focusNode: focusNode,
          placeholder: 'Enter address',
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a location';
            }

            if (_addressLat == null || _addressLon == null) {
              return 'Please select a valid address';
            }
            return null;
          },
          onSaved: (value) {
            _location = value;
          },
        );
      },
      suggestionsCallback: (pattern) async {
        return await _fetchAddressSuggestionsFromPlacesApi(pattern);
      },
      itemBuilder: (context, suggestion) {
        return CupertinoListTile(
          title: Text(suggestion.name),
          subtitle: Text(suggestion.formattedAddress ?? suggestion.name),
        );
      },
      onSelected: _processSelectedSuggestion,
      emptyBuilder: (context) {
        if (widget.addressController.text.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Start typing to see suggestions',
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Could not find address',
            style: CupertinoTheme.of(context)
                .textTheme
                .textStyle
                .copyWith(color: CupertinoColors.destructiveRed),
          ),
        );
      },
    );
  }

  /// Saves latitude and longitude for the given place that was selected in the type-ahead control.
  Future<void> _getLatLngFromPlaceId(String placeId) async {
    try {
      final details = await widget.addressesRepository.getPlaceDetails(placeId);
      if (details != null && details.geometry != null) {
        setState(() {
          _addressLat = details.geometry!.location.lat;
          _addressLon = details.geometry!.location.lng;
        });
      }
    } catch (e) {
      debugPrint('Could not get coordinates of a place Id. Error: $e');
      widget.onError?.call('Failed to get address details. Try again later.');
    }
  }

  /// Processes the selected suggestion.
  Future<void> _processSelectedSuggestion(PlacesSearchResult suggestion) async {
    setState(() {
      widget.addressController.text = suggestion.name.isEmpty
          ? suggestion.formattedAddress ?? ''
          : suggestion.name;

      _location = '${suggestion.name}\n${suggestion.formattedAddress}';
      _locationTitle = suggestion.name;
    });

    await _getLatLngFromPlaceId(suggestion.placeId);

    if (_addressLat == null || _addressLon == null) {
      widget.onError?.call('Failed to get address details. Try again later.');
      return;
    }

    widget.onSuccess(
      _locationTitle!,
      _location!,
      _addressLat!,
      _addressLon!,
    );
  }

  /// Gets address suggestions for the type-ahead control.
  Future<List<PlacesSearchResult>> _fetchAddressSuggestionsFromPlacesApi(
      String input) async {
    try {
      if (input.isEmpty) return [];
      return widget.addressesRepository.searchAddress(input);
    } catch (e) {
      debugPrint('Failed to get address suggestions $e');
      return [];
    }
  }
}
