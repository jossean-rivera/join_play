import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:join_play/custom_theme_data.dart';
import 'package:join_play/models/sport_event.dart';
import 'package:join_play/repositories/addresses_repository.dart';
import 'package:join_play/widgets/address_picker.dart';
import '../utilities/firebase_service.dart';
import 'package:join_play/navigation/route_names.dart';
import 'package:join_play/blocs/authentication/bloc/authentication_bloc.dart';

class GameFormPage extends StatefulWidget {
  final String sportId;
  final FirebaseService firebaseService;
  final AuthenticationBloc authenticationBloc;
  final AddressesRepository addressesRepository;

  const GameFormPage(
      {Key? key,
      required this.sportId,
      required this.firebaseService,
      required this.authenticationBloc,
      required this.addressesRepository})
      : super(key: key);

  @override
  _GameFormPageState createState() => _GameFormPageState();
}

class _GameFormPageState extends State<GameFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _gameName;
  String? _location;
  String? _locationTitle;
  int? _numPlayers;
  int? _slotsAvailable;
  Timestamp? _dateTime;

  final _dateTimeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Coordinates of the game address
  double? _addressLat;
  double? _addressLon;

  @override
  void dispose() {
    _dateTimeController.dispose();
    super.dispose();
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  Future<void> _pickDateTime(BuildContext context) async {
    DateTime? datePicked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (datePicked == null) return;

    // Pick the time
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return; // User canceled the picker

    // Combine date and time into a DateTime object
    final pickedDateTime = DateTime(
      datePicked.year,
      datePicked.month,
      datePicked.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _dateTime = Timestamp.fromDate(pickedDateTime); // Convert to Timestamp
      _dateTimeController.text =
          '${pickedDateTime.year}-${_twoDigits(pickedDateTime.month)}-${_twoDigits(pickedDateTime.day)} '
          '${_twoDigits(pickedDateTime.hour)}:${_twoDigits(pickedDateTime.minute)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'New Game',
        style: Theme.of(context).textTheme.headlineMedium,
      )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Game Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a game name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _gameName = value;
                },
              ),
              const SizedBox(height: 16.0),
              AddressPicker(
                  addressController: _addressController,
                  addressesRepository: widget.addressesRepository,
                  onSuccess: (String locationTitle, String location,
                      double latitude, double longitude) {
                    setState(() {
                      _location = location;
                      _locationTitle = locationTitle;
                      _addressLat = latitude;
                      _addressLon = longitude;
                    });
                  }),

              const SizedBox(height: 16.0),

              // Row for side-by-side dropdowns
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration:
                          const InputDecoration(labelText: 'No. of Players'),
                      items: List.generate(20, (index) => index + 1)
                          .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text(value.toString()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _numPlayers = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Select players';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0), // Spacing between dropdowns
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                          labelText: 'Player Slots Available'),
                      items: List.generate(20, (index) => index + 1)
                          .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text(value.toString()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _slotsAvailable = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Select slots';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _dateTimeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Game Date & Time',
                  hintText: 'Select Date and Time',
                ),
                onTap: () => _pickDateTime(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date and time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              Center(
                child: FilledButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      // Get user reference in database for the current logged in user
                      final String userId = widget.authenticationBloc.sportUser!.uuid;

                      final userRef = widget.firebaseService
                          .getUserDocumentReference(
                              widget.authenticationBloc.sportUser!.uuid);
                      // Create event in database
                      await widget.firebaseService.createEvent(SportEvent(
                        sportId: widget.sportId,
                        dateTime: _dateTime,
                        hostUserId: userRef,
                        name: _gameName,
                        slotsAvailable: _slotsAvailable,
                        totalSlots: _numPlayers,
                        location: _location,
                        locationLatitude: _addressLat,
                        locationLongitude: _addressLon,
                        locationTitle: _locationTitle,
                        positionsRequired: [],
                        registeredUsers: [],
                      ));

                      // Process the form data here (e.g., save it to Firebase)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Game added successfully!')),
                      );
                      context.goNamed(RouteNames.myGames);
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
