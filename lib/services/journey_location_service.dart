import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// Streams foreground location updates after checking the device settings and
/// requesting permission when needed. This service does not request background
/// location access.
class JourneyLocationService {
  const JourneyLocationService();

  Stream<Position> watch() async* {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception(
        'Location services are off. Turn on device location to share your position.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception(
        'Location permission was not granted. Allow location access to continue.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is blocked. Enable it in your device settings to continue.',
      );
    }

    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      throw Exception(
        'Location permission could not be determined. Please retry.',
      );
    }
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    );
  }
}

/// Confirms checkpoint arrival only after three distinct, recent, accurate
/// readings inside the arrival radius.
class CheckpointArrivalDetector {
  CheckpointArrivalDetector({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  static const double arrivalRadiusMeters = 250;
  static const double maximumAccuracyMeters = 100;
  static const Duration maximumReadingAge = Duration(seconds: 30);

  DateTime? _lastTimestamp;
  int _consecutiveReadings = 0;

  bool add(Position position, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final age = currentTime.difference(position.timestamp);
    if (age.isNegative || age > maximumReadingAge) {
      _consecutiveReadings = 0;
      return false;
    }

    final previousTimestamp = _lastTimestamp;
    if (previousTimestamp != null &&
        !position.timestamp.isAfter(previousTimestamp)) {
      return false;
    }

    if (previousTimestamp != null &&
        position.timestamp.difference(previousTimestamp) > maximumReadingAge) {
      _consecutiveReadings = 0;
    }
    _lastTimestamp = position.timestamp;

    final hasValidCoordinates =
        position.latitude.isFinite &&
        position.longitude.isFinite &&
        position.latitude >= -90 &&
        position.latitude <= 90 &&
        position.longitude >= -180 &&
        position.longitude <= 180;
    if (!hasValidCoordinates ||
        !position.accuracy.isFinite ||
        position.accuracy < 0 ||
        position.accuracy > maximumAccuracyMeters) {
      _consecutiveReadings = 0;
      return false;
    }

    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      latitude,
      longitude,
    );
    if (!distance.isFinite || distance > arrivalRadiusMeters) {
      _consecutiveReadings = 0;
      return false;
    }

    _consecutiveReadings++;
    return _consecutiveReadings >= 3;
  }
}
