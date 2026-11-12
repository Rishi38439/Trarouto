// Keep Material types compatible with the app shell.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../models/travel_models.dart';

const _blue = Color(0xFF147FE8);
const _orange = Color(0xFFF97316);
const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);

enum RecoveryRouteSection { all, current, backups }

/// A shared vertical timeline with connected recovery branches. Completed stops
/// and legs leave the active timeline; the current and future journey remain.
class RecoveryRouteTree extends StatelessWidget {
  const RecoveryRouteTree({
    super.key,
    required this.routes,
    required this.recommendedId,
    required this.selectedId,
    required this.branchAtB,
    required this.arrived,
    required this.complete,
    required this.onSelected,
    this.routeActionBuilder,
    this.section = RecoveryRouteSection.all,
    this.currentRouteId,
  });

  final List<RoutePossibility> routes;
  final String? recommendedId;
  final String? selectedId;
  final bool branchAtB;
  final Set<String> arrived;
  final bool complete;
  final ValueChanged<String> onSelected;
  final Widget Function(RoutePossibility)? routeActionBuilder;
  final RecoveryRouteSection section;
  final String? currentRouteId;

  @override
  Widget build(BuildContext context) {
    if (complete) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, color: _blue, size: 40),
            SizedBox(height: 12),
            Text(
              'You have arrived in Jodhpur',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: _ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text('Your journey is complete.', style: TextStyle(color: _muted)),
          ],
        ),
      );
    }
    final available = routes.where((r) => r.isFeasible).toList();
    final first = routes.first;
    final stops = <(String, String, String)>[
      ('cp-home', 'Home', '08:00'),
      ('cp-a', 'Checkpoint A · Jaipur', first.legs.first.arrivalTime),
      if (branchAtB)
        ('cp-b', 'Checkpoint B · Ajmer', first.legs[1].arrivalTime),
    ].where((stop) => !_hasVisited(stop.$1)).toList();
    final currentId = currentRouteId ?? recommendedId;
    final ordered =
        <RoutePossibility>[
              ...available.where((r) => r.id == recommendedId),
              ...available.where((r) => r.id != recommendedId),
            ]
            .where(
              (route) => switch (section) {
                RecoveryRouteSection.current => route.id == currentId,
                RecoveryRouteSection.backups => route.id != currentId,
                RecoveryRouteSection.all => true,
              },
            )
            .toList();
    return Semantics(
      container: true,
      label: 'Active journey timeline with recovery branches',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section != RecoveryRouteSection.backups)
            for (final stop in stops) _stop(stop.$1, stop.$2, stop.$3),
          if (ordered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                section == RecoveryRouteSection.backups
                    ? 'No backup connections are available.'
                    : 'No feasible connection remains.',
                style: const TextStyle(color: _muted),
              ),
            ),
          for (final route in ordered) _branch(context, route),
          if (section != RecoveryRouteSection.backups &&
              ordered.isNotEmpty &&
              !_hasVisited('cp-jodhpur'))
            _stop('cp-jodhpur', 'Jodhpur', 'Destination', last: true),
        ],
      ),
    );
  }

  Widget _stop(String id, String name, String time, {bool last = false}) =>
      IntrinsicHeight(
        key: ValueKey('checkpoint-$id'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 28,
              child: Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.circle, color: _blue, size: 8),
                  ),
                  if (!last)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 2, bottom: last ? 0 : 28),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _branch(BuildContext context, RoutePossibility route) {
    final best =
        section == RecoveryRouteSection.current ||
        (section == RecoveryRouteSection.all && route.id == recommendedId);
    final selected = route.id == selectedId;
    final color = best ? _blue : _orange;
    final legs = route.legs.skip(1).where((leg) {
      if (_hasVisited('cp-b') && leg.to == 'Checkpoint B') return false;
      return !(_hasVisited('cp-jodhpur') && leg.to == 'Jodhpur');
    }).toList();
    final expanded = best || selected;
    final original = routes.firstWhere(
      (r) => r.id == 'route-opt-1',
      orElse: () => routes.first,
    );
    final arrivalDifference =
        _minutes(route.estimatedArrivalTime) -
        _minutes(original.estimatedArrivalTime);
    final costDifference = route.totalCost - original.totalCost;
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.only(left: 14),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: color.withValues(alpha: 0.3), width: 2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              button: true,
              selected: selected,
              hint: best
                  ? 'Recommended connection'
                  : expanded
                  ? 'Tap to collapse connections'
                  : 'Tap to expand connections',
              child: Material(
                color: best ? const Color(0xFFF8FAFC) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: best
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  key: ValueKey('route-branch-${route.id}'),
                  onTap: () => onSelected(route.id),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(
                              best
                                  ? Icons.verified_outlined
                                  : Icons.alt_route_rounded,
                              size: 17,
                              color: best ? _blue : const Color(0xFF9A3412),
                            ),
                            Text(
                              best
                                  ? section == RecoveryRouteSection.current
                                        ? 'Current connections'
                                        : 'Recommended recovery'
                                  : 'Backup branch',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _muted,
                              ),
                            ),
                            if (selected && !best)
                              _pill('Selected backup', const Color(0xFF9A3412)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          route.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 26,
                          runSpacing: 12,
                          children: [
                            _metric(
                              'ARRIVE JODHPUR',
                              route.estimatedArrivalTime,
                            ),
                            _metric('TOTAL FARE', '₹${route.totalCost}'),
                          ],
                        ),
                        if (route.id != original.id) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _pill(
                                '${arrivalDifference >= 0 ? '+' : '−'}${_duration(arrivalDifference.abs())} vs original',
                                _muted,
                              ),
                              _pill(
                                '${costDifference >= 0 ? '+' : '−'}₹${costDifference.abs()} vs original',
                                _muted,
                              ),
                            ],
                          ),
                        ],
                        if (!best) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  expanded
                                      ? 'Hide connections'
                                      : 'View connections',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _muted,
                                  ),
                                ),
                              ),
                              Icon(
                                expanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                size: 20,
                                color: _muted,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (expanded) ...[
              const SizedBox(height: 16),
              for (var i = 0; i < legs.length; i++) ...[
                _leg(legs[i], route.id),
                if (i < legs.length - 1)
                  _transfer(
                    _place(legs[i].to),
                    _minutes(legs[i + 1].departureTime) -
                        _minutes(legs[i].arrivalTime),
                    25,
                  ),
              ],
              if (routeActionBuilder != null) ...[
                const SizedBox(height: 4),
                routeActionBuilder!(route),
              ],
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _leg(JourneyLeg leg, String routeId) => Padding(
    key: ValueKey(
      'upcoming-${leg.to == 'Checkpoint B' ? 'cp-b' : 'cp-jodhpur'}-$routeId',
    ),
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_modeIcon(leg.mode), color: _blue, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_place(leg.from)} → ${_place(leg.to)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: _ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${leg.provider} · ${leg.serviceNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: _muted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 20,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _time('DEPART', leg.departureTime),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.east_rounded, color: _muted, size: 18),
                  Text(
                    _duration(leg.durationMinutes),
                    style: const TextStyle(fontSize: 11, color: _muted),
                  ),
                ],
              ),
              _time('ARRIVE', leg.arrivalTime),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _transfer(String city, int wait, int minimum) {
    final spare = wait - minimum;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.swap_vert_rounded,
            color: Color(0xFF92400E),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$wait min transfer in $city',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF78350F),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$minimum min minimum · ${spare > 0
                      ? '$spare min spare'
                      : spare == 0
                      ? 'No spare time'
                      : 'Insufficient transfer time'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF78350F),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
    ),
  );

  Widget _metric(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: _muted,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: _ink,
        ),
      ),
    ],
  );

  Widget _time(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: _muted,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _ink,
        ),
      ),
    ],
  );

  IconData _modeIcon(String mode) => switch (mode) {
    'flight' => Icons.flight_outlined,
    'volvo-bus' || 'bus' => Icons.directions_bus_outlined,
    'express-cab' || 'cab' => Icons.local_taxi_outlined,
    _ => Icons.train_outlined,
  };
  int _minutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String _duration(int minutes) =>
      minutes < 60 ? '$minutes min' : '${minutes ~/ 60}h ${minutes % 60}m';

  bool _hasVisited(String id) {
    final reachedDestination = arrived.contains('cp-jodhpur');
    final reachedB = arrived.contains('cp-b') || reachedDestination;
    final reachedA = arrived.contains('cp-a') || reachedB;
    return switch (id) {
      'cp-home' => arrived.contains('cp-home') || reachedA,
      'cp-a' => reachedA,
      'cp-b' => reachedB,
      'cp-jodhpur' => reachedDestination,
      _ => false,
    };
  }

  String _place(String value) => switch (value) {
    'Checkpoint A' => 'Jaipur',
    'Checkpoint B' => 'Ajmer',
    _ => value,
  };
}
