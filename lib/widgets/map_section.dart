//  Map view showing current location and tracked path using OpenStreetMap.
// Uses flutter_map (no API key needed) with OSM tile layer.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:provider/provider.dart';

import '../providers/gnss_provider.dart';
import '../models/gps_position.dart';
import '../utils/app_theme.dart';
import 'section_card.dart';

class MapSection extends StatelessWidget {
  const MapSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GnssProvider>();
    final pos = provider.currentPosition;
    final isTracking = provider.isTracking;
    final totalDistance = provider.totalDistance;
    final pathPoints = provider.trackingPath;

    return SectionCard(
      title: 'Map View',
      subtitle: 'OpenStreetMap',
      accentColor: AppTheme.accentPurple,
      trailing: isTracking
          ? _DistanceBadge(meters: totalDistance)
          : null,
      child: Column(
        children: [
          // Render real tiles if we have a position, otherwise a simple placeholder
          if (pos.latitude != 0)
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(pos.latitude, pos.longitude),
                    initialZoom: 16,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.gnss_analyzer',
                    ),
                    // Path polyline — only render when we have 2+ points
                    if (pathPoints.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: pathPoints.map((p) => LatLng(p.latitude, p.longitude)).toList(),
                            color: AppTheme.accentCyan,
                            strokeWidth: 3,
                          ),
                        ],
                      ),
                    // Current position marker
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(pos.latitude, pos.longitude),
                          child: const Icon(Icons.navigation, color: AppTheme.accentGreen, size: 28),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            _MapPlaceholder(
              position: pos,
              pathPoints: pathPoints,
              isTracking: isTracking,
            ),
          const SizedBox(height: 10),
          // Coordinate readout below map
          if (pos.latitude != 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on,
                    color: AppTheme.accentPurple, size: 12),
                const SizedBox(width: 4),
                Text(
                  '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
/// Stylized map placeholder that shows coordinate grid and path simulation
class _MapPlaceholder extends StatelessWidget {
  final GpsPosition position;
  final List<GpsPosition> pathPoints;
  final bool isTracking;

  const _MapPlaceholder({
    required this.position,
    required this.pathPoints,
    required this.isTracking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentPurple.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomPaint(
          painter: _MapGridPainter(
            position: position,
            pathPoints: pathPoints,
            isTracking: isTracking,
          ),
          child: Center(
            child: position.latitude == 0
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        color: AppTheme.accentPurple.withOpacity(0.4),
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Acquiring location...',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Add flutter_map for live tiles',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontFamily: 'monospace',
                          fontSize: 9,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

/// Custom painter that draws a grid and path visualization
class _MapGridPainter extends CustomPainter {
  final GpsPosition position;
  final List<GpsPosition> pathPoints;
  final bool isTracking;

  _MapGridPainter({
    required this.position,
    required this.pathPoints,
    required this.isTracking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid
    final gridPaint = Paint()
      ..color = AppTheme.accentPurple.withOpacity(0.08)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 10; i++) {
      final x = size.width * i / 10;
      final y = size.height * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (position.latitude == 0) return;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Draw path if tracking
    if (pathPoints.length > 1) {
      final pathPaint = Paint()
        ..color = AppTheme.accentCyan.withOpacity(0.8)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // Scale path points relative to center
      final baseLat = pathPoints.first.latitude;
      final baseLon = pathPoints.first.longitude;
      const scale = 5000.0; // pixels per degree

      final path = Path();
      for (int i = 0; i < pathPoints.length; i++) {
        final dx = (pathPoints[i].longitude - baseLon) * scale;
        final dy = -(pathPoints[i].latitude - baseLat) * scale;
        final px = cx + dx;
        final py = cy + dy;
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      canvas.drawPath(path, pathPaint);
    }

    // Draw position circle / crosshair
    final centerPaint = Paint()
      ..color = AppTheme.accentGreen
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = AppTheme.accentGreen.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx, cy), 16, glowPaint);
    canvas.drawCircle(Offset(cx, cy), 6, centerPaint);

    // Crosshair lines
    final crossPaint = Paint()
      ..color = AppTheme.accentGreen.withOpacity(0.5)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(cx - 20, cy), Offset(cx - 8, cy), crossPaint);
    canvas.drawLine(Offset(cx + 8, cy), Offset(cx + 20, cy), crossPaint);
    canvas.drawLine(Offset(cx, cy - 20), Offset(cx, cy - 8), crossPaint);
    canvas.drawLine(Offset(cx, cy + 8), Offset(cx, cy + 20), crossPaint);

    // Accuracy circle
    if (position.accuracy > 0) {
      final accuracyPaint = Paint()
        ..color = AppTheme.accentCyan.withOpacity(0.15)
        ..style = PaintingStyle.fill;
      final accuracyBorderPaint = Paint()
        ..color = AppTheme.accentCyan.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      // Scale accuracy circle (rough approximation for visualization)
      final radius = (position.accuracy * 0.5).clamp(8.0, 60.0);
      canvas.drawCircle(Offset(cx, cy), radius, accuracyPaint);
      canvas.drawCircle(Offset(cx, cy), radius, accuracyBorderPaint);
    }
  }

  @override
  bool shouldRepaint(_MapGridPainter old) =>
      old.position != position || old.pathPoints != pathPoints;
}

class _DistanceBadge extends StatelessWidget {
  final double meters;

  const _DistanceBadge({required this.meters});

  @override
  Widget build(BuildContext context) {
    final label = meters >= 1000
        ? '${(meters / 1000).toStringAsFixed(2)} km'
        : '${meters.toStringAsFixed(0)} m';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.accentCyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.accentCyan.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.route, color: AppTheme.accentCyan, size: 10),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.accentCyan,
              fontSize: 10,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
