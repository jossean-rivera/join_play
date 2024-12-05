// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class SportUser {
  String uuid;
  String name;
  String email;
  String? profilePicture; // New optional field for profile picture URL

  SportUser({
    required this.uuid,
    required this.name,
    required this.email,
    this.profilePicture, // Add profilePicture as an optional parameter
  });

  SportUser copyWith({
    String? uuid,
    String? name,
    String? email,
    String? profilePicture, // Add profilePicture to copyWith
  }) {
    return SportUser(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'email': email,
      if (profilePicture != null) 'profilePicture': profilePicture, // Include profilePicture if not null
    };
  }

  factory SportUser.fromMap(Map<String, dynamic> map) {
    return SportUser(
      uuid: map['uuid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      profilePicture: map['profilePicture'] as String?, // Handle profilePicture
    );
  }

  String toJson() => json.encode(toMap());

  factory SportUser.fromJson(String source) =>
      SportUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'SportUser(uuid: $uuid, name: $name, email: $email, profilePicture: $profilePicture)';

  @override
  bool operator ==(covariant SportUser other) {
    if (identical(this, other)) return true;

    return other.uuid == uuid &&
        other.name == name &&
        other.email == email &&
        other.profilePicture == profilePicture;
  }

  @override
  int get hashCode =>
      uuid.hashCode ^ name.hashCode ^ email.hashCode ^ profilePicture.hashCode;
}
