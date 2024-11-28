// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SportEvent {
  String? id;
  String? sportId;
  Timestamp? dateTime;
  DocumentReference? hostUserId; // Changed to DocumentReference
  String? location;
  String? name;
  List<String>? positionsRequired;
  List<String>? registeredUsers;
  int? slotsAvailable;
  int? totalSlots;

  SportEvent({
    this.id,
    this.sportId,
    this.dateTime,
    this.hostUserId,
    this.location,
    this.name,
    this.positionsRequired,
    this.registeredUsers,
    this.slotsAvailable,
    this.totalSlots,
  });

  SportEvent copyWith({
    String? id,
    String? sportId,
    Timestamp? dateTime,
    DocumentReference? hostUserId, // Changed to DocumentReference
    String? location,
    String? name,
    List<String>? positionsRequired,
    List<String>? registeredUsers,
    int? slotsAvailable,
    int? totalSlots,
  }) {
    return SportEvent(
      id: id ?? this.id,
      sportId: sportId ?? this.sportId,
      dateTime: dateTime ?? this.dateTime,
      hostUserId: hostUserId ?? this.hostUserId,
      location: location ?? this.location,
      name: name ?? this.name,
      positionsRequired: positionsRequired ?? this.positionsRequired,
      registeredUsers: registeredUsers ?? this.registeredUsers,
      slotsAvailable: slotsAvailable ?? this.slotsAvailable,
      totalSlots: totalSlots ?? this.totalSlots,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sportId': sportId,
      'dateTime': dateTime,
      'hostUserId': hostUserId, // DocumentReference stored directly
      'location': location,
      'name': name,
      'positionsRequired': positionsRequired,
      'registeredUsers': registeredUsers,
      'slotsAvailable': slotsAvailable,
      'totalSlots': totalSlots,
    };
  }

  factory SportEvent.fromMap(Map<String, dynamic> map) {
    return SportEvent(
      id: map['id'] != null ? map['id'] as String : null,
      sportId: map['sportId'] != null ? map['sportId'] as String : null,
      dateTime: map['dateTime'] != null
          ? (map['dateTime'] is Timestamp
              ? map['dateTime'] as Timestamp
              : Timestamp.fromMillisecondsSinceEpoch(map['dateTime'] as int))
          : null,
      hostUserId: map['hostUserId'] != null
          ? (map['hostUserId'] as DocumentReference)
          : null, // Directly assigned if DocumentReference
      location: map['location'] != null ? map['location'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      positionsRequired: map['positionsRequired'] != null
          ? List<String>.from(map['positionsRequired'] as List)
          : null,
      registeredUsers: map['registeredUsers'] != null
          ? List<String>.from(map['registeredUsers'] as List)
          : null,
      slotsAvailable:
          map['slotsAvailable'] != null ? map['slotsAvailable'] as int : null,
      totalSlots: map['totalSlots'] != null ? map['totalSlots'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SportEvent.fromJson(String source) =>
      SportEvent.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SportEvent(id: $id, sportId: $sportId, dateTime: $dateTime, hostUserId: $hostUserId, location: $location, name: $name, positionsRequired: $positionsRequired, registeredUsers: $registeredUsers, slotsAvailable: $slotsAvailable, totalSlots: $totalSlots)';
  }

  @override
  bool operator ==(covariant SportEvent other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.sportId == sportId &&
        other.dateTime == dateTime &&
        other.hostUserId == hostUserId &&
        other.location == location &&
        other.name == name &&
        listEquals(other.positionsRequired, positionsRequired) &&
        listEquals(other.registeredUsers, registeredUsers) &&
        other.slotsAvailable == slotsAvailable &&
        other.totalSlots == totalSlots;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        sportId.hashCode ^
        dateTime.hashCode ^
        hostUserId.hashCode ^
        location.hashCode ^
        name.hashCode ^
        positionsRequired.hashCode ^
        registeredUsers.hashCode ^
        slotsAvailable.hashCode ^
        totalSlots.hashCode;
  }
}
