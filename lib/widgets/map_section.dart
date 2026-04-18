// widgets/map_section.dart
// Map view: live OSM tiles + path polyline + waypoint pin markers.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:provider/provider.dart';
import '../providers/gnss_provider.dart';
import '../providers/waypoint_provider.dart';
import '../models/gps_position.dart';
import '../models/waypoint.dart';
import '../utils/app_theme.dart';
import 'section_card.dart';

class MapSection extends StatelessWidget {
  const MapSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GnssProvider>();
    final waypointProvider = context.watch<WaypointProvider>();
    final pos = provider.currentPosition;
    final isTracking = provider.isTracking;
    final totalDistance = provider.totalDistance;
    final pathPoints = provider.trackingPath;
    final waypoints = waypointProvider.waypoints;

    return SectionCard(
      title: 'Map View',
      subtitle: 'OpenStreetMap',
      accentColor: AppTheme.accentPurple,
      trailing: isTracking
          ? _DistanceBadge(meters: totalDistance)
          : null,
      child: Column(
        children: [
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
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.gnss_analyzer',
                    ),
                    // Path polyline — only rendered when 2+ points exist
                    if (pathPoints.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: pathPoints
                                .map((p) => LatLng(p.latitude, p.longitude))
                                .toList(),
                            color: AppTheme.accentCyan,
                            strokeWidth: 3,
                          ),
                        ],
                      ),
                    // Waypoint markers — amber push-pin icons
                    if (waypoints.isNotEmpty)
                      MarkerLayer(
                        markers: waypoints
                            .map((w) => _buildWaypointMarker(context, w))
                            .toList(),
                      ),
                    // Current position marker
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(pos.latitude, pos.longitude),
                          child: const Icon(Icons.navigation,
                              color: AppTheme.accentGreen, size: 28),
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
                if (waypoints.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.push_pin,
                      color: AppTheme.accentAmber, size: 11),
                  const SizedBox(width: 3),
                  Text(
                    '${waypoints.length} pin${waypoints.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: AppTheme.accentAmber,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Marker _buildWaypointMarker(BuildContext context, Waypoint w) {
    return Marker(
      point: LatLng(w.latitude, w.longitude),
      width: 140,
      height: 52,
      child: GestureDetector(
        onTap: () => _showWaypointTooltip(context, w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name label
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(4),
                border:
                    Border.all(color: AppTheme.accentAmber.withOpacity(0.5)),
              ),
              child: Text(
                w.name,
                style: const TextStyle(
                  color: AppTheme.accentAmber,
                  fontSize: 9,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            // Pin icon
            const Icon(Icons.push_pin, color: AppTheme.accentAmber, size: 20),
          ],
        ),
      ),
    );
  }

  void _showWaypointTooltip(BuildContext context, Waypoint w) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.push_pin,
                    color: AppTheme.accentAmber, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    w.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            if (w.address != null) ...[
              const SizedBox(height: 8),
              Text(
                w.address!,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              w.coordString,
              style: const TextStyle(
                color: AppTheme.accentCyan,
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

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
                        'Acquiring location…',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontFamily: 'monospace',
                          fontSize: 11,
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

    if (pathPoints.length > 1) {
      final pathPaint = Paint()
        ..color = AppTheme.accentCyan.withOpacity(0.8)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final baseLat = pathPoints.first.latitude;
      final baseLon = pathPoints.first.longitude;
      const scale = 5000.0;

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

    final centerPaint = Paint()
      ..color = AppTheme.accentGreen
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = AppTheme.accentGreen.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx, cy), 16, glowPaint);
    canvas.drawCircle(Offset(cx, cy), 6, centerPaint);

    final crossPaint = Paint()
      ..color = AppTheme.accentGreen.withOpacity(0.5)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(cx - 20, cy), Offset(cx - 8, cy), crossPaint);
    canvas.drawLine(Offset(cx + 8, cy), Offset(cx + 20, cy), crossPaint);
    canvas.drawLine(Offset(cx, cy - 20), Offset(cx, cy - 8), crossPaint);
    canvas.drawLine(Offset(cx, cy + 8), Offset(cx, cy + 20), crossPaint);

    if (position.accuracy > 0) {
      final accuracyPaint = Paint()
        ..color = AppTheme.accentCyan.withOpacity(0.15)
        ..style = PaintingStyle.fill;
      final accuracyBorderPaint = Paint()
        ..color = AppTheme.accentCyan.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

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
