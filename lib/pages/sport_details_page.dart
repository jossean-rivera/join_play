import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:join_play/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:join_play/blocs/authentication/location/location_bloc.dart';
import 'package:join_play/models/sport_event.dart';
import 'package:join_play/navigation/route_names.dart';
import 'package:join_play/repositories/addresses_repository.dart';
import '../blocs/authentication/location/location_event.dart';
import '../utilities/firebase_service.dart';

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.sportId,
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
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(event.name ?? ''),
                          subtitle: Text(
                            "Location: ${event.location}\n"
                            "Time: ${event.dateTime?.toDate()}\n"
                            "Slots Available: ${event.slotsAvailable}\n"
                            "Host: ${event.hostName}",
                          ),
                          isThreeLine: true,
                          trailing: (event.slotsAvailable ?? 0) > 0
                              ? FilledButton(
                                  onPressed: () async {
                                    await widget.firebaseService
                                        .registerForEvent(
                                      event.id!, // Event ID
                                      widget.authenticationBloc.sportUser!
                                          .uuid, // Logged-in user ID
                                    );

                                    // Go to the confirmation page with animation
                                    GoRouter.of(context).goNamed(
                                      RouteNames.registrationConfirmation,
                                      pathParameters: {
                                        'sportId': event.sportId!
                                      },
                                    );
                                  },
                                  child: Text(
                                    "Register",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary),
                                  ),
                                )
                              : Text(
                                  "Full",
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error),
                                ),
                        ),
                      );
                    },
                  ),
                  // Change location button section
                  const SizedBox(height: 16),
                  const Text("Want to search for events in another location?"),
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
}
