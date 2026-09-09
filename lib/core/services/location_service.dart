import 'package:geolocator/geolocator.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy = 50.0,
  });
}

class LocationService {
  Future<LocationData> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service is disabled. Please enable it.');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Please enable it from settings.',
      );
    }

    final position = await Geolocator.getCurrentPosition();

    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
