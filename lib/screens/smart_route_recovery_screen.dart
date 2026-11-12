import 'package:flutter/material.dart';
import '../models/travel_models.dart';
import '../services/route_recovery_engine.dart';

class SmartRouteRecoveryScreen extends StatefulWidget {
  final Function(RoutePossibility)? onRebooked;

  const SmartRouteRecoveryScreen({super.key, this.onRebooked});

  @override
  State<SmartRouteRecoveryScreen> createState() => _SmartRouteRecoveryScreenState();
}

class _SmartRouteRecoveryScreenState extends State<SmartRouteRecoveryScreen> {
  String _selectedCheckpointId = 'cp-a';
  int _delayMinutes = 45; // Default to showcase Scenario 2!
  RoutePossibility? _rebookingTarget;

  @override
  Widget build(BuildContext context) {
    final result = RouteRecoveryEngine.recalculate(
      activeCheckpointId: _selectedCheckpointId,
      delayMinutes: _delayMinutes,
    );

    final checkpoints = result['checkpoints'] as List<CheckpointStatus>;
    final routes = result['routes'] as List<RoutePossibility>;
    final alertMessage = result['alertMessage'] as String;
    final alertSeverity = result['alertSeverity'] as String;
    final hasMissed = result['hasMissedConnection'] as bool;

    final targetCheckpoint = checkpoints.firstWhere((c) => c.id == _selectedCheckpointId, orElse: () => checkpoints[1]);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF1E1B4B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF97316).withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, color: Color(0xFFF97316), size: 14),
                        SizedBox(width: 4),
                        Text('AUTONOMOUS ROUTE FEASIBILITY ENGINE',
                            style: TextStyle(color: Color(0xFFFED7AA), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Smart Route Recovery',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Multi-checkpoint transit monitoring for Home → Checkpoint A (Jaipur) → Checkpoint B (Ajmer) → Jodhpur. Evaluates actual arrival against carrier connection deadlines.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Live Alert Box
            if (alertMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: alertSeverity == 'danger'
                      ? const Color(0xFFFFF1F2)
                      : alertSeverity == 'warning'
                          ? const Color(0xFFFFFBEB)
                          : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: alertSeverity == 'danger'
                        ? const Color(0xFFFDA4AF)
                        : alertSeverity == 'warning'
                            ? const Color(0xFFFCD34D)
                            : const Color(0xFF86EFAC),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      hasMissed ? Icons.error : Icons.check_circle,
                      color: alertSeverity == 'danger'
                          ? Colors.red.shade700
                          : alertSeverity == 'warning'
                              ? Colors.amber.shade800
                              : Colors.green.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasMissed ? 'MISSED CONNECTION DETECTED' : 'FEASIBILITY SECURE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: alertSeverity == 'danger'
                                  ? Colors.red.shade900
                                  : alertSeverity == 'warning'
                                      ? Colors.amber.shade900
                                      : Colors.green.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alertMessage,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: alertSeverity == 'danger'
                                  ? Colors.red.shade800
                                  : alertSeverity == 'warning'
                                      ? Colors.amber.shade900
                                      : Colors.green.shade900,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Interactive Simulator Controls
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune, color: Color(0xFF147FE8), size: 18),
                      SizedBox(width: 8),
                      Text('Interactive Checkpoint & Delay Simulator',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Quick Scenario Buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildScenarioChip('Scenario 1: On-Time at A', _delayMinutes == 0 && _selectedCheckpointId == 'cp-a', () {
                        setState(() {
                          _selectedCheckpointId = 'cp-a';
                          _delayMinutes = 0;
                        });
                      }),
                      _buildScenarioChip('Scenario 2: +45m Late at A (Misses B)', _delayMinutes == 45 && _selectedCheckpointId == 'cp-a', () {
                        setState(() {
                          _selectedCheckpointId = 'cp-a';
                          _delayMinutes = 45;
                        });
                      }),
                      _buildScenarioChip('Scenario 3: Severe +110m at A', _delayMinutes == 110 && _selectedCheckpointId == 'cp-a', () {
                        setState(() {
                          _selectedCheckpointId = 'cp-a';
                          _delayMinutes = 110;
                        });
                      }),
                      _buildScenarioChip('Scenario 4: Late at B (+50m)', _delayMinutes == 50 && _selectedCheckpointId == 'cp-b', () {
                        setState(() {
                          _selectedCheckpointId = 'cp-b';
                          _delayMinutes = 50;
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Checkpoint dropdown & Slider
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ACTIVE CHECKPOINT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              value: _selectedCheckpointId,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'cp-a', child: Text('Checkpoint A (Jaipur Jn)')),
                                DropdownMenuItem(value: 'cp-b', child: Text('Checkpoint B (Ajmer Terminal)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedCheckpointId = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('SIMULATED DELAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                Text('+${_delayMinutes}m',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _delayMinutes > 30 ? Colors.red.shade700 : const Color(0xFF147FE8))),
                              ],
                            ),
                            Slider(
                              value: _delayMinutes.toDouble(),
                              min: 0,
                              max: 140,
                              divisions: 28,
                              activeColor: _delayMinutes > 30 ? Colors.red : const Color(0xFF147FE8),
                              onChanged: (val) => setState(() => _delayMinutes = val.toInt()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Feasibility Math Readout
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Scheduled: ${targetCheckpoint.scheduledArrival}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                        Text('Actual Arrival: ${targetCheckpoint.actualArrival}',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _delayMinutes > 15 ? Colors.red.shade700 : const Color(0xFF0F172A))),
                        Text('Min Buffer Needed: ${targetCheckpoint.minTransferTimeMinutes}m',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF147FE8))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Checkpoints Stepper Cards
            const Text('CHECKPOINTS PROGRESS & TRANSFER GATES',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(0xFF64748B))),
            const SizedBox(height: 10),

            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: checkpoints.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, idx) {
                  final cp = checkpoints[idx];
                  final isTarget = cp.id == _selectedCheckpointId;
                  final isDelayed = isTarget && _delayMinutes > 15;

                  return Container(
                    width: 180,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isTarget ? (isDelayed ? const Color(0xFFFFF1F2) : const Color(0xFFEFF6FF)) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isTarget ? (isDelayed ? Colors.red.shade300 : const Color(0xFF3B82F6)) : const Color(0xFFE2E8F0),
                        width: isTarget ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Step ${idx + 1}',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDelayed ? Colors.red.shade100 : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isDelayed ? '+${_delayMinutes}m' : 'On-Time',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isDelayed ? Colors.red.shade800 : Colors.green.shade800),
                              ),
                            ),
                          ],
                        ),
                        Text(cp.name,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sched: ${cp.scheduledArrival}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                            Text('Min: ${cp.minTransferTimeMinutes}m', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Journey Options List
            const Text('JOURNEY POSSIBILITIES & RECOVERY ROUTES',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(0xFF64748B))),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: routes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, idx) {
                final route = routes[idx];
                final isFeasible = route.isFeasible;
                final isPrimary = route.isPrimary;

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: !isFeasible
                        ? const Color(0xFFFEF2F2).withOpacity(0.6)
                        : isPrimary
                            ? Colors.white
                            : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: !isFeasible
                          ? Colors.red.shade200
                          : isPrimary
                              ? const Color(0xFF147FE8)
                              : const Color(0xFFE2E8F0),
                      width: isPrimary ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Route Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        route.name,
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (isPrimary && isFeasible)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(12)),
                                        child: const Text('RECOMMENDED',
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                                      ),
                                    if (!isFeasible)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
                                        child: const Text('MISSED CONNECTION',
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(route.pathDescription, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('₹${route.totalCost}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                              Text('ETA: ${route.estimatedArrivalTime}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF147FE8))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Feasibility Note
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: !isFeasible
                              ? Colors.red.shade50
                              : isPrimary
                                  ? const Color(0xFFF0FDF4)
                                  : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          route.feasibilityReason ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: !isFeasible
                                ? Colors.red.shade800
                                : isPrimary
                                    ? Colors.green.shade900
                                    : const Color(0xFF334155),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Route Legs
                      Row(
                        children: route.legs.map((leg) {
                          final isCancelled = leg.bookingStatus == 'cancelled';
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isCancelled ? Colors.red.shade50 : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: isCancelled ? Border.all(color: Colors.red.shade200) : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(leg.mode.toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: isCancelled ? Colors.red : const Color(0xFF147FE8))),
                                      Text('₹${leg.cost}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text('${leg.from} → ${leg.to}',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          decoration: isCancelled ? TextDecoration.lineThrough : null),
                                      maxLines: 1),
                                  Text('${leg.departureTime} - ${leg.arrivalTime}',
                                      style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),

                      // Action Button
                      if (isFeasible)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPrimary ? const Color(0xFF147FE8) : const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleApp(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            icon: const Icon(Icons.sync, size: 16),
                            label: Text(isPrimary ? 'Manage Confirmed Route' : 'Switch & Re-book Alternative',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              _showRebookConfirmation(context, route);
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  void _showRebookConfirmation(BuildContext context, RoutePossibility route) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleApp(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.bolt, color: Color(0xFF147FE8)),
            SizedBox(width: 8),
            Text('Confirm Route Recovery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are confirming autonomous re-routing to:\n${route.name}',
                style: const TextStyle(fontSize: 13, height: 1.4)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('New Jodhpur ETA:', style: TextStyle(fontSize: 12)),
                    Text(route.estimatedArrivalTime, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total Route Cost:', style: TextStyle(fontSize: 12)),
                    Text('₹${route.totalCost}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ]),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF147FE8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleApp(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onRebooked?.call(route);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF0F172A),
                  content: Text('Route confirmed: ${route.name}. Digital vouchers issued!'),
                ),
              );
            },
            child: const Text('Confirm & Issue Vouchers'),
          ),
        ],
      ),
    );
  }
}

// Helper RoundedRectangleApp fallback for shape
ShapeBorder RoundedRectangleApp({required BorderRadius borderRadius}) {
  return RoundedRectangleBorder(borderRadius: borderRadius);
}
