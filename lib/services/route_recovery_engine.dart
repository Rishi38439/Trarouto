import '../models/travel_models.dart';

int timeToMinutes(String timeStr) {
  final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(timeStr);
  if (match == null) throw FormatException('Expected time in HH:mm format.', timeStr);
  final hours = int.parse(match.group(1)!);
  final minutes = int.parse(match.group(2)!);
  if (hours > 23 || minutes > 59) {
    throw FormatException('Time must be between 00:00 and 23:59.', timeStr);
  }
  return hours * 60 + minutes;
}

String minutesToTime(int totalMinutes) {
  final normMinutes = (totalMinutes + 24 * 60) % (24 * 60);
  return '${(normMinutes ~/ 60).toString().padLeft(2, '0')}:${(normMinutes % 60).toString().padLeft(2, '0')}';
}

String formatDuration(int minutes) {
  final hrs = minutes ~/ 60;
  final mins = minutes % 60;
  if (hrs == 0) return '${mins}m';
  return '${hrs}h ${mins > 0 ? '${mins}m' : ''}'.trim();
}

class RouteRecoveryEngine {
  static List<CheckpointStatus> getInitialCheckpoints() => [
        CheckpointStatus(
          id: 'cp-home', name: 'Home (Origin)', code: 'HOME', sequence: 0,
          scheduledArrival: '07:30', scheduledDeparture: '08:00', actualArrival: '07:30',
          minTransferTimeMinutes: 10, status: 'departed',
          notes: 'Departed on schedule via Vande Bharat Express.',
        ),
        CheckpointStatus(
          id: 'cp-a', name: 'Checkpoint A (Jaipur Jn)', code: 'JP-JN', sequence: 1,
          scheduledArrival: '11:45', scheduledDeparture: '12:30', minTransferTimeMinutes: 30,
          status: 'upcoming', notes: 'Primary interchange between Northern & Western transit lines.',
        ),
        CheckpointStatus(
          id: 'cp-b', name: 'Checkpoint B (Ajmer Terminal)', code: 'AII', sequence: 2,
          scheduledArrival: '15:15', scheduledDeparture: '16:00', minTransferTimeMinutes: 25,
          status: 'not-reached', notes: 'Secondary interchange for Marwar express line.',
        ),
        CheckpointStatus(
          id: 'cp-jodhpur', name: 'Jodhpur (Final Destination)', code: 'JU', sequence: 3,
          scheduledArrival: '20:15', scheduledDeparture: '20:15', minTransferTimeMinutes: 0,
          status: 'not-reached', notes: 'Destination: Blue City heritage terminal.',
        ),
      ];

  static List<RoutePossibility> getInitialRoutes() {
    const aDepartures = ['12:30', '13:15', '14:15'];
    const bArrivals = ['15:15', '16:00', '17:00'];
    const bDepartures = ['16:00', '16:45', '17:45'];
    const jArrivals = ['20:15', '21:00', '22:00'];
    const finalCosts = [1180, 1280, 1430];
    return List.generate(3, (i) {
      final routeNo = i + 1;
      final aToB = JourneyLeg(id: 'leg-$routeNo-a-b', from: 'Checkpoint A', to: 'Checkpoint B', mode: 'train',
        provider: 'Intercity Superfast', serviceNumber: 'SF-12988-$routeNo', departureTime: aDepartures[i],
        arrivalTime: bArrivals[i], durationMinutes: timeToMinutes(bArrivals[i]) - timeToMinutes(aDepartures[i]),
        cost: 720, bookingStatus: 'confirmed', bufferMinutesAfter: 45);
      final finalLeg = _finalLeg('leg-$routeNo-b-j', bDepartures[i], jArrivals[i], finalCosts[i]);
      final legs = [_homeToA(), aToB, finalLeg];
      return RoutePossibility(
        id: 'route-opt-$routeNo', name: 'Option $routeNo: ${['Primary Corridor', 'Later Intercity', 'Evening Recovery'][i]}',
        pathDescription: 'Home → Checkpoint A (Jaipur) → Checkpoint B (Ajmer) → Jodhpur',
        checkpoints: ['HOME', 'JP-JN', 'AII', 'JU'], legs: legs,
        departureTime: '08:00', estimatedArrivalTime: finalLeg.arrivalTime,
        totalDurationMinutes: timeToMinutes(finalLeg.arrivalTime) - 480,
        totalWaitingMinutes: timeToMinutes(legs[1].departureTime) - timeToMinutes(legs[0].arrivalTime) +
          timeToMinutes(finalLeg.departureTime) - timeToMinutes(legs[1].arrivalTime),
        totalCost: legs.fold(0, (sum, leg) => sum + leg.cost), isPrimary: i == 0,
        isFeasible: true, feasibilityRisk: 'none',
        feasibilityReason: 'Scheduled route with a shared Home → A → B journey.',
        recommendedAction: i == 0 ? 'Proceed with confirmed reservations.' : 'Available recovery option.',
      );
    });
  }

