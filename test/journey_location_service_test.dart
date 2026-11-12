import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:aeronova_travel/services/journey_location_service.dart';

Position fix(
  DateTime timestamp, {
  double accuracy = 20,
  double latitude = 26.9196,
}) => Position(
  latitude: latitude,
  longitude: 75.7878,
  timestamp: timestamp,
  accuracy: accuracy,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

void main() {
  test('arrival needs three distinct, recent, accurate readings', () {
    final detector = CheckpointArrivalDetector(
      latitude: 26.9196,
      longitude: 75.7878,
    );
    final now = DateTime.now();
    final first = fix(now.subtract(const Duration(seconds: 3)));
    expect(detector.add(first), isFalse);
    expect(detector.add(first), isFalse);
    expect(
      detector.add(fix(now.subtract(const Duration(seconds: 2)))),
      isFalse,
    );
    expect(detector.add(fix(now.subtract(const Duration(seconds: 1)))), isTrue);
  });

  test('poor accuracy and stale readings cannot confirm arrival', () {
    final detector = CheckpointArrivalDetector(
      latitude: 26.9196,
      longitude: 75.7878,
    );
    final now = DateTime.now();
    for (var i = 3; i > 0; i--) {
      expect(detector.add(fix(now.subtract(Duration(minutes: i)))), isFalse);
      expect(
        detector.add(fix(now.subtract(Duration(seconds: i)), accuracy: 500)),
        isFalse,
      );
    }
  });

  test('leaving the checkpoint resets arrival evidence', () {
    final detector = CheckpointArrivalDetector(
      latitude: 26.9196,
      longitude: 75.7878,
    );
    final now = DateTime.now();
    expect(
      detector.add(fix(now.subtract(const Duration(seconds: 5)))),
      isFalse,
    );
    expect(
      detector.add(fix(now.subtract(const Duration(seconds: 4)))),
      isFalse,
    );
    expect(
      detector.add(fix(now.subtract(const Duration(seconds: 3)), latitude: 28)),
      isFalse,
    );
    expect(
      detector.add(fix(now.subtract(const Duration(seconds: 2)))),
      isFalse,
    );
  });
}
