import 'dart:async';

// Use the app shell's Material library; migrate the whole app together.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/travel_models.dart';
import '../services/journey_location_service.dart';
import '../services/route_recovery_engine.dart';
import '../widgets/recovery_journey_map.dart';
import '../widgets/recovery_route_tree.dart';

class SmartRouteRecoveryScreen extends StatefulWidget {
  final Function(RoutePossibility)? onRebooked;
  final bool loadMapTiles;
  final JourneyLocationService locationService;

  const SmartRouteRecoveryScreen({
    super.key,
    this.onRebooked,
    this.loadMapTiles = true,
    this.locationService = const JourneyLocationService(),
  });

  @override
  State<SmartRouteRecoveryScreen> createState() =>
      _SmartRouteRecoveryScreenState();
}

class _SmartRouteRecoveryScreenState extends State<SmartRouteRecoveryScreen>
    with WidgetsBindingObserver {
  static const _blue = Color(0xFF147FE8);
  static const _orange = Color(0xFFF97316);
  static const _navy = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _routePoints = recoveryRoutePoints;

  bool _isLive = true;
  bool _isLoadingLocation = true;
  bool _isPlaying = false;
  bool _isOutsideCorridor = false;
  bool _isComplete = false;
  String? _locationMessage;
  Position? _position;
  StreamSubscription<Position>? _locationSubscription;
  Timer? _demoTimer;
  Timer? _fixExpiryTimer;
  final ValueNotifier<int> _mapRevision = ValueNotifier(0);
  int _demoMinutes = 8 * 60;
  int _demoADelay = 0;
  int _demoBDelay = 0;
  int _demoFinalDelay = 0;
  int _gpsGeneration = 0;
  RoutePossibility? _journeyRoute;
  int _delayMinutes = 0;
  String _checkpointId = 'cp-a';
  String? _lastArrivedCheckpointId;
  String? _lastArrivalTime;
  String? _selectedRouteId;
  String? _demoPreferredOriginId;
  String? _confirmedRouteId;
  final Set<String> _arrived = {};
  CheckpointArrivalDetector? _arrivalDetector;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startGps());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (!_isLoadingLocation || state != AppLifecycleState.inactive) {
        _stopLocation();
      }
      _pauseDemo();
      if (mounted && _isLive && !_isLoadingLocation) {
        setState(
          () => _locationMessage = 'GPS paused while the app is inactive. Tap Use my location to resume.',
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _demoTimer?.cancel();
    _fixExpiryTimer?.cancel();
    _locationSubscription?.cancel();
    _mapRevision.dispose();
    super.dispose();
  }

  Future<void> _startGps() async {
    if (!mounted) return;
    final generation = ++_gpsGeneration;
    setState(() {
      _isLive = true;
      _isLoadingLocation = true;
      _locationMessage = null;
      _isOutsideCorridor = false;
      _isComplete = false;
      _delayMinutes = 0;
      _arrivalDetector = null;
      _journeyRoute = null;
      _position = null;
      _checkpointId = 'cp-a';
      _lastArrivedCheckpointId = null;
      _lastArrivalTime = null;
      _arrived.clear();
      _confirmedRouteId = null;
    });
    _pauseDemo();
    try {
      await _locationSubscription?.cancel();
      if (!mounted || !_isLive || generation != _gpsGeneration) return;
      _locationSubscription = widget.locationService.watch().listen(
        _onPosition,
        onError: (Object error) {
          if (!mounted) return;
          setState(() {
            _isLoadingLocation = false;
            _locationMessage = 'Location is unavailable. Check location access and try again, or play the demo journey.';
          });
        },
        onDone: () {
          if (!mounted) return;
          setState(() {
            _isLoadingLocation = false;
            _locationMessage =
                'Location updates stopped. Tap Use my location to retry.';
          });
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _locationMessage = 'Location access is unavailable. Check permission and try again, or play the demo journey.';
        });
      }
    }
  }

  void _onPosition(Position position) {
    if (!mounted || !_isLive || _isComplete) return;
    if (!position.latitude.isFinite ||
        !position.longitude.isFinite ||
        position.latitude.abs() > 90 ||
        position.longitude.abs() > 180 ||
        !position.accuracy.isFinite ||
        position.accuracy < 0) {
      return;
    }
    final age = DateTime.now().difference(position.timestamp);
    final fresh =
        !age.isNegative &&
        age <= const Duration(seconds: 30) &&
        position.accuracy <= 100;
    _fixExpiryTimer?.cancel();
    if (fresh) {
      _fixExpiryTimer = Timer(const Duration(seconds: 31), () {
        if (!mounted || !_isLive || _isComplete) return;
        setState(() {
          _isOutsideCorridor = true;
          _locationMessage = 'Last GPS fix is stale. Waiting for a fresh position; arrival checks are paused.';
        });
      });
    }
    final upcoming = _upcomingCheckpoint;
    final target = _coordinateFor(upcoming.id);
    final inCorridor =
        Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          target.latitude,
          target.longitude,
        ) <=
        10000;
    var arrived = false;
    if (fresh && inCorridor) {
      _arrivalDetector ??= CheckpointArrivalDetector(
        latitude: target.latitude,
        longitude: target.longitude,
      );
      arrived = _arrivalDetector!.add(position);
    } else {
      _arrivalDetector = null;
    }
    setState(() {
      _position = position;
      _isLoadingLocation = false;
      _isOutsideCorridor = !inCorridor;
      _locationMessage = !fresh
          ? 'GPS fix is stale or inaccurate. Arrival checks need a fresh, accurate fix.'
          : !inCorridor
          ? 'Outside the demo route corridor. Schedule preview only; timing suggestions are paused.'
          : null;
      if (arrived) _markArrival(upcoming.id);
    });
    _mapRevision.value++;
  }

  void _stopLocation() {
    _gpsGeneration++;
    _fixExpiryTimer?.cancel();
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  Position _demoFix(LatLng point) => Position(
    latitude: point.latitude,
    longitude: point.longitude,
    timestamp: DateTime.now(),
    accuracy: 5,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  RoutePossibility? _primary(Map<String, dynamic> result) {
    for (final route in result['routes'] as List<RoutePossibility>) {
      if (route.isPrimary && route.isFeasible) return route;
    }
    return null;
  }

  void _resetDemo() {
    _stopLocation();
    _pauseDemo();
    setState(() {
      _isLive = false;
      _isLoadingLocation = false;
      _isOutsideCorridor = false;
      _isComplete = false;
      _demoMinutes = 480;
      _demoADelay = 0;
      _demoBDelay = 0;
      _demoFinalDelay = 0;
      _delayMinutes = 0;
      _checkpointId = 'cp-a';
      _journeyRoute = null;
      _lastArrivedCheckpointId = null;
      _lastArrivalTime = null;
      _confirmedRouteId = null;
      _selectedRouteId = null;
      _demoPreferredOriginId = null;
      _arrived.clear();
      _arrivalDetector = null;
      _position = _demoFix(_routePoints.first);
      _locationMessage =
          'Demo journey: simulated clock, position and schedules';
    });
  }

  void _playDemo() {
    if (_isLive || _isComplete) _resetDemo();
    _stopLocation();
    setState(() => _isPlaying = true);
    _demoTimer?.cancel();
    _demoTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isPlaying) return;
      setState(() {
        _demoMinutes += 15;
        _advanceDemo();
      });
    });
  }

  void _advanceDemo() {
    final arrivalA = 705 + _demoADelay;
    final aResult = RouteRecoveryEngine.recalculate(
      activeCheckpointId: 'cp-a',
      delayMinutes: _demoADelay,
    );
    final preferredA = _findRoute(
      aResult['routes'] as List<RoutePossibility>,
      _demoPreferredOriginId,
    );
    final aRoute = preferredA != null && preferredA.isFeasible
        ? preferredA
        : _primary(aResult);
    _journeyRoute = aRoute;
    _checkpointId = 'cp-a';
    _delayMinutes = _demoADelay;
    _arrived.add('cp-home');
    LatLng point;
    if (_demoMinutes < arrivalA) {
      point = _between(
        _routePoints[0],
        _routePoints[1],
        (_demoMinutes - 480) / (arrivalA - 480),
      );
    } else if (aRoute == null) {
      point = _routePoints[1];
      _arrived.add('cp-a');
      _isPlaying = false;
      _demoTimer?.cancel();
    } else {
      _arrived.add('cp-a');
      final departureA = timeToMinutes(aRoute.legs[1].departureTime);
      final arrivalB = timeToMinutes(aRoute.legs[1].arrivalTime) + _demoBDelay;
      if (_demoMinutes < departureA) {
        point = _routePoints[1];
      } else if (_demoMinutes < arrivalB) {
        point = _between(
          _routePoints[1],
          _routePoints[2],
          (_demoMinutes - departureA) / (arrivalB - departureA),
        );
      } else {
        _checkpointId = 'cp-b';
        _delayMinutes = arrivalB - 915;
        _arrived.add('cp-b');
        final bResult = RouteRecoveryEngine.recalculate(
          activeCheckpointId: 'cp-b',
          delayMinutes: _delayMinutes,
          completedRoute: aRoute,
        );
        final preferredB = _findRoute(
          bResult['routes'] as List<RoutePossibility>,
          _confirmedRouteId,
        );
        final bRoute = preferredB != null && preferredB.isFeasible
            ? preferredB
            : _primary(bResult);
        if (bRoute == null) {
          point = _routePoints[2];
          _isPlaying = false;
          _demoTimer?.cancel();
        } else {
          final departureB = timeToMinutes(bRoute.legs.last.departureTime);
          final arrivalJ =
              timeToMinutes(bRoute.estimatedArrivalTime) + _demoFinalDelay;
          point = _demoMinutes < departureB
              ? _routePoints[2]
              : _between(
                  _routePoints[2],
                  _routePoints[3],
                  (_demoMinutes - departureB) / (arrivalJ - departureB),
                );
          if (_demoMinutes >= arrivalJ) {
            _demoMinutes = arrivalJ;
            _isComplete = true;
            _arrived.add('cp-jodhpur');
            _isPlaying = false;
            _demoTimer?.cancel();
          }
        }
      }
    }
    _position = _demoFix(point);
    _mapRevision.value++;
  }

  LatLng _between(LatLng a, LatLng b, double fraction) {
    final t = fraction.clamp(0.0, 1.0);
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );
  }

  void _addDelay() {
    setState(() {
      if (!_arrived.contains('cp-a')) {
        _demoADelay += 15;
        _delayMinutes = _demoADelay;
      } else if (!_arrived.contains('cp-b')) {
        _demoBDelay += 15;
      } else {
        _demoFinalDelay += 15;
      }
      _demoMinutes += 15;
      _confirmedRouteId = null;
      _advanceDemo();
    });
  }

  void _pauseDemo() {
    _demoTimer?.cancel();
    _demoTimer = null;
    if (_isPlaying && mounted) setState(() => _isPlaying = false);
  }

  void _setScenario(String checkpoint, int delay) {
    _resetDemo();
    setState(() {
      _demoADelay = checkpoint == 'cp-a' ? delay : 0;
      _demoBDelay = checkpoint == 'cp-b' ? delay : 0;
      _checkpointId = checkpoint;
      _delayMinutes = delay;
      _demoMinutes = (checkpoint == 'cp-b' ? 915 : 705) + delay;
      _selectedRouteId = null;
      _demoPreferredOriginId = null;
      _advanceDemo();
      _locationMessage = 'Demo scenario: simulated estimates';
    });
  }

  void _markArrival(String checkpointId) {
    _arrived.add(checkpointId);
    if (checkpointId == 'cp-a' || checkpointId == 'cp-b') {
      _lastArrivedCheckpointId = checkpointId;
      final now = DateTime.now();
      _lastArrivalTime = _clockLabel(now.hour * 60 + now.minute);
    }
    if (checkpointId == 'cp-a') {
      _journeyRoute = _primary(
        RouteRecoveryEngine.recalculate(
          activeCheckpointId: 'cp-a',
          delayMinutes: 0,
          customArrivalTimeStr: _lastArrivalTime,
        ),
      );
      _checkpointId = 'cp-b';
      _arrivalDetector = CheckpointArrivalDetector(
        latitude: _routePoints[2].latitude,
        longitude: _routePoints[2].longitude,
      );
    } else if (checkpointId == 'cp-b') {
      _checkpointId = 'cp-jodhpur';
      _arrivalDetector = null;
    } else if (checkpointId == 'cp-jodhpur') {
      _isComplete = true;
      _stopLocation();
    }
    _confirmedRouteId = null;
  }

  void _manualArrival() {
    final id = _upcomingCheckpoint.id;
    setState(() {
      _markArrival(id);
      _locationMessage =
          'Arrival at ${_checkpointName(id)} confirmed manually.';
      _isOutsideCorridor = false;
    });
  }

  CheckpointStatus get _upcomingCheckpoint {
    final checkpoints = RouteRecoveryEngine.getInitialCheckpoints();
    final nextId = !_isLive
        ? (_isComplete || _arrived.contains('cp-b')
              ? 'cp-jodhpur'
              : _arrived.contains('cp-a')
              ? 'cp-b'
              : 'cp-a')
        : _checkpointId;
    return checkpoints.firstWhere((checkpoint) => checkpoint.id == nextId);
  }

  LatLng _coordinateFor(String id) => switch (id) {
    'cp-a' => _routePoints[1],
    'cp-b' => _routePoints[2],
    'cp-jodhpur' => _routePoints[3],
    _ => _routePoints[0],
  };

  String _checkpointName(String id) => switch (id) {
    'cp-a' => 'Checkpoint A · Jaipur',
    'cp-b' => 'Checkpoint B · Ajmer',
    'cp-jodhpur' => 'Jodhpur',
    _ => 'Home',
  };

  String _clockLabel(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  RoutePossibility? _findRoute(List<RoutePossibility> routes, String? id) {
    for (final route in routes) {
      if (route.id == id) return route;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final evaluateId = _isLive
        ? (_lastArrivedCheckpointId ?? 'cp-a')
        : _checkpointId;
    final result = RouteRecoveryEngine.recalculate(
      activeCheckpointId: evaluateId,
      delayMinutes: _delayMinutes,
      customArrivalTimeStr: _isLive ? _lastArrivalTime : null,
      completedRoute: evaluateId == 'cp-b' ? _journeyRoute : null,
    );
    final routes = result['routes'] as List<RoutePossibility>;
    final available = routes.where((r) => r.isFeasible).toList();
    final primary = result['activeRouteId'] as String?;
    final currentPlan =
        _findRoute(available, _confirmedRouteId) ??
        _findRoute(available, primary);
    final currentId = currentPlan?.id;
    final backups = available.where((route) => route.id != currentId).toList();
    final history = routes.where((r) => !r.isFeasible).toList();
    final branchAtB = evaluateId == 'cp-b';
    final showRisk = history.isNotEmpty && !_isComplete;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Roboto'),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _navy,
            foregroundColor: Colors.white,
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Delhi to Jodhpur',
                                style: TextStyle(
                                  fontSize: 23,
                                  height: 1.2,
                                  fontWeight: FontWeight.w700,
                                  color: _navy,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _badge(
                                _isLive ? 'GPS mode' : 'Demo tracking',
                                _isLive ? _blue : const Color(0xFF9A3412),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Tooltip(
                          message: 'Open journey map',
                          child: OutlinedButton.icon(
                            onPressed: _showMap,
                            icon: const Icon(Icons.map_outlined, size: 19),
                            label: const Text('Map'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _blue,
                              minimumSize: const Size(48, 48),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isComplete
                          ? 'Journey complete'
                          : 'Next stop · ${_upcomingCheckpoint.id == 'cp-a'
                                ? 'Jaipur'
                                : _upcomingCheckpoint.id == 'cp-b'
                                ? 'Ajmer'
                                : 'Jodhpur'}',
                      style: const TextStyle(fontSize: 14, color: _muted),
                    ),
                    const SizedBox(height: 16),
                    _playbackBar(),
                    if (!_isLive) ...[
                      const SizedBox(height: 12),
                      _demoProgress(currentPlan),
                    ],
                    const SizedBox(height: 16),
                    if (showRisk)
                      _notice(
                        available.isEmpty
                            ? 'All connections missed'
                            : currentPlan?.id == _confirmedRouteId
                            ? 'Current plan confirmed'
                            : 'Plan ${primary?.split('-').last} is now your best route',
                        available.isEmpty
                            ? 'No remaining departure fits your transfer window.'
                            : currentPlan?.id == _confirmedRouteId
                            ? 'Your confirmed replacement remains available.'
                            : 'Your earlier connection is unavailable. A later connection still works.',
                        _orange,
                      )
                    else if (_isLive)
                      _notice(
                        _isLoadingLocation
                            ? 'Finding your location'
                            : _position == null
                            ? 'Location unavailable'
                            : 'Location connected',
                        _locationMessage ?? 'Sample schedule. Arrival checks update your connection options.',
                        _blue,
                        action: !_isLoadingLocation && _position == null
                            ? TextButton(
                                onPressed: _startGps,
                                child: const Text('Retry'),
                              )
                            : null,
                      )
                    else
                      _notice(
                        _isComplete
                            ? 'You have arrived'
                            : _isPlaying
                            ? 'Journey advancing automatically'
                            : 'Demo paused',
                        'Simulated position and schedules',
                        _blue,
                      ),
                    const SizedBox(height: 20),
                    _surface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeading(
                            'Current plan',
                            _isComplete
                                ? 'Arrived'
                                : currentPlan == null
                                ? 'Unavailable'
                                : currentId == _confirmedRouteId &&
                                      currentId != null
                                ? 'Confirmed'
                                : currentId == 'route-opt-1'
                                ? 'Active route'
                                : 'Recovery suggested',
                            _blue,
                          ),
                          const SizedBox(height: 14),
                          if (currentPlan != null && !_isComplete)
                            _currentTransport(currentPlan),
                          const SizedBox(height: 12),
                          _mapPreview(),
                          const SizedBox(height: 20),
                          RecoveryRouteTree(
                            key: const ValueKey('current-plan-tree'),
                            section: RecoveryRouteSection.current,
                            currentRouteId: currentId,
                            routes: routes,
                            recommendedId: primary,
                            selectedId: currentId,
                            branchAtB: branchAtB,
                            arrived: _arrived,
                            complete: _isComplete,
                            routeActionBuilder: _routeAction,
                            onSelected: (_) {},
                          ),
                        ],
                      ),
                    ),
                    if (!_isComplete) ...[
                      const SizedBox(height: 20),
                      _surface(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeading(
                              'Backup plans',
                              '${backups.length} available',
                              const Color(0xFF9A3412),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Alternative connections if your current plan changes.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: _muted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            RecoveryRouteTree(
                              key: const ValueKey('backup-plans-tree'),
                              section: RecoveryRouteSection.backups,
                              currentRouteId: currentId,
                              routes: routes,
                              recommendedId: primary,
                              selectedId: _selectedRouteId,
                              branchAtB: branchAtB,
                              arrived: _arrived,
                              complete: false,
                              routeActionBuilder: _routeAction,
                              onSelected: (id) => setState(
                                () => _selectedRouteId = _selectedRouteId == id
                                    ? null
                                    : id,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (history.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Material(
                        color: Colors.transparent,
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          leading: const Icon(
                            Icons.history,
                            size: 20,
                            color: _muted,
                          ),
                          title: Text(
                            'Missed connections · ${history.length}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: _muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          children: [
                            for (final route in history)
                              ListTile(
                                title: Text(
                                  'Plan ${route.id.split('-').last} · ${route.legs[branchAtB ? 2 : 1].departureTime} departure',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                subtitle: Text(
                                  route.feasibilityReason ??
                                      'Transfer window missed',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Text(
                      'Demo schedules and bookings. No live transport availability.',
                      style: TextStyle(fontSize: 11, color: _muted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeading(String title, String status, Color color) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 12,
    runSpacing: 8,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: _navy,
        ),
      ),
      _badge(status, color),
    ],
  );

  Widget _currentTransport(RoutePossibility route) {
    final reached = <String>{
      if (_arrived.contains('cp-a') || _arrived.contains('cp-b'))
        'Checkpoint A',
      if (_arrived.contains('cp-b')) 'Checkpoint B',
      if (_isComplete) 'Jodhpur',
    };
    final leg = route.legs.firstWhere(
      (leg) => !reached.contains(leg.to),
      orElse: () => route.legs.last,
    );
    final mode = switch (leg.mode) {
      'flight' => 'Flight',
      'volvo-bus' || 'bus' => 'Coach',
      'express-cab' || 'cab' => 'Cab',
      _ => 'Train',
    };
    final placeFrom = leg.from == 'Checkpoint A'
        ? 'Jaipur'
        : leg.from == 'Checkpoint B'
        ? 'Ajmer'
        : leg.from;
    final placeTo = leg.to == 'Checkpoint A'
        ? 'Jaipur'
        : leg.to == 'Checkpoint B'
        ? 'Ajmer'
        : leg.to;
    return Container(
      key: const ValueKey('current-transport'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                mode == 'Train'
                    ? Icons.train_outlined
                    : mode == 'Flight'
                    ? Icons.flight_outlined
                    : mode == 'Coach'
                    ? Icons.directions_bus_outlined
                    : Icons.local_taxi_outlined,
                size: 19,
                color: _blue,
              ),
              Text(
                '$mode · $placeFrom → $placeTo',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${leg.provider} · ${leg.serviceNumber}',
            style: const TextStyle(fontSize: 12, color: _muted, height: 1.4),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 32,
            runSpacing: 8,
            children: [
              _transportTime('Departure', leg.departureTime),
              _transportTime('Arrival', leg.arrivalTime),
            ],
          ),
        ],
      ),
    );
  }

  Widget _transportTime(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 11, color: _muted)),
      const SizedBox(height: 3),
      Text(
        value,
        style: const TextStyle(
          fontSize: 19,
          color: _navy,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );

  Widget _mapPreview() {
    final point = _position == null
        ? _routePoints.first
        : LatLng(_position!.latitude, _position!.longitude);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Journey map',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _navy,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _showMap,
              icon: const Icon(Icons.open_in_full, size: 15),
              label: const Text('Expand map'),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: RecoveryJourneyMap(
              key: const ValueKey('current-plan-map'),
              latitude: point.latitude,
              longitude: point.longitude,
              isLive: _isLive,
              loadTiles: widget.loadMapTiles,
              showUserLocation: _position != null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _demoProgress(RoutePossibility? route) {
    final end = route == null
        ? 1215
        : timeToMinutes(route.estimatedArrivalTime);
    final progress = _isComplete
        ? 1.0
        : ((_demoMinutes - 480) / (end - 480)).clamp(0.0, 1.0);
    final completed = [
      'cp-a',
      'cp-b',
      'cp-jodhpur',
    ].where(_arrived.contains).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'Simulated journey progress',
          value: '${(progress * 100).round()} percent',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              color: _blue,
              backgroundColor: const Color(0xFFE2E8F0),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '15 min per second · $completed/3 stops reached',
          style: const TextStyle(fontSize: 11, color: _muted),
        ),
      ],
    );
  }

  Widget _playbackBar() => Wrap(
    spacing: 8,
    runSpacing: 8,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      if (_isLive)
        FilledButton.icon(
          onPressed: _playDemo,
          icon: const Icon(Icons.play_arrow_rounded, size: 20),
          label: const Text('Play demo journey'),
        )
      else ...[
        FilledButton.icon(
          onPressed: _isPlaying ? _pauseDemo : _playDemo,
          icon: Icon(
            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 20,
          ),
          label: Text(
            _isPlaying
                ? 'Pause'
                : _isComplete
                ? 'Replay demo journey'
                : 'Resume demo journey',
          ),
        ),
        Text(
          'Demo clock · ${_clockLabel(_demoMinutes)}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _navy,
          ),
        ),
      ],
      OutlinedButton.icon(
        onPressed: _showScenarios,
        icon: const Icon(Icons.tune_rounded, size: 18),
        label: const Text('Scenarios'),
        style: OutlinedButton.styleFrom(
          foregroundColor: _muted,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      if (!_isLive)
        IconButton(
          onPressed: _resetDemo,
          tooltip: 'Reset',
          icon: const Icon(Icons.restart_alt, color: _muted),
        ),
    ],
  );

  Widget _routeAction(RoutePossibility route) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _canBook(route) ? () => _confirmRoute(route) : null,
          icon: Icon(
            _confirmedRouteId == route.id
                ? Icons.check_rounded
                : Icons.confirmation_number_outlined,
            size: 18,
          ),
          label: Text(
            _confirmedRouteId == route.id
                ? 'Route confirmed'
                : route.id == 'route-opt-1'
                ? 'Review booking'
                : 'Review recovery booking',
          ),
          style: FilledButton.styleFrom(
            backgroundColor: _orange,
            foregroundColor: _navy,
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      if (_isLive && _arrived.isEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Schedule preview. Confirm arrival to check this connection.',
            style: TextStyle(fontSize: 12, color: _muted),
          ),
        ),
    ],
  );

  Future<void> _showMap() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.82,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ValueListenableBuilder<int>(
              valueListenable: _mapRevision,
              builder: (context, revision, child) {
                final point = _position == null
                    ? _routePoints.first
                    : LatLng(_position!.latitude, _position!.longitude);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Journey map',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _navy,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close map',
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: RecoveryJourneyMap(
                        key: const ValueKey('full-journey-map'),
                        latitude: point.latitude,
                        longitude: point.longitude,
                        isLive: _isLive,
                        loadTiles: widget.loadMapTiles,
                        showUserLocation: _position != null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isLive
                          ? _position == null
                                ? 'Waiting for a GPS fix'
                                : 'GPS accuracy: ${_position!.accuracy.round()} m'
                          : 'Demo clock: ${_clockLabel(_demoMinutes)} - simulated tracking',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 13,
                        color: _muted,
                      ),
                    ),
                    if (_isLive && !_isComplete) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          _manualArrival();
                          _mapRevision.value++;
                        },
                        icon: const Icon(Icons.flag_outlined),
                        label: const Text('Confirm arrival'),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showScenarios() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Demo controls',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Playback tracks the journey automatically. Use a scenario to jump to a connection change.',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 13,
                    color: _muted,
                  ),
                ),
                const SizedBox(height: 16),
                for (final scenario in <(String, String, int)>[
                  ('On time', 'cp-a', 0),
                  ('Late at A · +45m', 'cp-a', 45),
                  ('Severe · +90m', 'cp-a', 90),
                  ('Late at B · +50m', 'cp-b', 50),
                  ('All missed · +140m', 'cp-a', 140),
                ])
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      scenario.$3 == 0
                          ? Icons.check_circle_outline
                          : Icons.alt_route_rounded,
                      color: scenario.$3 == 0 ? _blue : _orange,
                    ),
                    title: Text(
                      scenario.$1,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: _muted),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _setScenario(scenario.$2, scenario.$3);
                    },
                  ),
                if (!_isLive) ...[
                  const Divider(height: 24),
                  OutlinedButton.icon(
                    onPressed: _isComplete
                        ? null
                        : () {
                            Navigator.pop(sheetContext);
                            _addDelay();
                          },
                    icon: const Icon(Icons.more_time),
                    label: const Text('+15 min delay'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _startGps();
                    },
                    icon: const Icon(Icons.gps_fixed),
                    label: const Text('Use my location'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _notice(String title, String message, Color color, {Widget? action}) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),
            ?action,
          ],
        ),
      );

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        color: color == _blue ? _navy : color,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _surface({required Widget child, double padding = 16}) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: EdgeInsets.all(padding), child: child),
  );

  bool _canBook(RoutePossibility route) =>
      route.isFeasible &&
      _confirmedRouteId != route.id &&
      !_isComplete &&
      !_isOutsideCorridor &&
      (!_isLive || _arrived.isNotEmpty);

  Future<void> _confirmRoute(RoutePossibility route) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm your route'),
        content: Text(
          'Plan ${route.id.split('-').last} arrives in Jodhpur at ${route.estimatedArrivalTime}.\nTotal ₹${route.totalCost}.\n\nThis creates a simulated booking in your trip kit.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm route'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted || !_canBook(route)) return;
    setState(() {
      _confirmedRouteId = route.id;
      _journeyRoute = route;
      _selectedRouteId = null;
      if (!_isLive && !_arrived.contains('cp-b')) {
        _demoPreferredOriginId = route.id;
      }
    });
    widget.onRebooked?.call(route);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Route confirmed. Demo voucher added to your trip kit.'),
      ),
    );
  }
}
