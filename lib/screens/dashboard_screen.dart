import 'package:flutter/material.dart';
import '../models/travel_models.dart';
import '../services/mock_data_service.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;
  final Itinerary activeItinerary;

  const DashboardScreen({
    super.key,
    required this.onNavigateTab,
    required this.activeItinerary,
  });

  @override
  Widget build(BuildContext context) {
    final destinations = MockDataService.getDestinations();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 18, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('AERONOVA AI 2.0 · VIRTUAL TRAVEL AGENT',
                        style: TextStyle(color: Color(0xFFBAE6FD), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                  const SizedBox(height: 12),
                  const Text('Welcome back, Rishi',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  const Text(
                    'Your journey to Jodhpur, Rajasthan is currently active. Checkpoint A transfer windows are being monitored for delay buffers.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions Grid
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    title: 'Smart Route\nRecovery',
                    subtitle: 'Signature Engine',
                    icon: Icons.alt_route,
                    color: const Color(0xFFF97316),
                    onTap: () => onNavigateTab(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    context,
                    title: 'AI Trip\nPlanner',
                    subtitle: 'Conversational',
                    icon: Icons.auto_awesome,
                    color: const Color(0xFF147FE8),
                    onTap: () => onNavigateTab(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    context,
                    title: 'Offline\nTrip Kit',
                    subtitle: 'Cached Dossier',
                    icon: Icons.download_for_offline,
                    color: const Color(0xFF8B5CF6),
                    onTap: () => onNavigateTab(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Active Trip Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.near_me, color: Color(0xFF10B981), size: 18),
                          SizedBox(width: 8),
                          Text('ACTIVE CORRIDOR IN TRANSIT',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(0xFF0F172A))),
                        ],
                      ),
                      TextButton(
                        onPressed: () => onNavigateTab(1),
                        child: const Row(
                          children: [
                            Text('Route Guardian', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF147FE8))),
                            Icon(Icons.chevron_right, size: 16, color: Color(0xFF147FE8)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Text('Home → Checkpoint A (Jaipur) → Checkpoint B (Ajmer) → Jodhpur',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  const Text('Next Interchange: Checkpoint A (Jaipur Jn) at 11:45 AM • 45m Safe Buffer',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 16),

                  // Checkpoint Stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStepCircle('Home', '08:00', true),
                      Expanded(child: Container(height: 2, color: const Color(0xFF147FE8))),
                      _buildStepCircle('Point A', '11:45', true, isCurrent: true),
                      Expanded(child: Container(height: 2, color: const Color(0xFFE2E8F0))),
                      _buildStepCircle('Point B', '15:15', false),
                      Expanded(child: Container(height: 2, color: const Color(0xFFE2E8F0))),
                      _buildStepCircle('Jodhpur', '20:15', false),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Budget Overview
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: Color(0xFF10B981), size: 18),
                          SizedBox(width: 8),
                          Text('TRAVEL BUDGET OVERVIEW',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(0xFF0F172A))),
                        ],
                      ),
                      Text('₹14,800 of ₹24,500', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF147FE8))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const LinearProgressIndicator(
                      value: 0.60,
                      backgroundColor: Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Committed Expenses: ₹14,800', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      Text('Remaining Buffer: ₹9,700', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Featured Destinations
            const Text('TRENDING & UNDERRATED DESTINATIONS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(0xFF64748B))),
            const SizedBox(height: 12),

            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: destinations.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, idx) {
                  final dest = destinations[idx];
                  return Container(
                    width: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(dest.imageUrl, fit: BoxFit.cover),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: dest.category == 'hidden-gem' ? const Color(0xFFF59E0B) : const Color(0xFF147FE8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    dest.category == 'hidden-gem' ? 'HIDDEN GEM' : 'POPULAR',
                                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dest.name,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  maxLines: 1),
                              const SizedBox(height: 2),
                              Text('${dest.region}, ${dest.country}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                              const SizedBox(height: 4),
                              Text('~${dest.currency}${dest.averageDailyBudget}/day',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF147FE8))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), height: 1.2)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCircle(String label, String time, bool isDone, {bool isCurrent = false}) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCurrent ? const Color(0xFFF97316) : isDone ? const Color(0xFF147FE8) : const Color(0xFFE2E8F0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone && !isCurrent
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(label.substring(0, 1),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isCurrent ? Colors.white : const Color(0xFF475569))),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        Text(time, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
      ],
    );
  }
}
