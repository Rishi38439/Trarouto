import 'package:flutter/material.dart';
import 'models/travel_models.dart';
import 'services/mock_data_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/smart_route_recovery_screen.dart';
import 'screens/ai_trip_planner_screen.dart';
import 'screens/destination_discovery_screen.dart';
import 'screens/booking_dashboard_screen.dart';
import 'screens/offline_kit_screen.dart';
import 'screens/emergency_assistance_screen.dart';
import 'screens/translation_screen.dart';
import 'screens/scam_verification_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AeroNovaApp());
}

class AeroNovaApp extends StatelessWidget {
  const AeroNovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AeroNova AI — Virtual Travel Agent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF147FE8),
          primary: const Color(0xFF147FE8),
          secondary: const Color(0xFFF97316),
          surface: Colors.white,
          background: const Color(0xFFF8FAFC),
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
        ),
      ),
      home: const MainAppShell(),
    );
  }
}

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _currentTabIndex = 0;
  late Itinerary _activeItinerary;
  late List<BookingItem> _userBookings;
  late List<EmergencyContact> _emergencyContacts;

  @override
  void initState() {
    super.initState();
    _activeItinerary = MockDataService.getDefaultItinerary();
    _userBookings = MockDataService.getInitialBookings();
    _emergencyContacts = MockDataService.getEmergencyContacts();
  }

  void _onSaveOffline(Itinerary itin) {
    setState(() {
      _activeItinerary = itin;
      _activeItinerary.isSavedOffline = true;
    });
  }

  void _onBookingCreated(BookingItem item) {
    setState(() {
      _userBookings.insert(0, item);
    });
  }

  void _onRouteRebooked(RoutePossibility route) {
    setState(() {
      _userBookings.insert(
        0,
        BookingItem(
          id: 'bk-rec-${DateTime.now().millisecondsSinceEpoch}',
          type: 'train',
          title: 'Route Recovery: ${route.name}',
          provider: 'AeroNova Recovery Dispatch',
          referenceNumber: 'REC-${DateTime.now().millisecondsSinceEpoch % 100000}',
          destination: 'Jodhpur',
          price: route.totalCost,
          currency: '₹',
          status: 'confirmed',
          voucherNumber: 'VOUCHER-REC-9912',
          details: {'New ETA': route.estimatedArrivalTime, 'Route': route.pathDescription},
        ),
      );
    });
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return DashboardScreen(
          onNavigateTab: (tabIdx) => setState(() => _currentTabIndex = tabIdx),
          activeItinerary: _activeItinerary,
        );
      case 1:
        return SmartRouteRecoveryScreen(
          onRebooked: _onRouteRebooked,
        );
      case 2:
        return AiTripPlannerScreen(
          onSaveOffline: _onSaveOffline,
        );
      case 3:
        return DestinationDiscoveryScreen(
          onAddDestination: (dest) {
            setState(() => _currentTabIndex = 2);
          },
        );
      case 4:
        return OfflineKitScreen(
          activeItinerary: _activeItinerary,
          bookings: _userBookings,
          emergencyContacts: _emergencyContacts,
        );
      case 5:
        return BookingDashboardScreen(
          userBookings: _userBookings,
          onBookingCreated: _onBookingCreated,
        );
      case 6:
        return const EmergencyAssistanceScreen();
      case 7:
        return const TranslationScreen();
      case 8:
        return const ScamVerificationScreen();
      default:
        return DashboardScreen(
          onNavigateTab: (tabIdx) => setState(() => _currentTabIndex = tabIdx),
          activeItinerary: _activeItinerary,
        );
    }
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'AeroNova Command Center';
      case 1: return 'Smart Route Recovery (Signature)';
      case 2: return 'Conversational AI Planner';
      case 3: return 'Explore Destinations';
      case 4: return 'Offline Travel Kit';
      case 5: return 'Travel Bookings & Vouchers';
      case 6: return 'Emergency SOS Assistance';
      case 7: return 'Multilingual Translation';
      case 8: return 'Travel Scam Verification';
      default: return 'AeroNova AI';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF147FE8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.flight_takeoff, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_getTitle(_currentTabIndex),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const Text('AI Virtual Travel Concierge', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt, color: Color(0xFFF97316)),
            tooltip: 'Smart Route Recovery',
            onPressed: () => setState(() => _currentTabIndex = 1),
          ),
          IconButton(
            icon: const Icon(Icons.download_for_offline, color: Color(0xFF8B5CF6)),
            tooltip: 'Offline Trip Kit',
            onPressed: () => setState(() => _currentTabIndex = 4),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF0F172A)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF147FE8), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.flight_takeoff, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 10),
                  const Text('AeroNova AI', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('Autonomous Travel Companion', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            _buildDrawerTile(Icons.dashboard, 'Dashboard', 0),
            _buildDrawerTile(Icons.alt_route, 'Smart Route Recovery (Signature)', 1, isSignature: true),
            _buildDrawerTile(Icons.auto_awesome, 'Plan a Trip (AI)', 2),
            _buildDrawerTile(Icons.explore, 'Explore Destinations', 3),
            _buildDrawerTile(Icons.download_for_offline, 'Offline Travel Kit', 4),
            _buildDrawerTile(Icons.confirmation_number, 'Travel Bookings', 5),
            _buildDrawerTile(Icons.emergency, 'Emergency Assistance', 6),
            _buildDrawerTile(Icons.translate, 'Translation Assistant', 7),
            _buildDrawerTile(Icons.security, 'Travel Scam Verification', 8),
          ],
        ),
      ),
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _currentTabIndex.clamp(0, 4),
              onDestinationSelected: (val) => setState(() => _currentTabIndex = val),
              labelType: NavigationRailLabelType.selected,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
                NavigationRailDestination(icon: Icon(Icons.alt_route), label: Text('Recovery')),
                NavigationRailDestination(icon: Icon(Icons.auto_awesome), label: Text('Planner')),
                NavigationRailDestination(icon: Icon(Icons.explore), label: Text('Explore')),
                NavigationRailDestination(icon: Icon(Icons.download_for_offline), label: Text('Offline')),
              ],
            ),
          Expanded(child: _buildScreen(_currentTabIndex)),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : BottomNavigationBar(
              currentIndex: _currentTabIndex.clamp(0, 4),
              onTap: (val) => setState(() => _currentTabIndex = val),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF147FE8),
              unselectedItemColor: const Color(0xFF64748B),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.alt_route), label: 'Recovery'),
                BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Planner'),
                BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
                BottomNavigationBarItem(icon: Icon(Icons.download_for_offline), label: 'Offline'),
              ],
            ),
    );
  }

  Widget _buildDrawerTile(IconData icon, String title, int index, {bool isSignature = false}) {
    final isSelected = _currentTabIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSignature ? const Color(0xFFF97316) : isSelected ? const Color(0xFF147FE8) : const Color(0xFF64748B)),
      title: Text(title,
          style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSignature ? const Color(0xFFC2410C) : isSelected ? const Color(0xFF147FE8) : const Color(0xFF0F172A))),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context);
        setState(() => _currentTabIndex = index);
      },
    );
  }
}
