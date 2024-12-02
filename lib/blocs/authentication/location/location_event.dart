// location_event.dart
import 'package:geocoding/geocoding.dart';

abstract class LocationEvent {}

class RequestCurrentLocationEvent extends LocationEvent {}

class SaveLocationEvent extends LocationEvent {
  final double latitude;
  final double longitude;
  final Placemark? placemark;

  SaveLocationEvent(
      {required this.latitude, required this.longitude, this.placemark});
}
