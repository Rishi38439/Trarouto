import 'package:flutter_test/flutter_test.dart';
import 'package:aeronova_travel/models/travel_models.dart';
import 'package:aeronova_travel/services/route_recovery_engine.dart';

void main() {
  RoutePossibility route(Map<String, dynamic> result, String id) =>
      (result['routes'] as List<RoutePossibility>).firstWhere((item) => item.id == id);

  Map<String, dynamic> recalcA(int delay) => RouteRecoveryEngine.recalculate(
        activeCheckpointId: 'cp-a', delayMinutes: delay);
  Map<String, dynamic> recalcB(String arrival, {RoutePossibility? completedRoute}) =>
      RouteRecoveryEngine.recalculate(
        activeCheckpointId: 'cp-b', delayMinutes: 0,
        customArrivalTimeStr: arrival, completedRoute: completedRoute);

  group('route recovery', () {
    test('accepts exact transfer cutoff at A', () {
      final result = recalcA(15); // 12:00 arrival + 30m = 12:30 departure.
      expect(result['hasMissedConnection'], isFalse);
      expect(result['activeRouteId'], 'route-opt-1');
    });

    test('promotes the earliest feasible A alternative at +45m and +90m', () {
      final plus45 = recalcA(45);
      expect(plus45['activeRouteId'], 'route-opt-2');
      expect(route(plus45, 'route-opt-1').isFeasible, isFalse);
      expect(route(plus45, 'route-opt-1').legs[1].bookingStatus, 'missed');
      final promoted = route(plus45, 'route-opt-2');
      expect(promoted.legs[0].arrivalTime, '12:30');
      expect(promoted.legs[0].durationMinutes, 270);
      expect(promoted.totalWaitingMinutes, 90); // 45m at A and 45m at B.
      expect(promoted.totalDurationMinutes, 780);
      expect(promoted.totalCost, 2950);

      final plus90 = recalcA(90);
      expect(plus90['activeRouteId'], 'route-opt-3');
      expect(route(plus90, 'route-opt-2').isFeasible, isFalse);
    });

    test('returns no active route after every A connection is missed', () {
      final result = recalcA(140);
      expect(result['hasMissedConnection'], isTrue);
      expect(result['activeRouteId'], isNull);
      expect((result['routes'] as List<RoutePossibility>).every((r) => !r.isFeasible), isTrue);
    });

    test('recovers at B +50m and retains completed shared prefix', () {
      final result = recalcB('16:05');
      expect(result['activeRouteId'], 'route-opt-2');
      expect(result['hasMissedConnection'], isTrue);
      final routes = result['routes'] as List<RoutePossibility>;
      for (final item in routes) {
        expect(item.legs[0].from, 'Home');
        expect(item.legs[0].to, 'Checkpoint A');
        expect(item.legs[1].from, 'Checkpoint A');
        expect(item.legs[1].to, 'Checkpoint B');
        expect(item.legs[0].departureTime, '08:00');
        expect(item.legs[1].departureTime, '12:30');
      }
      final selected = route(result, 'route-opt-2');
      expect(selected.totalWaitingMinutes, 85); // 45m at A and 40m at B.
      expect(selected.totalDurationMinutes, 780); // 08:00 to 21:00.
      expect(selected.totalCost, 2950);
      expect((result['checkpoints'] as List<CheckpointStatus>)[2].actualArrival, '16:05');
    });

    test('returns no active route after the B cutoff', () {
      final result = recalcB('17:21'); // ready at 17:46, after the last 17:45 departure.
      expect(result['hasMissedConnection'], isTrue);
      expect(result['activeRouteId'], isNull);
    });

    test('carries the selected A recovery prefix into B recalculation', () {
      final resultA = recalcA(45);
      final selected = route(resultA, 'route-opt-2');
      final resultB = recalcB('16:05', completedRoute: selected);
      final recovered = route(resultB, 'route-opt-2');

      expect(recovered.legs[0].arrivalTime, '12:30');
      expect(recovered.legs[1].departureTime, '13:15');
      expect(recovered.legs[1].arrivalTime, '16:05');
      expect(recovered.legs[1].durationMinutes, 170);
      expect(recovered.totalWaitingMinutes, 85); // 45m at A and 40m at B.
      expect(recovered.totalDurationMinutes, 780);
      expect(recovered.totalCost, 2950);
    });

    test('validates custom time in HH:mm range', () {
      expect(() => timeToMinutes('24:00'), throwsFormatException);
      expect(() => timeToMinutes('8:30'), throwsFormatException);
      expect(timeToMinutes('08:30'), 510);
    });
  });
}
