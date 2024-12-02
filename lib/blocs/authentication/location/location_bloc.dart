import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../repositories/addresses_repository.dart';
import '../../../widgets/address_picker.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final AddressesRepository addressesRepository;
  bool _currentLocationAquired = false;

  String? _location;
  String? _locationName;
  double? _latitude;
  double? _longitude;

  /// Determines whether or not we have aquired an address
  get locationAquired => _currentLocationAquired;

  /// Address of the current location of the device.
  get currLocation => _location ?? '';

  /// Address name of the current location
  get currLocationName => _locationName ?? '';

  /// Latitude of the current location
  get currLocationLatitude => _latitude ?? 0;

  /// Longitud of the current location
  get currLocationLongitude => _longitude ?? 0;

  LocationBloc(this.addressesRepository) : super(LocationInitial()) {
    // handle event to save current address
    on<SaveLocationEvent>((event, emit) {
      if (_currentLocationAquired) {
        // The current location has already been set.
        return;
      }
      var place = event.placemark;
      if (place != null) {
        _locationName = place.name ??
            "${place.subLocality},\n${place.subAdministrativeArea},\n${place.postalCode}";
        _location =
            '${place.street},\n${place.subLocality},\n${place.subAdministrativeArea},\n${place.postalCode}';
      } 
      _latitude = event.latitude;
      _longitude = event.longitude;
      _currentLocationAquired = true;

      emit(LocationLoaded(
          latitude: _latitude!,
          longitude: _longitude!,
          address: _location!,
          addressName: _locationName!));
    });
    // Handle the event to make sure we have granted the
    on<RequestCurrentLocationEvent>((event, emit) async {
      if (_currentLocationAquired) {
        // The current location has already been set.
        return;
      }

      // Try to get the location of the device.
      Position? position = await addressesRepository.getCurrentPosition();
      if (position != null) {
        Placemark? place =
            await addressesRepository.getAddressFromPosition(position);
        if (place != null) {
          _locationName = place.name ??
              "${place.subLocality},\n${place.subAdministrativeArea},\n${place.postalCode}";
          _location =
              '${place.street},\n${place.subLocality},\n${place.subAdministrativeArea},\n${place.postalCode}';
          _latitude = position.latitude;
          _longitude = position.longitude;
          _currentLocationAquired = true;
          emit(LocationLoaded(
              latitude: _latitude!,
              longitude: _longitude!,
              address: _location!,
              addressName: _locationName!));
        }
      }
    });
  }

  /// Shows dialoag when user has not granted location access. Ask user to select the address to search for events.
  Future<void> showLocationUnavailableDialog(
      {required BuildContext context, Function? onCancel}) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final GlobalKey<FormState> formKey = GlobalKey<FormState>();
          final TextEditingController textController = TextEditingController();

          return AlertDialog(
            title: const Text('Location Unavailable'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Location services are disabled. Please either enable the service '
                  'or select the address you would like to find events.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Form(
                  key: formKey,
                  child: AddressPicker(
                      addressController: textController,
                      addressesRepository: addressesRepository,
                      onSuccess: (addressName, address, lat, long) {
                        _locationName = addressName;
                        _location = address;
                        _latitude = lat;
                        _longitude = long;
                        _currentLocationAquired = true;
                      }),
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    GoRouter.of(context).pop();
                  }
                },
                child: const Text('Submit'),
              ),
              TextButton(
                  onPressed: () {
                    GoRouter.of(context).pop();
                    onCancel?.call();
                  },
                  child: const Text('Cancel'))
            ],
          );
        });
  }

    /// Shows dialoag to override the current location by allowing the user to pick it.
  Future<void> showChangeLocationDialog(
      {required BuildContext context, Function? onCancel}) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final GlobalKey<FormState> formKey = GlobalKey<FormState>();
          final TextEditingController textController = TextEditingController();

          return AlertDialog(
            title: const Text('Change Location'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select your location to see sport events.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Form(
                  key: formKey,
                  child: AddressPicker(
                      addressController: textController,
                      addressesRepository: addressesRepository,
                      onSuccess: (addressName, address, lat, long) {
                        _locationName = addressName;
                        _location = address;
                        _latitude = lat;
                        _longitude = long;
                        _currentLocationAquired = true;
                      }),
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    GoRouter.of(context).pop();
                  }
                },
                child: const Text('Submit'),
              ),
              TextButton(
                  onPressed: () {
                    GoRouter.of(context).pop();
                    onCancel?.call();
                  },
                  child: const Text('Cancel'))
            ],
          );
        });
  }

}
