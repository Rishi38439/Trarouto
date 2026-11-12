import 'package:flutter/material.dart';
import '../models/travel_models.dart';
import '../services/mock_data_service.dart';

class AiTripPlannerScreen extends StatefulWidget {
  final Function(Itinerary) onSaveOffline;

  const AiTripPlannerScreen({super.key, required this.onSaveOffline});

  @override
  State<AiTripPlannerScreen> createState() => _AiTripPlannerScreenState();
}

class _AiTripPlannerScreenState extends State<AiTripPlannerScreen> {
  final TextEditingController _promptController = TextEditingController(
    text: 'I want to visit Italy for 5 nights with a moderate budget. I like historical places, underrated destinations, and local food.',
  );

  String _startLocation = 'Milan';
  String _destination = 'Italy (Florence & Bologna)';
  int _travellers = 2;
  int _nights = 5;
  String _budgetTier = 'moderate';
  final Set<String> _selectedInterests = {'historical', 'food', 'culture', 'offbeat'};

  bool _isGenerating = false;
  Itinerary? _generatedItinerary;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _generatedItinerary = MockDataService.getDefaultItinerary();
  }

  void _generateItinerary() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(milliseconds: 900));

    final itin = Itinerary(
      id: 'itin-${DateTime.now().millisecondsSinceEpoch}',
      title: '$_nights-Day ${_destination.split('(')[0].trim()} Tailored Odyssey',
      destination: _destination,
      startLocation: _startLocation,
      startDate: '2026-05-15',
      endDate: '2026-05-20',
      durationDays: _nights + 1,
      durationNights: _nights,
      travellers: _travellers,
      budgetTier: _budgetTier,
      tags: [_budgetTier.toUpperCase(), 'AI GENERATED', ..._selectedInterests.take(2).map((i) => i.toUpperCase())],
      summary: 'Personalized itinerary customized for $_travellers traveler(s) emphasizing ${_selectedInterests.join(', ')}.',
      heroImage: _destination.toLowerCase().contains('italy')
          ? 'https://images.unsplash.com/photo-1516483638261-f4dbaf036963?auto=format&fit=crop&w=1200&q=80'
          : 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?auto=format&fit=crop&w=1200&q=80',
      days: [
        DayPlan(
          dayNumber: 1,
          date: 'Day 1',
          title: 'Arrival & Renaissance Architecture',
          theme: 'Arrival & Strolls',
          description: 'Settle into boutique hotel, take orientation walking tour of cathedral squares and local enotecas.',
          breakfast: 'Artisanal espresso & cornetto at local bar',
          lunch: 'Handmade tagliatelle al ragù',
          dinner: 'Farm-to-table Tuscan steak with Chianti wine',
          activities: [
            Activity(
              id: 'a1',
              time: '10:00 AM',
              title: 'Historical Centro Walking Tour',
              location: 'Piazza del Duomo',
              description: 'Guided architectural overview of renaissance landmarks and hidden courtyards.',
              category: 'historical',
              cost: 35,
              duration: '2.5 hrs',
            ),
            Activity(
              id: 'a2',
              time: '03:00 PM',
              title: 'Artisan Workshop & Leather Guild',
              location: 'Santa Croce District',
              description: 'Meet 4th-generation guild crafters and view traditional leather finishing.',
              category: 'culture',
              cost: 20,
              duration: '1.5 hrs',
            ),
          ],
        ),
        DayPlan(
          dayNumber: 2,
          date: 'Day 2',
          title: 'Gastronomy & Underrated Hillside Views',
          theme: 'Culinary Secrets',
          description: 'Explore covered food markets, attend a pasta masterclass, and watch sunset over the river.',
          breakfast: 'Fresh ricotta pastries & cappuccino',
          lunch: 'Tasting menu at historic Mercato Centrale',
          dinner: 'Trattoria dining in quiet artisan quarter',
          activities: [
            Activity(
              id: 'a3',
              time: '09:30 AM',
              title: 'Market Tour & Pasta Masterclass',
              location: 'San Lorenzo Market',
              description: 'Select seasonal produce with chef followed by hands-on pasta preparation.',
              category: 'food',
              cost: 65,
              duration: '3 hrs',
            ),
          ],
        ),
      ],
      estimatedTotalCost: _budgetTier == 'luxury' ? 4200 : _budgetTier == 'budget' ? 1200 : 2100,
      currency: _destination.toLowerCase().contains('india') ? '₹' : '€',
      createdAt: 'Just Now',
    );

    setState(() {
      _generatedItinerary = itin;
      _selectedDayIndex = 0;
      _isGenerating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Conversational Prompt Box
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
                    children: [
                      Icon(Icons.auto_awesome, color: Color(0xFF147FE8), size: 20),
                      SizedBox(width: 8),
                      Text('Conversational AI Trip Planner',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Type your journey vision in natural language or customize the exact parameters below.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _promptController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'e.g. 5 nights in Italy with moderate budget, historical sites and food...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF147FE8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _isGenerating ? null : _generateItinerary,
                      icon: _isGenerating
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.auto_awesome, size: 16),
                      label: Text(_isGenerating ? 'Synthesizing Itinerary...' : 'Generate AI Itinerary',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Form Parameters
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
                  const Text('ITINERARY PARAMETERS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(0xFF64748B))),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _startLocation,
                          decoration: InputDecoration(
                            labelText: 'Starting Location',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            isDense: true,
                          ),
                          onChanged: (val) => _startLocation = val,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: _destination,
                          decoration: InputDecoration(
                            labelText: 'Destination',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            isDense: true,
                          ),
                          onChanged: (val) => _destination = val,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _budgetTier,
                          decoration: InputDecoration(
                            labelText: 'Budget Tier',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'budget', child: Text('Budget')),
                            DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                            DropdownMenuItem(value: 'luxury', child: Text('Luxury')),
                          ],
                          onChanged: (val) => setState(() => _budgetTier = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: '$_nights',
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Nights',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            isDense: true,
                          ),
                          onChanged: (val) => _nights = int.tryParse(val) ?? 5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('TRAVEL INTERESTS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInterestChip('Historical Places', 'historical'),
                      _buildInterestChip('Local Food & Wine', 'food'),
                      _buildInterestChip('Culture & Arts', 'culture'),
                      _buildInterestChip('Underrated / Offbeat', 'offbeat'),
                      _buildInterestChip('Nature & Scenery', 'nature'),
                      _buildInterestChip('Adventure', 'adventure'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Generated Itinerary Display
            if (_generatedItinerary != null) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Image
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(_generatedItinerary!.heroImage, fit: BoxFit.cover),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_generatedItinerary!.title,
                                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                      Text('${_generatedItinerary!.durationDays} Days · ${_generatedItinerary!.travellers} Travelers',
                                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF0F172A),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {
                                    widget.onSaveOffline(_generatedItinerary!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Itinerary saved to Offline Trip Kit!')),
                                    );
                                  },
                                  icon: const Icon(Icons.download, size: 16),
                                  label: const Text('Save Offline', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Day Tabs
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: _generatedItinerary!.days.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final day = entry.value;
                              final isSelected = idx == _selectedDayIndex;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text('Day ${day.dayNumber}'),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFF147FE8),
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : const Color(0xFF475569),
                                  ),
                                  onSelected: (_) => setState(() => _selectedDayIndex = idx),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),

                          // Day Content
                          Builder(builder: (context) {
                            final currentDay = _generatedItinerary!.days[_selectedDayIndex];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(currentDay.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(currentDay.description, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                const SizedBox(height: 14),

                                ...currentDay.activities.map((act) => Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                                            child: Text(act.time,
                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF147FE8))),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(act.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 2),
                                                Text(act.description, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                                const SizedBox(height: 4),
                                                Text(act.location,
                                                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic)),
                                              ],
                                            ),
                                          ),
                                          Text(act.cost == 0 ? 'Free' : '${_generatedItinerary!.currency}${act.cost}',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    )),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInterestChip(String label, String key) {
    final selected = _selectedInterests.contains(key);
    return FilterChip(
      label: Text(label),
      selected: selected,
      selectedColor: const Color(0xFFEFF6FF),
      checkmarkColor: const Color(0xFF147FE8),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: selected ? const Color(0xFF147FE8) : const Color(0xFF475569),
      ),
      onSelected: (val) {
        setState(() {
          if (val) {
            _selectedInterests.add(key);
          } else {
            _selectedInterests.remove(key);
          }
        });
      },
    );
  }
}
