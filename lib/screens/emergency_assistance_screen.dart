import 'package:flutter/material.dart';
import '../services/mock_data_service.dart';

class EmergencyAssistanceScreen extends StatefulWidget {
  const EmergencyAssistanceScreen({super.key});

  @override
  State<EmergencyAssistanceScreen> createState() => _EmergencyAssistanceScreenState();
}

class _EmergencyAssistanceScreenState extends State<EmergencyAssistanceScreen> {
  bool _sosActive = false;
  int _countdown = 5;

  void _triggerSos() {
    setState(() {
      _sosActive = true;
      _countdown = 5;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_sosActive) return false;
      setState(() => _countdown -= 1);
      return _countdown > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final contacts = MockDataService.getEmergencyContacts();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SOS Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF881337), Color(0xFF4C0519), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Emergency SOS & Assistance',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Direct satellite dispatch to 112 police and AIIMS trauma emergency wards.',
                      style: TextStyle(color: Color(0xFFFECDD3), fontSize: 12)),
                  const SizedBox(height: 16),
                  if (_sosActive)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.red.shade900, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('BROADCASTING IN ${_countdown}s · 112 ALERT',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          TextButton(
                            style: TextButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red.shade900),
                            onPressed: () => setState(() => _sosActive = false),
                            child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE11D48),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _triggerSos,
                      icon: const Icon(Icons.warning, size: 18),
                      label: const Text('ACTIVATE SOS ALERT', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Speed Dials
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('112', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                        Text('Police & SOS', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('108', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                        Text('Ambulance Trauma', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1363', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF147FE8))),
                        Text('Tourist Helpline', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Verified Contacts List
            const Text('LOCAL EMERGENCY FACILITIES (JODHPUR)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(0xFF64748B))),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: contacts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final c = contacts[idx];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('${c.address} · ${c.distance}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          const SizedBox(height: 4),
                          Text(c.openHours, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Simulated Call dispatched to: ${c.phone}')),
                          );
                        },
                        icon: const Icon(Icons.phone, size: 14),
                        label: const Text('Call', style: TextStyle(fontSize: 11)),
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
}
