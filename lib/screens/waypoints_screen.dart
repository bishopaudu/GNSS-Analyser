// screens/waypoints_screen.dart
// Displays all saved waypoints with share and delete actions.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/waypoint.dart';
import '../providers/waypoint_provider.dart';
import '../utils/app_theme.dart';

class WaypointsScreen extends StatelessWidget {
  const WaypointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final waypoints = context.watch<WaypointProvider>().waypoints;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SAVED WAYPOINTS',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: waypoints.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: waypoints.length,
              itemBuilder: (context, index) {
                return _WaypointCard(waypoint: waypoints[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.accentAmber.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.accentAmber.withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.push_pin_outlined,
              color: AppTheme.accentAmber,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'NO WAYPOINTS SAVED',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the pin icon on the home screen\nto drop a waypoint at your current location.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontFamily: 'monospace',
              fontSize: 11,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaypointCard extends StatelessWidget {
  final Waypoint waypoint;

  const _WaypointCard({required this.waypoint});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentAmber.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
              border: const Border(
                bottom: BorderSide(color: AppTheme.border),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppTheme.accentAmber.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.accentAmber.withOpacity(0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.push_pin,
                    color: AppTheme.accentAmber,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    waypoint.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Share button
                IconButton(
                  icon: const Icon(Icons.share,
                      color: AppTheme.accentCyan, size: 18),
                  tooltip: 'Share location',
                  onPressed: () => _shareWaypoint(waypoint),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppTheme.accentRed, size: 18),
                  tooltip: 'Delete waypoint',
                  onPressed: () => _confirmDelete(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Address
                if (waypoint.address != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppTheme.accentAmber, size: 13),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          waypoint.address!,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontFamily: 'monospace',
                            fontSize: 11,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                // Coordinates row
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.my_location,
                      label: waypoint.coordString,
                      color: AppTheme.accentCyan,
                    ),
                    if (waypoint.altitude != null) ...[
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.terrain,
                        label: '${waypoint.altitude!.toStringAsFixed(1)} m',
                        color: AppTheme.accentPurple,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                // Timestamp
                Text(
                  _formatDate(waypoint.createdAt),
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontFamily: 'monospace',
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareWaypoint(Waypoint w) {
    final mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${w.latitude},${w.longitude}';
    final text = '📌 ${w.name}\n'
        '${w.address != null ? '${w.address}\n' : ''}'
        '$mapsUrl\n'
        '${w.coordString}';
    Share.share(text);
  }

  void _confirmDelete(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Delete Waypoint?',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontFamily: 'monospace',
            fontSize: 15,
          ),
        ),
        content: Text(
          'Remove "${waypoint.name}" from your saved locations?',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<WaypointProvider>().deleteWaypoint(waypoint.id);
              Navigator.pop(ctx);
            },
            child: const Text(
              'DELETE',
              style: TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  $h:$m';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
