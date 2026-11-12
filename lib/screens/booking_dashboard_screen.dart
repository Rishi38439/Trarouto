import 'package:flutter/material.dart';
import '../models/travel_models.dart';
import '../services/mock_data_service.dart';

class BookingDashboardScreen extends StatefulWidget {
  final List<BookingItem> userBookings;
  final Function(BookingItem) onBookingCreated;

  const BookingDashboardScreen({
    super.key,
    required this.userBookings,
    required this.onBookingCreated,
  });

  @override
  State<BookingDashboardScreen> createState() => _BookingDashboardScreenState();
}

class _BookingDashboardScreenState extends State<BookingDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hotels = MockDataService.getHotels();
    final transports = MockDataService.getTransports();
    final trainsAndFlights = transports.where((t) => t.type == 'train' || t.type == 'flight').toList();
    final localRides = transports.where((t) => t.type == 'ola' || t.type == 'uber').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF064E3B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Travel Booking Dashboard',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        const Text('Simulate reservations for luxury stays, trains, flights, and Ola/Uber cabs.',
                            style: TextStyle(color: Color(0xFF6EE7B7), fontSize: 12)),
                        const SizedBox(height: 12),
                        Text('${widget.userBookings.length} Active Vouchers Issued',
                            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF147FE8),
                    unselectedLabelColor: const Color(0xFF64748B),
                    indicatorColor: const Color(0xFF147FE8),
                    tabs: const [
                      Tab(text: 'Hotels & Stays'),
                      Tab(text: 'Trains & Flights'),
                      Tab(text: 'Ola / Uber Cabs'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Hotels
            ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: hotels.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, idx) {
                final h = hotels[idx];
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
                        height: 140,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(h.imageUrl, fit: BoxFit.cover),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                                child: Text('★ ${h.rating}',
                                    style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(h.name,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      maxLines: 1),
                                ),
                                Text('${h.currency}${h.pricePerNight}',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF147FE8))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(h.distanceFromAttractions, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              children: h.facilities
                                  .map((f) => Chip(
                                        label: Text(f, style: const TextStyle(fontSize: 9)),
                                        padding: EdgeInsets.zero,
                                        backgroundColor: const Color(0xFFF1F5F9),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF147FE8),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {
                                  final booking = BookingItem(
                                    id: 'bk-${DateTime.now().millisecondsSinceEpoch}',
                                    type: 'hotel',
                                    title: '${h.name} (Deluxe Suite)',
                                    provider: h.name,
                                    referenceNumber: 'CONF-HTL-${DateTime.now().millisecondsSinceEpoch % 100000}',
                                    destination: h.city,
                                    price: h.pricePerNight * 2,
                                    currency: h.currency,
                                    status: 'confirmed',
                                    voucherNumber: 'VOUCHER-${DateTime.now().millisecondsSinceEpoch % 10000}',
                                    details: {'Address': h.address, 'Rooms': '1 Heritage Suite'},
                                  );
                                  widget.onBookingCreated(booking);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Reserved ${h.name}. Voucher saved to Offline Kit!')),
                                  );
                                },
                                child: const Text('Book Room', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Trains & Flights
            ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: trainsAndFlights.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final tr = trainsAndFlights[idx];
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
                          Text(tr.provider, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('${tr.from} → ${tr.to}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          const SizedBox(height: 4),
                          Text('${tr.departureTime} · ${tr.duration}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF147FE8))),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${tr.currency}${tr.price}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          const SizedBox(height: 6),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              final b = BookingItem(
                                id: 'bk-tr-${DateTime.now().millisecondsSinceEpoch}',
                                type: tr.type,
                                title: '${tr.provider} (${tr.from} → ${tr.to})',
                                provider: tr.provider,
                                referenceNumber: 'PNR-${DateTime.now().millisecondsSinceEpoch % 10000000}',
                                destination: tr.to,
                                price: tr.price,
                                currency: tr.currency,
                                status: 'confirmed',
                                voucherNumber: 'VOUCHER-${DateTime.now().millisecondsSinceEpoch % 10000}',
                                details: {'Departure': tr.departureTime, 'Route': tr.routeCode},
                              );
                              widget.onBookingCreated(b);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Booked ${tr.provider}!')),
                              );
                            },
                            child: const Text('Book Ticket', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            // Local Cabs
            ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: localRides.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final cab = localRides[idx];
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
                          Text(cab.provider, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('${cab.from} → ${cab.to}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          const SizedBox(height: 4),
                          Text('ETA: ${cab.departureTime} (${cab.vehicleType})',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${cab.currency}${cab.price}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          const SizedBox(height: 6),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Dispatched ${cab.provider}! Driver arriving in 3 mins.')),
                              );
                            },
                            child: const Text('Dispatch Ride', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
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
