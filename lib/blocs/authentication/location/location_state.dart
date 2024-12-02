// location_state.dart
abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final double latitude;
  final double longitude;
  final String address;
  final String addressName;

  LocationLoaded({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.addressName,
  });
}

class LocationError extends LocationState {
  final String errorMessage;

  LocationError({required this.errorMessage});
}