  static JourneyLeg _homeToA() => JourneyLeg(
    id: 'leg-home-a', from: 'Home', to: 'Checkpoint A', mode: 'train',
    provider: 'Vande Bharat Exp (20977)', serviceNumber: 'VB-20977', departureTime: '08:00',
    arrivalTime: '11:45', durationMinutes: 225, cost: 950, bookingStatus: 'confirmed', bufferMinutesAfter: 45);

  static JourneyLeg _finalLeg(String id, String departure, String arrival, int cost) => JourneyLeg(
    id: id, from: 'Checkpoint B', to: 'Jodhpur', mode: 'train',
    provider: 'Marwar Express', serviceNumber: 'ME-${id.substring(4, 5)}',
    departureTime: departure, arrivalTime: arrival,
    durationMinutes: timeToMinutes(arrival) - timeToMinutes(departure), cost: cost,
    bookingStatus: 'confirmed', bufferMinutesAfter: 0,
  );

  static Map<String, dynamic> recalculate({
    required String activeCheckpointId,
    required int delayMinutes,
    String? customArrivalTimeStr,
    RoutePossibility? completedRoute,
  }) {
    final checkpoints = getInitialCheckpoints();
    var routes = getInitialRoutes();
    final target = checkpoints.firstWhere((c) => c.id == activeCheckpointId);
    final scheduled = timeToMinutes(target.scheduledArrival);
    final actual = customArrivalTimeStr != null && customArrivalTimeStr.isNotEmpty
        ? timeToMinutes(customArrivalTimeStr) : scheduled + delayMinutes;
    delayMinutes = actual - scheduled;
    target.actualArrival = minutesToTime(actual);
    target.delayMinutes = delayMinutes;
    target.status = delayMinutes > 15 ? 'delayed' : 'on-time';

    var missed = false;
    var alert = '';
    var severity = 'success';
    final transfer = target.minTransferTimeMinutes;
    final ready = actual + transfer;
    if (activeCheckpointId == 'cp-b') {
      final completedLegs = completedRoute?.legs ?? getInitialRoutes().first.legs;
      final homeToA = completedLegs[0].clone();
      final plannedAToB = completedLegs[1];
      final actualAToB = JourneyLeg(
        id: plannedAToB.id, from: plannedAToB.from, to: plannedAToB.to,
        mode: plannedAToB.mode, provider: plannedAToB.provider,
        serviceNumber: plannedAToB.serviceNumber,
        departureTime: plannedAToB.departureTime, arrivalTime: target.actualArrival!,
        durationMinutes: (actual - timeToMinutes(plannedAToB.departureTime)).clamp(0, 24 * 60).toInt(),
        cost: plannedAToB.cost, bookingStatus: plannedAToB.bookingStatus,
        bufferMinutesAfter: plannedAToB.bufferMinutesAfter,
      );
      final templateLegs = [homeToA, actualAToB];
      routes = List.generate(3, (i) {
        final finalLeg = _finalLeg('leg-${i + 1}-b-j', ['16:00', '16:45', '17:45'][i],
          ['20:15', '21:00', '22:00'][i], [1180, 1280, 1430][i]);
        final canConnect = actual + transfer <= timeToMinutes(finalLeg.departureTime);
        if (!canConnect) finalLeg.bookingStatus = 'missed';
        final waitAtB = canConnect ? timeToMinutes(finalLeg.departureTime) - actual : 0;
        final waitAtA = (timeToMinutes(actualAToB.departureTime) - timeToMinutes(homeToA.arrivalTime)).clamp(0, 24 * 60).toInt();
        final waiting = waitAtA + waitAtB;
        final duration = timeToMinutes(finalLeg.arrivalTime) - timeToMinutes(homeToA.departureTime);
        final legs = [templateLegs[0].clone(), templateLegs[1].clone(), finalLeg];
        return RoutePossibility(id: 'route-opt-${i + 1}', name: 'Option ${i + 1}: ${['Primary Corridor', 'Later Intercity', 'Evening Recovery'][i]}',
          pathDescription: 'Home → Checkpoint A (Jaipur) → Checkpoint B (Ajmer) → Jodhpur',
          checkpoints: ['HOME', 'JP-JN', 'AII', 'JU'], legs: legs, departureTime: '08:00',
          estimatedArrivalTime: finalLeg.arrivalTime, totalDurationMinutes: duration,
          totalWaitingMinutes: waiting, totalCost: legs.fold(0, (sum, leg) => sum + leg.cost),
          isPrimary: false, isFeasible: canConnect, feasibilityRisk: canConnect ? 'backup' : 'missed',
          feasibilityReason: canConnect ? 'Connection available from Checkpoint B.' : 'Missed connection from Checkpoint B.',
          recommendedAction: canConnect ? 'Available recovery option.' : 'Connection missed.');
      });
    } else if (activeCheckpointId == 'cp-a') {
      routes = routes.map((route) {
        final legs = route.legs.map((leg) => leg.clone()).toList();
        final scheduledLeg = legs[0];
        legs[0] = JourneyLeg(
          id: scheduledLeg.id, from: scheduledLeg.from, to: scheduledLeg.to,
          mode: scheduledLeg.mode, provider: scheduledLeg.provider,
          serviceNumber: scheduledLeg.serviceNumber,
          departureTime: scheduledLeg.departureTime, arrivalTime: target.actualArrival!,
          durationMinutes: (actual - timeToMinutes(scheduledLeg.departureTime)).clamp(0, 24 * 60).toInt(),
          cost: scheduledLeg.cost, bookingStatus: scheduledLeg.bookingStatus,
          bufferMinutesAfter: scheduledLeg.bufferMinutesAfter,
        );
        final waitAtA = (timeToMinutes(legs[1].departureTime) - actual).clamp(0, 24 * 60).toInt();
        final waitAtB = (timeToMinutes(legs[2].departureTime) - timeToMinutes(legs[1].arrivalTime)).clamp(0, 24 * 60).toInt();
        return RoutePossibility(
          id: route.id, name: route.name, pathDescription: route.pathDescription,
          checkpoints: route.checkpoints, legs: legs, departureTime: route.departureTime,
          estimatedArrivalTime: route.estimatedArrivalTime,
          totalDurationMinutes: route.totalDurationMinutes,
          totalWaitingMinutes: waitAtA + waitAtB,
          totalCost: route.totalCost, isPrimary: route.isPrimary,
          isFeasible: route.isFeasible, feasibilityReason: route.feasibilityReason,
          feasibilityRisk: route.feasibilityRisk, recommendedAction: route.recommendedAction,
        );
      }).toList();
    }
    final candidates = activeCheckpointId == 'cp-a'
        ? routes.map((r) => (r, timeToMinutes(r.legs[1].departureTime))).toList()
        : routes.map((r) => (r, timeToMinutes(r.legs[2].departureTime))).toList();
    final feasible = candidates.where((entry) => ready <= entry.$2).toList();

    for (final (route, departure) in candidates) {
      if (departure < ready) {
        route.isFeasible = false;
        route.feasibilityRisk = 'missed';
        route.legs[activeCheckpointId == 'cp-a' ? 1 : 2].bookingStatus = 'missed';
        route.feasibilityReason = 'Missed connection: ready at ${minutesToTime(ready)}, after departure at ${minutesToTime(departure)}.';
        missed = true;
      }
    }
    for (final route in routes) {
      route.isPrimary = false;
      if (route.isFeasible) {
        final selectedId = feasible.isEmpty ? null : feasible.first.$1.id;
        route.feasibilityRisk = route.id == selectedId ? 'none' : 'backup';
        route.recommendedAction = route.id == selectedId ? 'Recommended recovery route.' : 'Available backup route.';
      }
    }

    if (feasible.isNotEmpty) {
      final selected = feasible.first.$1;
      selected.isPrimary = true;
      alert = missed
          ? 'Connection missed. ${selected.name} is the earliest feasible recovery route.'
          : activeCheckpointId == 'cp-a' ? 'Checkpoint A connection verified.' : 'Checkpoint B connection verified.';
      severity = missed ? 'warning' : 'success';
    } else {
      alert = 'All remaining connections are missed. No feasible route is available.';
      severity = 'danger';
    }
    final activeRoutes = routes.where((r) => r.isPrimary && r.isFeasible);
    final activeRoute = activeRoutes.isEmpty ? null : activeRoutes.first;
    return {
      'checkpoints': checkpoints, 'routes': routes, 'activeRouteId': activeRoute?.id,
      'hasMissedConnection': missed, 'alertMessage': alert, 'alertSeverity': severity,
    };
  }
}
