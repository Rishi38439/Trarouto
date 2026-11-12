import 'dart:async';

// Use the app shell's Material library; migrate the whole app together.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:aeronova_travel/models/travel_models.dart';
import 'package:aeronova_travel/screens/smart_route_recovery_screen.dart';
import 'package:aeronova_travel/services/journey_location_service.dart';
import 'package:aeronova_travel/widgets/recovery_journey_map.dart';
import 'package:aeronova_travel/widgets/recovery_route_tree.dart';

class UnavailableLocation extends JourneyLocationService {
  const UnavailableLocation();

  @override
  Stream<Position> watch() =>
      Stream.error(Exception('Location permission denied'));
}

Future<void> openRecovery(
  WidgetTester tester, {
  Size size = const Size(375, 812),
  double scale = 1,
  void Function(RoutePossibility)? onRebooked,
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
      home: SmartRouteRecoveryScreen(
        loadMapTiles: false,
        locationService: const UnavailableLocation(),
        onRebooked: onRebooked,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> chooseScenario(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text('Scenarios'));
  await tester.tap(find.text('Scenarios'));
  await tester.pumpAndSettle();
  final target = find.text(label);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> openMap(WidgetTester tester) async {
  final mapButton = find.byTooltip('Open journey map');
  await tester.ensureVisible(mapButton);
  await tester.tap(mapButton);
  await tester.pumpAndSettle();
}

Future<void> closeMap(WidgetTester tester) async {
  Navigator.of(tester.element(find.byType(SmartRouteRecoveryScreen))).pop();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('current plan, backup plans and map preview are distinct', (
    tester,
  ) async {
    await openRecovery(tester);

    expect(find.text('Current plan'), findsOneWidget);
    expect(find.text('Backup plans'), findsOneWidget);
    expect(find.byKey(const ValueKey('current-plan-tree')), findsOneWidget);
    expect(find.byKey(const ValueKey('backup-plans-tree')), findsOneWidget);
    expect(find.byKey(const ValueKey('current-plan-map')), findsOneWidget);
    expect(find.byTooltip('Open journey map'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
  });

  testWidgets('confirming a backup makes it current and keeps the old plan', (
    tester,
  ) async {
    await openRecovery(tester);
    await chooseScenario(tester, 'On time');

    final branch = find.descendant(
      of: find.byKey(const ValueKey('backup-plans-tree')),
      matching: find.byKey(const ValueKey('route-branch-route-opt-3')),
    );
    await tester.ensureVisible(branch);
    await tester.tap(branch);
    await tester.pumpAndSettle();

    final currentTree = tester.widget<RecoveryRouteTree>(
      find.byKey(const ValueKey('current-plan-tree')),
    );
    final backupTree = tester.widget<RecoveryRouteTree>(
      find.byKey(const ValueKey('backup-plans-tree')),
    );
    expect(currentTree.currentRouteId, 'route-opt-1');
    expect(backupTree.currentRouteId, 'route-opt-1');
    expect(backupTree.selectedId, 'route-opt-3');

    final review = find.text('Review recovery booking');
    await tester.ensureVisible(review);
    await tester.tap(review);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm route'));
    await tester.pumpAndSettle();

    final promotedTree = tester.widget<RecoveryRouteTree>(
      find.byKey(const ValueKey('current-plan-tree')),
    );
    final remainingBackups = tester.widget<RecoveryRouteTree>(
      find.byKey(const ValueKey('backup-plans-tree')),
    );
    expect(promotedTree.currentRouteId, 'route-opt-3');
    expect(
      remainingBackups.routes.map((route) => route.id),
      contains('route-opt-1'),
    );
    await tester.ensureVisible(find.text('Resume demo journey'));
    await tester.tap(find.text('Resume demo journey'));
    await tester.pump(const Duration(seconds: 20));
    final tracked = tester.widget<RecoveryJourneyMap>(
      find.byKey(const ValueKey('current-plan-map')),
    );
    expect(tracked.latitude, greaterThan(recoveryRoutePoints[2].latitude));
    expect(tracked.latitude, lessThan(recoveryRoutePoints[1].latitude));
    expect(
      tester
          .widget<RecoveryRouteTree>(
            find.byKey(const ValueKey('current-plan-tree')),
          )
          .currentRouteId,
      'route-opt-3',
    );
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump();
  });

  testWidgets(
    'tapping a tree branch selects its summary without changing the recommendation',
    (tester) async {
      await openRecovery(tester);
      await chooseScenario(tester, 'On time');
      final branch = find.descendant(
        of: find.byKey(const ValueKey('backup-plans-tree')),
        matching: find.byKey(const ValueKey('route-branch-route-opt-3')),
      );
      await tester.ensureVisible(branch);
      await tester.tap(branch);
      await tester.pumpAndSettle();
      final tree = tester.widget<RecoveryRouteTree>(
        find.byKey(const ValueKey('backup-plans-tree')),
      );
      expect(tree.recommendedId, 'route-opt-1');
      expect(tree.selectedId, 'route-opt-3');
      expect(find.text('Selected backup'), findsOneWidget);
      await tester.ensureVisible(branch);
      await tester.tap(branch);
      await tester.pumpAndSettle();
      expect(find.text('Selected backup'), findsNothing);
      expect(
        find.byKey(const ValueKey('upcoming-cp-b-route-opt-3')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('paused delay injection updates the journey immediately', (
    tester,
  ) async {
    await openRecovery(tester);
    await tester.ensureVisible(find.text('Play demo journey'));
    await tester.tap(find.text('Play demo journey'));
    await tester.pump(const Duration(seconds: 10));
    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();
    await openMap(tester);
    final before = tester
        .widget<RecoveryJourneyMap>(
          find.byKey(const ValueKey('full-journey-map')),
        )
        .latitude;
    await closeMap(tester);
    await tester.tap(find.text('Scenarios'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('+15 min delay'));
    await tester.tap(find.text('+15 min delay'));
    await tester.pumpAndSettle();
    await openMap(tester);
    final after = tester
        .widget<RecoveryJourneyMap>(
          find.byKey(const ValueKey('full-journey-map')),
        )
        .latitude;
    expect(after, isNot(before));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'demo can pause, resume and finish without a past-checkpoint booking',
    (tester) async {
      await openRecovery(tester);
      await tester.ensureVisible(find.text('Play demo journey'));
      await tester.tap(find.text('Play demo journey'));
      await tester.pump(const Duration(seconds: 10));
      await tester.ensureVisible(find.text('Pause'));
      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();
      await openMap(tester);
      final beforePause = tester
          .widget<RecoveryJourneyMap>(
            find.byKey(const ValueKey('full-journey-map')),
          )
          .latitude;
      await tester.pump(const Duration(seconds: 5));
      expect(
        tester
            .widget<RecoveryJourneyMap>(
              find.byKey(const ValueKey('full-journey-map')),
            )
            .latitude,
        beforePause,
      );
      await closeMap(tester);
      await tester.ensureVisible(find.text('Resume demo journey'));
      await tester.tap(find.text('Resume demo journey'));
      await tester.pump(const Duration(seconds: 1));
      await openMap(tester);
      expect(
        tester
            .widget<RecoveryJourneyMap>(
              find.byKey(const ValueKey('full-journey-map')),
            )
            .latitude,
        isNot(beforePause),
      );
      await closeMap(tester);
      await tester.pump(const Duration(seconds: 100));
      expect(find.text('Journey complete'), findsOneWidget);
      await openMap(tester);
      final map = tester.widget<RecoveryJourneyMap>(
        find.byKey(const ValueKey('full-journey-map')),
      );
      expect(map.latitude, recoveryRoutePoints.last.latitude);
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'GPS is default and denied permission never creates a device dot',
    (tester) async {
      await openRecovery(tester);
      expect(find.text('GPS mode'), findsOneWidget);
      expect(find.text('Retry'), findsWidgets);
      await openMap(tester);
      expect(
        tester
            .widget<RecoveryJourneyMap>(
              find.byKey(const ValueKey('full-journey-map')),
            )
            .showUserLocation,
        isFalse,
      );
      final tree = tester.widget<RecoveryRouteTree>(
        find.byKey(const ValueKey('backup-plans-tree')),
      );
      expect(tree.routes.where((route) => route.isFeasible), hasLength(3));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'late arrival promotes a backup, confirmation calls booking once',
    (tester) async {
      final bookings = <RoutePossibility>[];
      await openRecovery(tester, onRebooked: bookings.add);
      await chooseScenario(tester, 'Late at A · +45m');
      expect(find.text('Demo tracking'), findsOneWidget);
      expect(find.byKey(const ValueKey('checkpoint-cp-home')), findsNothing);
      expect(find.byKey(const ValueKey('checkpoint-cp-a')), findsNothing);
      expect(find.textContaining('Missed connections'), findsOneWidget);
      final review = find.text('Review recovery booking').first;
      await tester.ensureVisible(review);
      await tester.tap(review);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm route'));
      await tester.pumpAndSettle();
      expect(bookings, hasLength(1));
      expect(bookings.single.id, 'route-opt-2');
      final confirmed = find.text('Route confirmed').first;
      await tester.ensureVisible(confirmed);
      await tester.tap(confirmed);
      await tester.pumpAndSettle();
      expect(bookings, hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('all missed has no enabled booking action', (tester) async {
    await openRecovery(tester);
    await chooseScenario(tester, 'All missed · +140m');
    expect(find.textContaining('No feasible'), findsWidgets);
    expect(find.text('Review recovery booking'), findsNothing);
    expect(find.text('Review booking'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(375, 812),
    const Size(812, 375),
    const Size(1024, 768),
  ]) {
    testWidgets('recovery tree fits $size with enlarged text', (tester) async {
      await openRecovery(tester, size: size, scale: 2);
      await chooseScenario(tester, 'Late at B · +50m');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('demo advances a marker and stops safely when screen closes', (
    tester,
  ) async {
    await openRecovery(tester);
    final play = find.text('Play demo journey');
    await tester.ensureVisible(play);
    await tester.tap(play);
    await tester.pump(const Duration(seconds: 10));
    // The map is a modal view, and the simulated trip keeps advancing behind it.
    await openMap(tester);
    final map = tester.widget<RecoveryJourneyMap>(
      find.byKey(const ValueKey('full-journey-map')),
    );
    expect(map.isLive, isFalse);
    expect(map.showUserLocation, isTrue);
    expect(map.latitude, isNot(28.6139));
    final beforeModalPlayback = map.latitude;
    await tester.pump(const Duration(seconds: 1));
    expect(
      tester
          .widget<RecoveryJourneyMap>(
            find.byKey(const ValueKey('full-journey-map')),
          )
          .latitude,
      isNot(beforeModalPlayback),
    );
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'demo uses fifteen simulated minutes per second and hides visited stops',
    (tester) async {
      await openRecovery(tester);
      await tester.ensureVisible(find.text('Play demo journey'));
      await tester.tap(find.text('Play demo journey'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Demo clock · 08:15'), findsOneWidget);

      await tester.pump(const Duration(seconds: 19));
      expect(find.byKey(const ValueKey('checkpoint-cp-home')), findsNothing);
      expect(find.byKey(const ValueKey('checkpoint-cp-a')), findsNothing);

      await tester.pump(const Duration(seconds: 12));
      expect(find.byKey(const ValueKey('checkpoint-cp-b')), findsNothing);

      await tester.pump(const Duration(seconds: 100));
      expect(find.byKey(const ValueKey('checkpoint-cp-jodhpur')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('late at B shows only the remaining route from Ajmer', (
    tester,
  ) async {
    await openRecovery(tester);
    await chooseScenario(tester, 'Late at B · +50m');
    expect(find.byKey(const ValueKey('checkpoint-cp-home')), findsNothing);
    expect(find.byKey(const ValueKey('checkpoint-cp-a')), findsNothing);
    expect(
      find.byKey(const ValueKey('upcoming-cp-jodhpur-route-opt-2')),
      findsOneWidget,
    );
    expect(find.text('Home'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
