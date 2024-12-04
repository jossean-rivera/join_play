import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../blocs/authentication/bloc/authentication_bloc.dart';
import '../utilities/firebase_service.dart';

class ProfilePage extends StatefulWidget {
  final FirebaseService firebaseService;
  final AuthenticationBloc authenticationBloc;

  const ProfilePage({
    super.key,
    required this.firebaseService,
    required this.authenticationBloc,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = false;
  String? profilePictureUrl;

  // Load the profile picture and user details
  Future<void> _loadUserProfile() async {
    final userId = widget.authenticationBloc.sportUser?.uuid ?? '';
    if (userId.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final url = await widget.firebaseService.getProfilePicture(userId);
      setState(() {
        profilePictureUrl = url;
      });
    } catch (e) {
      debugPrint('Error loading profile picture: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Upload a new profile picture
  Future<void> _pickAndUploadImage() async {
    final userId = widget.authenticationBloc.sportUser?.uuid ?? '';
    if (userId.isEmpty) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return; // No file was selected
    }

    setState(() {
      isLoading = true;
    });

    try {
      await widget.firebaseService.uploadProfilePicture(userId, pickedFile.path);
      await _loadUserProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated!")),
      );
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile picture.")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Delete the profile picture
  Future<void> _deleteProfilePicture() async {
    final userId = widget.authenticationBloc.sportUser?.uuid ?? '';
    if (userId.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      await widget.firebaseService.deleteProfilePicture(userId);
      setState(() {
        profilePictureUrl = null; // Remove the picture from the UI
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture deleted!")),
      );
    } catch (e) {
      debugPrint('Error deleting profile picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete profile picture.")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Edit profile details
  Future<void> _editProfileDetails() async {
    final user = widget.authenticationBloc.sportUser;
    if (user == null) return;

    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                final newEmail = emailController.text.trim();
                if (newName.isEmpty || newEmail.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Fields cannot be empty!")),
                  );
                  return;
                }
                try {
                  await widget.firebaseService.updateUserProfile(
                    user.uuid,
                    newName,
                    newEmail,
                  );
                  widget.authenticationBloc.add(AuthenticationUserChangedEvent(
                    FirebaseAuth.instance.currentUser,
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile updated!")),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  debugPrint('Error updating profile: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to update profile.")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Delete account
  Future<void> _deleteAccount() async {
    final userId = widget.authenticationBloc.sportUser?.uuid ?? '';
    if (userId.isEmpty) return;

    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
              "Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await widget.firebaseService.deleteAccount(userId);
        widget.authenticationBloc.add(AuthenticationLogoutEvent());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account deleted successfully.")),
        );
      } catch (e) {
        debugPrint('Error deleting account: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete account.")),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authenticationBloc.sportUser;
    final userName = user?.name ?? 'Unknown';
    final userEmail = user?.email ?? 'Unknown';

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Profile Picture Section
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: profilePictureUrl != null
                          ? NetworkImage(profilePictureUrl!)
                          : null,
                      child: profilePictureUrl == null
                          ? Text(
                              userName.isNotEmpty ? userName[0] : '',
                              style: Theme.of(context).textTheme.headlineMedium,
                            )
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.add_a_photo),
                                  title: const Text('Upload Picture'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickAndUploadImage();
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete),
                                  title: const Text('Delete Picture'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _deleteProfilePicture();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // User Details Section
                Text(userName, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 5),
                Text(userEmail, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
                // Edit Profile Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FilledButton(
                    onPressed: _editProfileDetails,
                    child: const Text("Edit Profile"),
                  ),
                ),
                // Delete Account Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FilledButton(
                    onPressed: _deleteAccount,
                    child: const Text("Delete Account"),
                  ),
                ),
                // Logout Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FilledButton(
                    onPressed: () {
                      widget.authenticationBloc.add(AuthenticationLogoutEvent());
                    },
                    child: const Text("Log Out"),
                  ),
                ),
              ],
            ),
          );
  }
}
