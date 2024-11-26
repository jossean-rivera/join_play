// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';


class SportUser {
  String uuid;
  String name;
  String email;
  SportUser({
    required this.uuid,
    required this.name,
    required this.email,
  });

  SportUser copyWith({
    String? uuid,
    String? name,
    String? email,
  }) {
    return SportUser(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uuid': uuid,
      'name': name,
      'email': email,
    };
  }

  factory SportUser.fromMap(Map<String, dynamic> map) {
    return SportUser(
      uuid: map['uuid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SportUser.fromJson(String source) => SportUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'SportUser(uuid: $uuid, name: $name, email: $email)';

  @override
  bool operator ==(covariant SportUser other) {
    if (identical(this, other)) return true;
  
    return 
      other.uuid == uuid &&
      other.name == name &&
      other.email == email;
  }

  @override
  int get hashCode => uuid.hashCode ^ name.hashCode ^ email.hashCode;
}
