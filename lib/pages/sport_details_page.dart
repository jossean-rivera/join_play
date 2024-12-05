import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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

  const SportDetailsPage({
    super.key,
    required this.sportId,
    required this.firebaseService,
    required this.authenticationBloc,
    required this.addressesRepository,
  });

  @override
  State<SportDetailsPage> createState() => _SportDetailsPageState();
}

class _SportDetailsPageState extends State<SportDetailsPage> {
  bool showUnavailable = false;

  late LocationBloc _locationBloc;

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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.sportId),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoSwitch(
              value: showUnavailable,
              onChanged: (value) {
                setState(() {
                  showUnavailable = value;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                showUnavailable ? "Unavailable" : "Available",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      child: Stack(
        children: [
          FutureBuilder<List<SportEvent>>(
            future: _loadAllData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                if (_locationBloc.locationAquired &&
                    _locationBloc.currLocationName.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("No events close to ${_locationBloc.currLocationName}"),
                        const SizedBox(height: 8),
                        CupertinoButton(
                          onPressed: () async {
                            await _locationBloc.showChangeLocationDialog(
                                context: context);
                            setState(() {});
                          },
                          child: const Text('Change location'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: Text("No events available for this sport."));
              } else {
                final events = snapshot.data!;

                return CupertinoScrollbar(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return Container(
                              margin: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemBackground,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: CupertinoColors.systemGrey.withOpacity(0.5),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                              child: CupertinoListTile(
                                title: Text(event.name ?? ''),
                                subtitle: Text(
                                  "Location: ${event.location}\n"
                                  "Time: ${event.dateTime?.toDate()}\n"
                                  "Slots Available: ${event.slotsAvailable}\n"
                                  "Host: ${event.hostName}",
                                ),
                                trailing: (event.slotsAvailable ?? 0) > 0
                                    ? CupertinoButton.filled(
                                        onPressed: () async {
                                          await widget.firebaseService
                                              .registerForEvent(
                                            event.id!,
                                            widget.authenticationBloc.sportUser!
                                                .uuid,
                                          );
                                          context.goNamed(
                                            RouteNames.registrationConfirmation,
                                            pathParameters: {'sportId': event.sportId!},
                                          );
                                        },
                                        child: const Text("Register"),
                                      )
                                    : const Text(
                                        "Full",
                                        style: TextStyle(color: CupertinoColors.destructiveRed),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text("Want to search for events in another location?"),
                        CupertinoButton(
                          onPressed: () async {
                            await _locationBloc.showChangeLocationDialog(
                                context: context);
                            setState(() {});
                          },
                          child: const Text('Change location'),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
          // Floating action button workaround for CupertinoPageScaffold
          Positioned(
            bottom: 16,
            right: 16,
            child: CupertinoButton.filled(
              onPressed: () {
                _navigateToForm(context, widget.sportId);
              },
              child: const Text('Add'),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<SportEvent>> _loadAllData() async {
    bool success = await _handleLocationAccess();

    if (!success) {
      return [];
    }

    List<SportEvent> events =
        await widget.firebaseService.getEventsForSport(widget.sportId);

    Iterable<SportEvent> filteredEvents = events.where((e) {
      final hasSlots = (e.slotsAvailable ?? 0) > 0;
      bool slotsFilter = showUnavailable ? !hasSlots : hasSlots;

      if (!slotsFilter) {
        return false;
      }

      if (e.locationLatitude == null || e.locationLongitude == null) {
        return false;
      }

      double distance = widget.addressesRepository.calculateDistance(
        _locationBloc.currLocationLatitude!,
        _locationBloc.currLocationLongitude!,
        e.locationLatitude!,
        e.locationLongitude!,
      );
      return distance <= _radiusInKM;
    });

    for (SportEvent event in filteredEvents) {
      event.hostName = await widget.firebaseService
          .getHostName(event.hostUserId as DocumentReference);
    }

    return filteredEvents.toList();
  }

  Future<bool> _handleLocationAccess() async {
    if (_locationBloc.locationAquired) {
      return true;
    }

    bool access = await widget.addressesRepository.handleLocationPermission();
    if (!access) {
      await _locationBloc.showLocationUnavailableDialog(
        context: context,
        onCancel: () {
          context.goNamed(RouteNames.sports);
        },
      );
      return true;
    } else {
      Position? currPosition =
          await widget.addressesRepository.getCurrentPosition();

      if (currPosition != null) {
        Placemark? place = await widget.addressesRepository
            .getAddressFromPosition(currPosition);

        _locationBloc.add(SaveLocationEvent(
          latitude: currPosition.latitude,
          longitude: currPosition.longitude,
          placemark: place,
        ));

        setState(() {});
        return true;
      }
    }

    return false;
  }
}
