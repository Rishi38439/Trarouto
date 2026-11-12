// Keep Material types compatible with the app shell.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aeronova_travel/models/travel_models.dart';
import 'package:aeronova_travel/services/route_recovery_engine.dart';
import 'package:aeronova_travel/widgets/recovery_route_tree.dart';

Future<void> pumpRouteTree(
  WidgetTester tester, {
  required List<RoutePossibility> routes,
  required String selectedId,
  Size size = const Size(375, 812),
  double scale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: RecoveryRouteTree(
            routes: routes,
            recommendedId: 'route-opt-1',
            selectedId: selectedId,
            branchAtB: true,
            arrived: const {},
            complete: false,
            onSelected: (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void setAjmerArrival(RoutePossibility route, String arrivalTime) {
  final leg = route.legs[1];
  route.legs[1] = JourneyLeg(
    id: leg.id,
    from: leg.from,
    to: leg.to,
    mode: leg.mode,
    provider: leg.provider,
    serviceNumber: leg.serviceNumber,
    departureTime: leg.departureTime,
    arrivalTime: arrivalTime,
    durationMinutes:
        timeToMinutes(arrivalTime) - timeToMinutes(leg.departureTime),
    cost: leg.cost,
    bookingStatus: leg.bookingStatus,
    bufferMinutesAfter: leg.bufferMinutesAfter,
  );
}

void main() {
  testWidgets('Ajmer transfer labels show computed wait and spare margin', (
    tester,
  ) async {
    final routes = RouteRecoveryEngine.getInitialRoutes();
    setAjmerArrival(routes[1], '16:05');
    setAjmerArrival(routes[2], '16:05');

    await pumpRouteTree(tester, routes: routes, selectedId: 'route-opt-2');

    expect(find.text('40 min transfer in Ajmer'), findsOneWidget);
    expect(find.text('25 min minimum · 15 min spare'), findsOneWidget);
    await pumpRouteTree(tester, routes: routes, selectedId: 'route-opt-3');
    expect(find.text('100 min transfer in Ajmer'), findsOneWidget);
    expect(find.text('25 min minimum · 75 min spare'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'minimum transfer has no spare time and backups compare to route 1',
    (tester) async {
      final routes = RouteRecoveryEngine.getInitialRoutes();
      setAjmerArrival(routes[1], '16:20');

      await pumpRouteTree(
        tester,
        routes: routes,
        selectedId: 'route-opt-2',
        size: const Size(320, 780),
        scale: 2,
      );

      expect(find.text('25 min transfer in Ajmer'), findsOneWidget);
      expect(find.text('25 min minimum · No spare time'), findsOneWidget);
      expect(find.text('+45 min vs original'), findsOneWidget);
      expect(find.text('+₹100 vs original'), findsOneWidget);
      expect(find.text('+1h 45m vs original'), findsOneWidget);
      expect(find.text('+₹250 vs original'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
