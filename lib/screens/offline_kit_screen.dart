import 'package:flutter/material.dart';
import '../models/travel_models.dart';

class OfflineKitScreen extends StatefulWidget {
  final Itinerary activeItinerary;
  final List<BookingItem> bookings;
  final List<EmergencyContact> emergencyContacts;

  const OfflineKitScreen({
    super.key,
    required this.activeItinerary,
    required this.bookings,
    required this.emergencyContacts,
  });

  @override
  State<OfflineKitScreen> createState() => _OfflineKitScreenState();
}

class _OfflineKitScreenState extends State<OfflineKitScreen> {
  bool _isDownloading = false;

  void _downloadTrip() async {
    setState(() => _isDownloading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isDownloading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trip Kit Packaged & Verified for Offline Access!')),
    );
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
            // Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF312E81)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Offline Travel Kit',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade500.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade400),
                        ),
                        child: const Text('LOCAL STORAGE CACHE',
                            style: TextStyle(color: Color(0xFFFDE68A), fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Zero-connectivity access to boarding passes, hotel vouchers, and emergency contacts in remote areas.',
                      style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 12)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isDownloading ? null : _downloadTrip,
                    icon: _isDownloading
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.download, size: 16),
                    label: Text(_isDownloading ? 'Saving to Local Storage...' : 'Download Active Trip for Offline',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Cached Dossier Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('CACHED DIGITAL VOUCHERS',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(0xFF64748B))),
                Text('${widget.bookings.length} Passes Stored',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF147FE8))),
              ],
            ),
            const SizedBox(height: 12),

            // Vouchers List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final b = widget.bookings[idx];
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
                          Text(b.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('Ref: ${b.referenceNumber}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                          const SizedBox(height: 4),
                          Text('Voucher: ${b.voucherNumber}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF147FE8))),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(10)),
                        child: const Text('OFFLINE VALID',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Emergency Contacts in Offline Kit
            const Text('OFFLINE EMERGENCY DIRECTORY',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(0xFF64748B))),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.emergencyContacts.take(2).length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final c = widget.emergencyContacts[idx];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF9F1239))),
                          Text(c.phone, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF881337))),
                        ],
                      ),
                      const Icon(Icons.phone, size: 18, color: Color(0xFFE11D48)),
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
