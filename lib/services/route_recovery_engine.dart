import '../models/travel_models.dart';

int timeToMinutes(String timeStr) {
  final parts = timeStr.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

String minutesToTime(int totalMinutes) {
  final normMinutes = (totalMinutes + 24 * 60) % (24 * 60);
  final hours = normMinutes ~/ 60;
  final mins = normMinutes % 60;
  return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
}

String formatDuration(int minutes) {
  final hrs = minutes ~/ 60;
  final mins = minutes % 60;
  if (hrs == 0) return '${mins}m';
  return '${hrs}h ${mins > 0 ? '${mins}m' : ''}'.trim();
}

class RouteRecoveryEngine {
  static List<CheckpointStatus> getInitialCheckpoints() {
    return [
      CheckpointStatus(
        id: 'cp-home',
        name: 'Home (Origin)',
        code: 'HOME',
        sequence: 0,
        scheduledArrival: '07:30',
        scheduledDeparture: '08:00',
        actualArrival: '07:30',
        delayMinutes: 0,
        minTransferTimeMinutes: 10,
        status: 'departed',
        notes: 'Departed on schedule via Vande Bharat Express.',
      ),
      CheckpointStatus(
        id: 'cp-a',
        name: 'Checkpoint A (Jaipur Jn)',
        code: 'JP-JN',
        sequence: 1,
        scheduledArrival: '11:45',
        scheduledDeparture: '12:30',
        actualArrival: null,
        delayMinutes: 0,
        minTransferTimeMinutes: 30,
        status: 'upcoming',
        notes: 'Primary interchange between Northern & Western transit lines.',
      ),
      CheckpointStatus(
        id: 'cp-b',
        name: 'Checkpoint B (Ajmer Terminal)',
        code: 'AII',
        sequence: 2,
        scheduledArrival: '15:15',
        scheduledDeparture: '16:00',
        actualArrival: null,
        delayMinutes: 0,
        minTransferTimeMinutes: 25,
        status: 'not-reached',
        notes: 'Secondary interchange for Marwar express line.',
      ),
      CheckpointStatus(
        id: 'cp-jodhpur',
        name: 'Jodhpur (Final Destination)',
        code: 'JU',
        sequence: 3,
        scheduledArrival: '20:15',
        scheduledDeparture: '20:15',
        actualArrival: null,
        delayMinutes: 0,
        minTransferTimeMinutes: 0,
        status: 'not-reached',
        notes: 'Destination: Blue City heritage terminal.',
      ),
    ];
  }

  static List<RoutePossibility> getInitialRoutes() {
    return [
      RoutePossibility(
        id: 'route-opt-1',
        name: 'Option 1: Primary Standard Corridor',
        pathDescription: 'Home → Checkpoint A (Jaipur) → Checkpoint B (Ajmer) → Jodhpur',
        checkpoints: ['HOME', 'JP-JN', 'AII', 'JU'],
        departureTime: '08:00',
        estimatedArrivalTime: '20:15',
        totalDurationMinutes: 735,
        totalWaitingMinutes: 90,
        totalCost: 2850,
        isPrimary: true,
        isFeasible: true,
        feasibilityRisk: 'none',
        feasibilityReason: 'Scheduled primary route. All connections within safe transfer windows.',
        recommendedAction: 'Proceed with confirmed reservations.',
        legs: [
          JourneyLeg(
            id: 'leg-1-1',
            from: 'Home',
            to: 'Checkpoint A',
            mode: 'train',
            provider: 'Vande Bharat Exp (20977)',
            serviceNumber: 'VB-20977',
            departureTime: '08:00',
            arrivalTime: '11:45',
            durationMinutes: 225,
            cost: 950,
            bookingStatus: 'confirmed',
            bufferMinutesAfter: 45,
          ),
          JourneyLeg(
            id: 'leg-1-2',
            from: 'Checkpoint A',
            to: 'Checkpoint B',
            mode: 'train',
            provider: 'Intercity Superfast (12988)',
            serviceNumber: 'SF-12988',
            departureTime: '12:30',
            arrivalTime: '15:15',
            durationMinutes: 165,
            cost: 720,
            bookingStatus: 'confirmed',
            bufferMinutesAfter: 45,
          ),
          JourneyLeg(
            id: 'leg-1-3',
            from: 'Checkpoint B',
            to: 'Jodhpur',
            mode: 'train',
            provider: 'Marwar Express (14814)',
            serviceNumber: 'ME-14814',
            departureTime: '16:00',
            arrivalTime: '20:15',
            durationMinutes: 255,
            cost: 1180,
            bookingStatus: 'confirmed',
            bufferMinutesAfter: 0,
          ),
        ],
      ),
      RoutePossibility(
        id: 'route-opt-2',
        name: 'Option 2: Direct High-Speed Bypass from A',
        pathDescription: 'Home → Checkpoint A (Jaipur) → Jodhpur (Bypassing B via Direct Highway Express)',
        checkpoints: ['HOME', 'JP-JN', 'JU'],
        departureTime: '08:00',
        estimatedArrivalTime: '19:40',
        totalDurationMinutes: 700,
        totalWaitingMinutes: 65,
        totalCost: 3420,
        isPrimary: false,
        isFeasible: true,
        feasibilityRisk: 'none',
        feasibilityReason: 'Alternative route bypassing Checkpoint B. Later departure from A absorbs up to 65 min delay.',
        recommendedAction: 'Standby backup if Checkpoint A transfer is tight.',
        legs: [
          JourneyLeg(
            id: 'leg-2-1',
            from: 'Home',
            to: 'Checkpoint A',
            mode: 'train',
            provider: 'Vande Bharat Exp (20977)',
            serviceNumber: 'VB-20977',
            departureTime: '08:00',
            arrivalTime: '11:45',
            durationMinutes: 225,
            cost: 950,
            bookingStatus: 'confirmed',
            bufferMinutesAfter: 65,
          ),
          JourneyLeg(
            id: 'leg-2-2',
            from: 'Checkpoint A',
            to: 'Jodhpur',
            mode: 'express-cab',
            provider: 'AeroNova Priority Highway Shuttle',
            serviceNumber: 'AN-EXP-401',
            departureTime: '13:00',
            arrivalTime: '19:40',
            durationMinutes: 400,
            cost: 2470,
            bookingStatus: 'few-seats',
            bufferMinutesAfter: 0,
          ),
        ],
      ),
      RoutePossibility(
        id: 'route-opt-3',
        name: 'Option 3: Southern Corridor via B Bypass',
        pathDescription: 'Home → Checkpoint B (Ajmer Direct) → Jodhpur (Direct Western Link)',
        checkpoints: ['HOME', 'AII', 'JU'],
        departureTime: '08:30',
        estimatedArrivalTime: '21:10',
        totalDurationMinutes: 760,
        totalWaitingMinutes: 50,
        totalCost: 3100,
        isPrimary: false,
        isFeasible: true,
        feasibilityRisk: 'none',
        feasibilityReason: 'Alternative southern rail artery bypassing Jaipur entirely.',
        recommendedAction: 'Available re-route if early delays occur before Jaipur.',
        legs: [
          JourneyLeg(
            id: 'leg-3-1',
            from: 'Home',
            to: 'Checkpoint B',
            mode: 'flight',
            provider: 'Regional Air Connector (S9-312)',
            serviceNumber: 'S9-312',
            departureTime: '09:15',
            arrivalTime: '12:00',
            durationMinutes: 165,
            cost: 2150,
            bookingStatus: 'available',
            bufferMinutesAfter: 60,
          ),
          JourneyLeg(
            id: 'leg-3-2',
            from: 'Checkpoint B',
            to: 'Jodhpur',
            mode: 'volvo-bus',
            provider: 'Rajasthan State Deluxe Express',
            serviceNumber: 'RSRTC-DLX-9',
            departureTime: '14:30',
            arrivalTime: '21:10',
            durationMinutes: 400,
            cost: 950,
            bookingStatus: 'available',
            bufferMinutesAfter: 0,
          ),
        ],
      ),
    ];
  }

  static Map<String, dynamic> recalculate({
    required String activeCheckpointId,
    required int delayMinutes,
    String? customArrivalTimeStr,
  }) {
    final checkpoints = getInitialCheckpoints();
    final routes = getInitialRoutes();

    final targetCheckpoint = checkpoints.firstWhere((c) => c.id == activeCheckpointId);
    final scheduledArrivalMins = timeToMinutes(targetCheckpoint.scheduledArrival);

    int actualArrivalMins;
    if (customArrivalTimeStr != null && customArrivalTimeStr.isNotEmpty) {
      actualArrivalMins = timeToMinutes(customArrivalTimeStr);
      delayMinutes = actualArrivalMins - scheduledArrivalMins;
    } else {
      actualArrivalMins = scheduledArrivalMins + delayMinutes;
    }

    targetCheckpoint.actualArrival = minutesToTime(actualArrivalMins);
    targetCheckpoint.delayMinutes = delayMinutes;
    targetCheckpoint.status = delayMinutes > 15 ? 'delayed' : 'on-time';

    String alertMessage = '';
    String alertSeverity = 'info';
    bool hasMissedConnection = false;

    final route1 = routes.firstWhere((r) => r.id == 'route-opt-1');
    final route2 = routes.firstWhere((r) => r.id == 'route-opt-2');
    final route3 = routes.firstWhere((r) => r.id == 'route-opt-3');

    final leg1_2 = route1.legs[1];
    final leg2_2 = route2.legs[1];

    if (activeCheckpointId == 'cp-a') {
      final minTransfer = targetCheckpoint.minTransferTimeMinutes; // 30m
      final earliestReady = actualArrivalMins + minTransfer;

      final leg1Dep = timeToMinutes(leg1_2.departureTime); // 12:30 -> 750
      final leg2Dep = timeToMinutes(leg2_2.departureTime); // 13:00 -> 780

      if (earliestReady > leg1Dep) {
        // Missed connection for Option 1
        hasMissedConnection = true;
        route1.isPrimary = false;
        route1.isFeasible = false;
        route1.feasibilityRisk = 'missed';
        leg1_2.bookingStatus = 'cancelled';
        route1.feasibilityReason =
            'MISSED CONNECTION: Arrived at ${targetCheckpoint.actualArrival}. Minimum transfer is ${minTransfer}m (ready at ${minutesToTime(earliestReady)}), but connection ${leg1_2.serviceNumber} departed at ${leg1_2.departureTime}.';
        route1.recommendedAction = 'Option 1 disqualified.';

        if (earliestReady <= leg2Dep) {
          // Option 2 promoted!
          route2.isPrimary = true;
          route2.isFeasible = true;
          route2.feasibilityRisk = (earliestReady + 10 >= leg2Dep) ? 'tight-connection' : 'none';
          route2.feasibilityReason =
              'PROMOTED ALTERNATIVE: Direct highway express ${leg2_2.serviceNumber} departs at ${leg2_2.departureTime}. Buffer remaining: ${leg2Dep - earliestReady} mins. Jodhpur ETA: ${route2.estimatedArrivalTime}.';
          route2.recommendedAction = 'RECOMMENDED RECOVERY: Promoted to Option 2. Confirm seat reservation.';

          alertMessage =
              'CRITICAL ALERT: Connection ${leg1_2.serviceNumber} missed at Checkpoint A due to +${delayMinutes}m delay. Option 1 disqualified. Option 2 dynamically promoted!';
          alertSeverity = 'warning';
        } else {
          // Both 1 and 2 missed
          route2.isPrimary = false;
          route2.isFeasible = false;
          route2.feasibilityRisk = 'missed';
          route2.feasibilityReason = 'Connection deadline for Option 2 passed at ${leg2_2.departureTime}.';

          route3.isPrimary = true;
          route3.isFeasible = true;
          route3.feasibilityReason = 'Emergency alternate corridor via Southern flight connector.';
          route3.recommendedAction = 'Emergency rebooking required via Option 3.';

          alertMessage =
              'EMERGENCY: Both normal connections missed at Checkpoint A (+${delayMinutes}m delay). Option 3 promoted as emergency corridor.';
          alertSeverity = 'danger';
        }
      } else {
        // On-time
        route1.isPrimary = true;
        route1.isFeasible = true;
        final bufferLeft = leg1Dep - earliestReady;
        route1.feasibilityReason =
            'Connection secure. Reached Checkpoint A at ${targetCheckpoint.actualArrival} (+${delayMinutes}m). Buffer remaining: $bufferLeft minutes.';
        route1.recommendedAction = 'Proceed with planned Option 1 connection.';

        route2.isPrimary = false;
        route2.isFeasible = true;

        alertMessage = delayMinutes > 0
            ? 'Checkpoint A update: +${delayMinutes}m delay absorbed within 45m buffer. Option 1 on track.'
            : 'Checkpoint A: All connections running normally on schedule.';
        alertSeverity = 'success';
      }
    } else if (activeCheckpointId == 'cp-b') {
      final minTransfer = targetCheckpoint.minTransferTimeMinutes; // 25m
      final earliestReady = actualArrivalMins + minTransfer;
      final leg1_3 = route1.legs[2];
      final leg3Dep = timeToMinutes(leg1_3.departureTime); // 16:00

      if (earliestReady > leg3Dep) {
        hasMissedConnection = true;
        route1.isPrimary = false;
        route1.isFeasible = false;
        route1.feasibilityRisk = 'missed';
        leg1_3.bookingStatus = 'cancelled';
        route1.feasibilityReason =
            'MISSED CONNECTION AT B: Reached at ${targetCheckpoint.actualArrival}. Final leg departed at ${leg1_3.departureTime}.';

        final lateCoachETA = minutesToTime(actualArrivalMins + minTransfer + 270);
        route2.isPrimary = true;
        route2.isFeasible = true;
        route2.name = 'Option 2 (Recovered): Emergency Intercity Shuttle from B';
        route2.pathDescription = 'Checkpoint B (Ajmer) → Jodhpur (Night Coach)';
        route2.estimatedArrivalTime = lateCoachETA;
        route2.totalCost = 3680;
        route2.feasibilityReason =
            'RE-ROUTE ACTIVE: Catching night intercity coach departing ${minutesToTime(earliestReady + 20)}. Revised Jodhpur ETA: $lateCoachETA.';
        route2.recommendedAction = 'Confirm emergency replacement transfer from B.';

        alertMessage = 'MISSED CONNECTION AT B: Recalculated feasible evening alternative with revised ETA: $lateCoachETA.';
        alertSeverity = 'danger';
      } else {
        route1.isPrimary = true;
        route1.isFeasible = true;
        route1.feasibilityReason = 'Checkpoint B reached at ${targetCheckpoint.actualArrival}. Final connection verified.';
        alertMessage = 'Checkpoint B connection verified. On track for scheduled Jodhpur arrival.';
        alertSeverity = 'success';
      }
    }

    final primary = routes.firstWhere((r) => r.isPrimary && r.isFeasible, orElse: () => routes[0]);

    return {
      'checkpoints': checkpoints,
      'routes': routes,
      'activeRouteId': primary.id,
      'hasMissedConnection': hasMissedConnection,
      'alertMessage': alertMessage,
      'alertSeverity': alertSeverity,
    };
  }
}
