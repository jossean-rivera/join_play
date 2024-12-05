import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:join_play/models/sport_event.dart';
import 'package:join_play/repositories/addresses_repository.dart';
import 'package:join_play/widgets/address_picker.dart';
import 'package:join_play/navigation/route_names.dart';
import 'package:join_play/blocs/authentication/bloc/authentication_bloc.dart';
import '../utilities/firebase_service.dart';

class GameFormPage extends StatefulWidget {
  final String sportId;
  final FirebaseService firebaseService;
  final AuthenticationBloc authenticationBloc;
  final AddressesRepository addressesRepository;
  final SportEvent? existingEvent; // Optional for edit mode

  const GameFormPage({
    Key? key,
    required this.sportId,
    required this.firebaseService,
    required this.authenticationBloc,
    required this.addressesRepository,
    this.existingEvent, // Existing game for editing
  }) : super(key: key);

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
  final _addressController = TextEditingController();

  double? _addressLat;
  double? _addressLon;

  @override
  void initState() {
    super.initState();
    if (widget.existingEvent != null) {
      _loadExistingData(widget.existingEvent!);
    }
  }

  void _loadExistingData(SportEvent event) {
    setState(() {
      _gameName = event.name;
      _location = event.location;
      _locationTitle = event.locationTitle;
      _addressLat = event.locationLatitude;
      _addressLon = event.locationLongitude;
      _numPlayers = event.totalSlots;
      _slotsAvailable = event.slotsAvailable;
      _dateTime = event.dateTime;

      _dateTimeController.text =
          '${_dateTime!.toDate().year}-${_twoDigits(_dateTime!.toDate().month)}-${_twoDigits(_dateTime!.toDate().day)} '
          '${_twoDigits(_dateTime!.toDate().hour)}:${_twoDigits(_dateTime!.toDate().minute)}';
      _addressController.text = event.locationTitle ?? '';
    });
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> _pickDateTime(BuildContext context) async {
    DateTime? datePicked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (datePicked == null) return;

    TimeOfDay? timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (timePicked == null) return;

    final pickedDateTime = DateTime(
      datePicked.year,
      datePicked.month,
      datePicked.day,
      timePicked.hour,
      timePicked.minute,
    );

    setState(() {
      _dateTime = Timestamp.fromDate(pickedDateTime);
      _dateTimeController.text =
          '${pickedDateTime.year}-${_twoDigits(pickedDateTime.month)}-${_twoDigits(pickedDateTime.day)} '
          '${_twoDigits(pickedDateTime.hour)}:${_twoDigits(pickedDateTime.minute)}';
    });
  }

  @override
  void dispose() {
    _dateTimeController.dispose();
    super.dispose();
  }

  Future<void> _deleteGame() async {
    if (widget.existingEvent != null) {
      final confirmation = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Game'),
          content: const Text('Are you sure you want to delete this game?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmation == true) {
        await widget.firebaseService.deleteEvent(widget.existingEvent!.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game deleted successfully!')),
        );
        context.goNamed(RouteNames.myGames);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingEvent == null ? 'New Game' : 'Edit Game',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Game Name'),
                      initialValue: _gameName,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter a game name'
                          : null,
                      onSaved: (value) => _gameName = value,
                    ),
                    const SizedBox(height: 16.0),
                    AddressPicker(
                      addressController: _addressController,
                      addressesRepository: widget.addressesRepository,
                      onSuccess: (locationTitle, location, lat, lon) {
                        setState(() {
                          _locationTitle = locationTitle;
                          _location = location;
                          _addressLat = lat;
                          _addressLon = lon;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                                labelText: 'No. of Players'),
                            value: _numPlayers,
                            items: List.generate(20, (index) => index + 1)
                                .map((value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(value.toString()),
                                    ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _numPlayers = value),
                            validator: (value) =>
                                value == null ? 'Select players' : null,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                                labelText: 'Slots Available'),
                            value: _slotsAvailable,
                            items: List.generate(20, (index) => index + 1)
                                .map((value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(value.toString()),
                                    ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _slotsAvailable = value),
                            validator: (value) =>
                                value == null ? 'Select slots' : null,
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
                      validator: (value) =>
                          value == null || value.isEmpty
                              ? 'Select date and time'
                              : null,
                    ),
                  ],
                ),
              ),
              if (widget.existingEvent != null)
                TextButton(
                  onPressed: _deleteGame,
                  child: const Text(
                    'Delete Game',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 16.0),
              FilledButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final userRef = widget.firebaseService
                        .getUserDocumentReference(
                            widget.authenticationBloc.sportUser!.uuid);

                    if (widget.existingEvent != null && widget.existingEvent!.id !=null) {
                      // Update existing event
                      await widget.firebaseService.updateEvent(
                        widget.existingEvent!.id!,
                        SportEvent(
                          id: widget.existingEvent!.id,
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
                          positionsRequired:
                              widget.existingEvent!.positionsRequired,
                          registeredUsers: widget.existingEvent!.registeredUsers,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Game updated successfully!')),
                      );
                    } else {
                      // Create new event
                      await widget.firebaseService.createEvent(
                        SportEvent(
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
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Game added successfully!')),
                      );
                    }

                    context.goNamed(RouteNames.myGames);
                  }
                },
                child: Text(widget.existingEvent == null ? 'Submit' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
