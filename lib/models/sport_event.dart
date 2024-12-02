// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SportEvent {
  String? id;
  String? sportId;
  Timestamp? dateTime;
  DocumentReference? hostUserId;
  String? name;
  List<String>? positionsRequired;
  List<String>? registeredUsers;
  int? slotsAvailable;
  int? totalSlots;
  String? location;
  String? locationTitle;
  double? locationLatitude;
  double? locationLongitude;
  String? hostName;

  SportEvent({
    this.id,
    this.sportId,
    this.dateTime,
    this.hostUserId,
    this.name,
    this.positionsRequired,
    this.registeredUsers,
    this.slotsAvailable,
    this.totalSlots,
    this.location,
    this.locationTitle,
    this.locationLatitude,
    this.locationLongitude,
  });

  SportEvent copyWith({
    String? id,
    String? sportId,
    Timestamp? dateTime,
    DocumentReference? hostUserId,
    String? name,
    List<String>? positionsRequired,
    List<String>? registeredUsers,
    int? slotsAvailable,
    int? totalSlots,
    String? location,
    String? locationTitle,
    double? locationLatitude,
    double? locationLongitude,
  }) {
    return SportEvent(
      id: id ?? this.id,
      sportId: sportId ?? this.sportId,
      dateTime: dateTime ?? this.dateTime,
      hostUserId: hostUserId ?? this.hostUserId,
      name: name ?? this.name,
      positionsRequired: positionsRequired ?? this.positionsRequired,
      registeredUsers: registeredUsers ?? this.registeredUsers,
      slotsAvailable: slotsAvailable ?? this.slotsAvailable,
      totalSlots: totalSlots ?? this.totalSlots,
      location: location ?? this.location,
      locationTitle: locationTitle ?? this.locationTitle,
      locationLatitude: locationLatitude ?? this.locationLatitude,
      locationLongitude: locationLongitude ?? this.locationLongitude,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sportId': sportId,
      'dateTime': dateTime,
      'hostUserId': hostUserId,
      'name': name,
      'positionsRequired': positionsRequired,
      'registeredUsers': registeredUsers,
      'slotsAvailable': slotsAvailable,
      'totalSlots': totalSlots,
      'location': location,
      'locationTitle': locationTitle,
      'locationLatitude': locationLatitude,
      'locationLongitude': locationLongitude,
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
      name: map['name'] != null ? map['name'] as String : null,
      positionsRequired: map['positionsRequired'] != null ? List<String>.from(map['positionsRequired'] as List) : null,
      registeredUsers: map['registeredUsers'] != null ? List<String>.from(map['registeredUsers'] as List) : null,
      slotsAvailable: map['slotsAvailable'] != null ? map['slotsAvailable'] as int : null,
      totalSlots: map['totalSlots'] != null ? map['totalSlots'] as int : null,
      location: map['location'] != null ? map['location'] as String : null,
      locationTitle: map['locationTitle'] != null ? map['locationTitle'] as String : null,
      locationLatitude: map['locationLatitude'] != null ? map['locationLatitude'] as double : null,
      locationLongitude: map['locationLongitude'] != null ? map['locationLongitude'] as double : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SportEvent.fromJson(String source) => SportEvent.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SportEvent(id: $id, sportId: $sportId, dateTime: $dateTime, hostUserId: $hostUserId, name: $name, positionsRequired: $positionsRequired, registeredUsers: $registeredUsers, slotsAvailable: $slotsAvailable, totalSlots: $totalSlots, location: $location, locationTitle: $locationTitle, locationLatitude: $locationLatitude, locationLongitude: $locationLongitude)';
  }

  @override
  bool operator ==(covariant SportEvent other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.sportId == sportId &&
      other.dateTime == dateTime &&
      other.hostUserId == hostUserId &&
      other.name == name &&
      listEquals(other.positionsRequired, positionsRequired) &&
      listEquals(other.registeredUsers, registeredUsers) &&
      other.slotsAvailable == slotsAvailable &&
      other.totalSlots == totalSlots &&
      other.location == location &&
      other.locationTitle == locationTitle &&
      other.locationLatitude == locationLatitude &&
      other.locationLongitude == locationLongitude;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      sportId.hashCode ^
      dateTime.hashCode ^
      hostUserId.hashCode ^
      name.hashCode ^
      positionsRequired.hashCode ^
      registeredUsers.hashCode ^
      slotsAvailable.hashCode ^
      totalSlots.hashCode ^
      location.hashCode ^
      locationTitle.hashCode ^
      locationLatitude.hashCode ^
      locationLongitude.hashCode;
  }
}
