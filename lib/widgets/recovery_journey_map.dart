// Use the app shell's Material library; migrate the whole app together.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

const List<LatLng> recoveryRoutePoints = <LatLng>[
  LatLng(28.6139, 77.2090), // Delhi
  LatLng(26.9196, 75.7878), // Jaipur
  LatLng(26.4568, 74.6367), // Ajmer
  LatLng(26.2867, 73.0230), // Jodhpur
];

/// A real OpenStreetMap-backed map with an explicitly illustrative corridor.
class RecoveryJourneyMap extends StatefulWidget {
  const RecoveryJourneyMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.isLive,
    this.loadTiles = true,
    this.showUserLocation = true,
  });

  final double latitude;
  final double longitude;
  final bool isLive;
  final bool loadTiles;

  /// Keep false until the app has a real device fix to avoid showing a made-up
  /// blue dot at the default coordinates.
  final bool showUserLocation;

  @override
  State<RecoveryJourneyMap> createState() => _RecoveryJourneyMapState();
}

class _RecoveryJourneyMapState extends State<RecoveryJourneyMap> {
  final MapController _mapController = MapController();
  bool _mapReady = false;
  bool _tilesUnavailable = false;

  @override
  void didUpdateWidget(covariant RecoveryJourneyMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLive &&
        widget.showUserLocation &&
        (widget.latitude != oldWidget.latitude ||
            widget.longitude != oldWidget.longitude)) {
      _centerOnUser();
    }
  }

  void _centerOnUser() {
    if (!_mapReady) return;
    _mapController.move(LatLng(widget.latitude, widget.longitude), 12);
  }

  void _onTileError(TileImage tile, Object error, StackTrace? stackTrace) {
    if (!mounted || _tilesUnavailable) return;
    setState(() => _tilesUnavailable = true);
  }

  Future<void> _openAttribution() async {
    final opened = await launchUrl(
      Uri.parse('https://www.openstreetmap.org/copyright'),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open OpenStreetMap copyright details.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stops = <({String name, LatLng point})>[
      (name: 'Delhi', point: recoveryRoutePoints[0]),
      (name: 'Jaipur', point: recoveryRoutePoints[1]),
      (name: 'Ajmer', point: recoveryRoutePoints[2]),
      (name: 'Jodhpur', point: recoveryRoutePoints[3]),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCameraFit: CameraFit.bounds(
                  bounds: LatLngBounds.fromPoints(recoveryRoutePoints),
                  padding: const EdgeInsets.all(48),
                ),
                onMapReady: () {
                  _mapReady = true;
                  if (widget.isLive && widget.showUserLocation) {
                    _centerOnUser();
                  }
                },
              ),
              children: [
                if (widget.loadTiles)
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.aeronova.aeronova_travel',
                    errorTileCallback: _onTileError,
                  ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: recoveryRoutePoints,
                      color: const Color(0xFF147FE8),
                      strokeWidth: 4,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    for (var index = 0; index < stops.length; index++)
                      Marker(
                        point: stops[index].point,
                        width: 86,
                        height: 66,
                        alignment: Alignment.topCenter,
                        child: _StopMarker(
                          number: index + 1,
                          name: stops[index].name,
                        ),
                      ),
                    if (widget.showUserLocation)
                      Marker(
                        point: LatLng(widget.latitude, widget.longitude),
                        width: 34,
                        height: 34,
                        child: Semantics(
                          label: 'Your current location',
                          child: const _CurrentLocationMarker(),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: _RouteLabel(isLive: widget.isLive),
          ),
          if (widget.loadTiles && _tilesUnavailable)
            Positioned(
              left: 12,
              top: 52,
              right: 12,
              child: Material(
                color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Text(
                    'Some map tiles could not load. The route remains available.',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 8,
            bottom: 6,
            child: TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F172A),
                textStyle: const TextStyle(fontSize: 11),
              ),
              onPressed: widget.loadTiles ? _openAttribution : null,
              child: const Text('© OpenStreetMap contributors'),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Material(
                color: Colors.white,
                elevation: 3,
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'Center on current location',
                  icon: const Icon(Icons.my_location, color: Color(0xFF147FE8)),
                  onPressed: widget.showUserLocation ? _centerOnUser : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StopMarker extends StatelessWidget {
  const _StopMarker({required this.number, required this.name});

  final int number;
  final String name;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 25,
        height: 25,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4)],
        ),
        child: Text(
          '$number',
          textScaler: TextScaler.noScaling,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Container(
        constraints: const BoxConstraints(maxWidth: 80),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          name,
          textScaler: TextScaler.noScaling,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

class _CurrentLocationMarker extends StatelessWidget {
  const _CurrentLocationMarker();

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF147FE8),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 3),
      boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 6)],
    ),
  );
}

class _RouteLabel extends StatelessWidget {
  const _RouteLabel({required this.isLive});

  final bool isLive;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 5)],
    ),
    child: Text(
      isLive ? 'Illustrative route · GPS' : 'Illustrative route',
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
