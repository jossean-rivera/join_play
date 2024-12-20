import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:join_play/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:join_play/blocs/authentication/location/location_bloc.dart';
import 'package:join_play/custom_theme_data.dart';
import 'package:join_play/models/sport_event.dart';
import 'package:join_play/navigation/route_names.dart';

import 'package:join_play/repositories/addresses_repository.dart';
import '../blocs/authentication/location/location_event.dart';

import '../utilities/firebase_service.dart';
import 'package:join_play/models/sport_user.dart';

String toCamelCase(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}


class SportDetailsPage extends StatefulWidget {
  final String sportId;
  final FirebaseService firebaseService;
  final AuthenticationBloc authenticationBloc;
  final AddressesRepository addressesRepository;

  const SportDetailsPage(
      {super.key,
      required this.sportId,
      required this.firebaseService,
      required this.authenticationBloc,
      required this.addressesRepository});

  @override
  State<SportDetailsPage> createState() => _SportDetailsPageState();
}

class _SportDetailsPageState extends State<SportDetailsPage> {
  bool showUnavailable = false;

  late LocationBloc _locationBloc;
  late AuthenticationBloc _authenticationBloc;
  final DateFormat dateFormat = DateFormat('MM/dd/yyyy HH:mm');

  // Radius for the events to display
  static const double _radiusInKM = 100;

  void _navigateToForm(BuildContext context, String sportId) {
    context.goNamed(
      RouteNames.gameForm,
      pathParameters: {'sportId': sportId},
    );
  }

  @override
  void initState() {
    _locationBloc = BlocProvider.of<LocationBloc>(context);
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          toCamelCase(widget.sportId),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          Switch(
            value: showUnavailable,
            onChanged: (value) {
              setState(() {
                showUnavailable = value;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                showUnavailable ? "Unavailable" : "Available",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<SportEvent>>(
        future: _loadAllData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display loading icon
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Display error
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Display label that says there are no nearby events
            // Give the option to change the location.
            if (_locationBloc.locationAquired != null &&
                _locationBloc.currLocationName.isNotEmpty) {
              return Center(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("No events close to ${_locationBloc.currLocationName}"),
                  const SizedBox(
                    height: 8,
                  ),
                  TextButton(
                      onPressed: () async {
                        // Show dialog to change address
                        await _locationBloc.showChangeLocationDialog(
                            context: context);

                        // Refresh UI
                        setState(() {});
                      },
                      child: const Text('Change location'))
                ],
              ));
            }
            return const Center(
                child: Text("No events available for this sport."));
          } else {
            final events = snapshot.data!;

            if (events.isEmpty) {
              return const Center(child: Text("No matching events found."));
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    // Set options to avoid conflicting scroll with single child scroll view
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      // Get current user ID
                      final currentUserId =
                          widget.authenticationBloc.sportUser?.uuid ?? '';

                      // Check if the user is registered for this event
                      final isRegistered =
                          event.registeredUsers?.contains(currentUserId) ??
                              false;

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                            title: Text(event.name ?? ''),
                            subtitle: Text(
                              "Location: ${event.location}\n"
                              "Time: ${event.dateTime == null ? 'none' : dateFormat.format(event.dateTime!.toDate())}\n"
                              "Slots Available: ${event.slotsAvailable}\n"
                              "Host: ${event.hostName}",
                            ),
                            isThreeLine: true,
                            trailing: getListViewActionButton(event)),
                      );
                    },
                  ),
                  // Change location button section
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                            "Want to search for events in another location?"),
                        TextButton(
                          onPressed: () async {
                            // Show dialog to change address
                            await _locationBloc.showChangeLocationDialog(
                                context: context);

                            // Refresh UI
                            setState(() {});
                          },
                          child: const Text('Change location'),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToForm(context, widget.sportId);
        },
        child: const Text('Add'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Combines all async process for loading data into one future
  Future<List<SportEvent>> _loadAllData() async {
    // Handle location access first.
    bool success = await _handleLocationAccess();

    if (!success) {
      return [];
    }

    // Get all sports events
    List<SportEvent> events =
        await widget.firebaseService.getEventsForSport(widget.sportId);

    // Get only the events that are open
    Iterable<SportEvent> filteredEvents = events.where((e) {
      // Filter based on the slots available
      final hasSlots = (e.slotsAvailable ?? 0) > 0;
      bool slotsFilter = showUnavailable ? !hasSlots : hasSlots;

      if (!slotsFilter) {
        return false;
      }

      // We need coordinates to calculate the distance
      if (e.locationLatitude == null || e.locationLongitude == null) {
        return false;
      }

      // Filter events that are close
      double distance = widget.addressesRepository.calculateDistance(
          _locationBloc.currLocationLatitude!,
          _locationBloc.currLocationLongitude!,
          e.locationLatitude!,
          e.locationLongitude!);
      return distance <= _radiusInKM;
    });

    for (SportEvent event in filteredEvents) {
      // Set host name
      event.hostName = await widget.firebaseService
          .getHostName(event.hostUserId as DocumentReference);
    }

    return filteredEvents.toList();
  }

  /// Checks if the user has granted access and ask
  /// for permission if not then ask for the address they want to use.
  Future<bool> _handleLocationAccess() async {
    if (_locationBloc.locationAquired) {
      // We have already saved the location to search for events.
      return true;
    }

    bool access = await widget.addressesRepository.handleLocationPermission();
    if (!access) {
      // Ask user to select the location then.
      await _locationBloc.showLocationUnavailableDialog(
          context: context,
          onCancel: () {
            // Go back
            context.goNamed(RouteNames.sports);
          });
      return true;
    } else {
      // Get the location of the device
      Position? currPosition =
          await widget.addressesRepository.getCurrentPosition();

      if (currPosition != null) {
        Placemark? place = await widget.addressesRepository
            .getAddressFromPosition(currPosition);

        _locationBloc.add(SaveLocationEvent(
            latitude: currPosition.latitude,
            longitude: currPosition.longitude,
            placemark: place));

        setState(() {});
        return true;
      }
    }

    return false;
  }

  /// Gets the action button for the list view of the sports event based on the state of the event.
  Widget getListViewActionButton(SportEvent event) {
    final selfHosting =
        event.hostUserId?.id == _authenticationBloc.sportUser!.uuid;

    if (selfHosting) {
      // Display label for the events the current using is already hosting.
      return const Text("You're hosting");
    }

    if ((event.slotsAvailable ?? 0) <= 0) {
      // Display label to say the game is full
      return const Text(
        "Full",
        style: TextStyle(color: CustomColors.lightError),
      );
    }

    if (event.registeredUsers?.contains(_authenticationBloc.sportUser!.uuid) ??
        false) {
      // Display label that the user already registered to this game.
      return const Text("You're going!");
    }

    // Return a butotn that allows the user to register to the game.
    return FilledButton(
      onPressed: () async {
        await widget.firebaseService.registerForEvent(
          event.id!, // Event ID
          widget.authenticationBloc.sportUser!.uuid, // Logged-in user ID
        );

        // Go to the confirmation page with animation
        GoRouter.of(context).goNamed(
          RouteNames.registrationConfirmation,
          pathParameters: {'sportId': event.sportId!},
        );
      },
      child: Text(
        "Register",
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}
