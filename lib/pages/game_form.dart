import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:join_play/models/sport_event.dart';
import 'package:join_play/repositories/addresses_repository.dart';
import 'package:join_play/widgets/address_picker.dart';
import '../utilities/firebase_service.dart';
import 'package:join_play/navigation/route_names.dart';
import 'package:join_play/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:go_router/go_router.dart';

class GameFormPage extends StatefulWidget {
  final String sportId;
  final FirebaseService firebaseService;
  final AuthenticationBloc authenticationBloc;
  final AddressesRepository addressesRepository;

  const GameFormPage({
    Key? key,
    required this.sportId,
    required this.firebaseService,
    required this.authenticationBloc,
    required this.addressesRepository,
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
  final TextEditingController _addressController = TextEditingController();

  double? _addressLat;
  double? _addressLon;

  @override
  void dispose() {
    _dateTimeController.dispose();
    super.dispose();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> _pickDateTime(BuildContext context) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 300,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.dateAndTime,
            initialDateTime: DateTime.now(),
            onDateTimeChanged: (DateTime value) {
              setState(() {
                _dateTime = Timestamp.fromDate(value);
                _dateTimeController.text =
                    '${value.year}-${_twoDigits(value.month)}-${_twoDigits(value.day)} '
                    '${_twoDigits(value.hour)}:${_twoDigits(value.minute)}';
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('New Game'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CupertinoTextFormFieldRow(
                placeholder: 'Game Name',
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
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 32.0,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _numPlayers = index + 1;
                        });
                      },
                      children: List<Widget>.generate(
                        20,
                        (index) => Text('${index + 1}'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 32.0,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _slotsAvailable = index + 1;
                        });
                      },
                      children: List<Widget>.generate(
                        20,
                        (index) => Text('${index + 1}'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: () => _pickDateTime(context),
                child: AbsorbPointer(
                  child: CupertinoTextFormFieldRow(
                    controller: _dateTimeController,
                    placeholder: 'Game Date & Time',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a date and time';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              Center(
                child: CupertinoButton.filled(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      final userRef = widget.firebaseService
                          .getUserDocumentReference(
                              widget.authenticationBloc.sportUser!.uuid);

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

                      // Use GoRouter to navigate back to My Games page
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
