import 'package:flutter/material.dart';
import '../models/travel_models.dart';
import '../services/mock_data_service.dart';

class DestinationDiscoveryScreen extends StatefulWidget {
  final Function(Destination) onAddDestination;

  const DestinationDiscoveryScreen({super.key, required this.onAddDestination});

  @override
  State<DestinationDiscoveryScreen> createState() => _DestinationDiscoveryScreenState();
}

class _DestinationDiscoveryScreenState extends State<DestinationDiscoveryScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final destinations = MockDataService.getDestinations().filter((d) {
      final matchesCategory = _selectedCategory == 'all' || d.category == _selectedCategory;
      final matchesQuery = d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.country.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Discover Popular & Hidden Gems',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('From royal fortress ramparts to remote desert oases and Italian hill cloisters.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildCatButton('All', 'all'),
                      const SizedBox(width: 8),
                      _buildCatButton('Popular Hotspots', 'popular'),
                      const SizedBox(width: 8),
                      _buildCatButton('Hidden Gems ✨', 'hidden-gem'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Grid
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: destinations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, idx) {
                final dest = destinations[idx];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(dest.imageUrl, fit: BoxFit.cover),
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: dest.category == 'hidden-gem' ? const Color(0xFFF59E0B) : const Color(0xFF147FE8),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(dest.category == 'hidden-gem' ? 'HIDDEN GEM' : 'POPULAR',
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              left: 12,
                              right: 12,
                              child: Text(dest.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)])),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dest.description, style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              children: dest.highlights
                                  .map((h) => Chip(
                                        label: Text(h, style: const TextStyle(fontSize: 10)),
                                        backgroundColor: const Color(0xFFF1F5F9),
                                        padding: EdgeInsets.zero,
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Avg ~${dest.currency}${dest.averageDailyBudget}/day',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF147FE8))),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {
                                    widget.onAddDestination(dest);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Added ${dest.name} to Itinerary Planner!')),
                                    );
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Add to Planner', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
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

  Widget _buildCatButton(String label, String key) {
    final selected = _selectedCategory == key;
    return InkWell(
      onTap: () => setState(() => _selectedCategory = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: selected ? const Color(0xFF0F172A) : Colors.white70)),
      ),
    );
  }
}

extension FilterExt<T> on List<T> {
  Iterable<T> filter(bool Function(T) test) sync* {
    for (final element in this) {
      if (test(element)) yield element;
    }
  }
}
