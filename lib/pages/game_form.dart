import 'package:flutter/material.dart';

class GameFormPage extends StatefulWidget {
  final String sportId;

  const GameFormPage({Key? key, required this.sportId}) : super(key: key);

  @override
  _GameFormPageState createState() => _GameFormPageState();
}

class _GameFormPageState extends State<GameFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _gameName;
  String? _location;
  int? _numPlayers;
  int? _slotsAvailable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Game'),
      ),
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
              TextFormField(
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
                onSaved: (value) {
                  _location = value;
                },
              ),
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
              const SizedBox(height: 32.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Process the form data here (e.g., save it to Firebase)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Game added successfully!')),
                      );
                      Navigator.pop(context);
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
