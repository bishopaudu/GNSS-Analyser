// Main scrollable screen containing all GNSS sections + tracking FAB.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gnss_provider.dart';
import '../providers/waypoint_provider.dart';
import '../models/waypoint.dart';
import '../utils/app_theme.dart';
import '../widgets/position_section.dart';
import '../widgets/satellite_dashboard_section.dart';
import '../widgets/satellite_list_section.dart';
import '../widgets/map_section.dart';
import '../widgets/signal_chart_section.dart';
import 'skyplot_screen.dart';
import 'about_screen.dart';
import 'waypoints_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GnssProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(context, provider),
      body: provider.errorMessage != null
          ? _buildErrorState(provider.errorMessage!)
          : _buildBody(),
      //floatingActionButton: _TrackingFab(),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, GnssProvider provider) {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentCyan.withValues(alpha: 0.1),
              border: Border.all(
                  color: AppTheme.accentCyan.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.satellite_alt,
                color: AppTheme.accentCyan, size: 18),
          ),
        /*  const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GNSS ANALYZER',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                 // letterSpacing: 3,
                  fontFamily: 'monospace',
                ),
              ),
              /*Text(
                'DIAGNOSTIC TOOL',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 8,
                  letterSpacing: 3,
                  fontFamily: 'monospace',
                ),
              ),*/
            ],
          ),*/
        ],
      ),
      actions: _buildActions(context, provider),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.border),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, GnssProvider gnssProvider) {
    return [
      IconButton(
        icon: const Icon(Icons.info_outline, color: AppTheme.accentPurple),
        tooltip: 'GNSS Glossary',
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AboutScreen())),
      ),
      IconButton(
        icon: const Icon(Icons.radar, color: AppTheme.accentCyan),
        tooltip: 'Radar View',
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SkyplotScreen())),
      ),
      IconButton(
        icon: const Icon(Icons.push_pin, color: AppTheme.accentAmber),
        tooltip: 'Drop Waypoint',
        onPressed: () => _showDropPinDialog(context, gnssProvider),
      ),
      IconButton(
        icon: const Icon(Icons.bookmarks, color: AppTheme.accentGreen),
        tooltip: 'Saved Waypoints',
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const WaypointsScreen())),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: _StatusIndicator(isActive: gnssProvider.isInitialized),
      ),
    ];
  }

  void _showDropPinDialog(BuildContext context, GnssProvider gnssProvider) {
    final pos = gnssProvider.currentPosition;

    if (pos.latitude == 0 && pos.longitude == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Waiting for GPS fix — try again in a moment.',
          style: TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        backgroundColor: AppTheme.accentAmber,
        duration: Duration(seconds: 2),
      ));
      return;
    }

    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.push_pin, color: AppTheme.accentAmber, size: 20),
            SizedBox(width: 10),
            Text(
              'Drop Waypoint',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontFamily: 'monospace',
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${pos.latitude.toStringAsFixed(5)}°, '
              '${pos.longitude.toStringAsFixed(5)}°',
              style: const TextStyle(
                color: AppTheme.accentCyan,
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
            if (gnssProvider.currentAddress != null) ...[
              const SizedBox(height: 4),
              Text(
                gnssProvider.currentAddress!,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontFamily: 'monospace',
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'Name this location…',
                hintStyle: const TextStyle(
                  color: AppTheme.textMuted,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
                filled: true,
                fillColor: AppTheme.surfaceHighlight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: AppTheme.accentAmber, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL',
                style: TextStyle(
                    color: AppTheme.textMuted, fontFamily: 'monospace')),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final waypoint = Waypoint(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                latitude: pos.latitude,
                longitude: pos.longitude,
                altitude: pos.altitude != 0 ? pos.altitude : null,
                address: gnssProvider.currentAddress,
                createdAt: DateTime.now(),
              );
              context.read<WaypointProvider>().addWaypoint(waypoint);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('📌 "$name" saved.',
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 12)),
                backgroundColor: AppTheme.accentGreen.withOpacity(0.9),
                duration: const Duration(seconds: 2),
              ));
            },
            child: const Text('SAVE',
                style: TextStyle(
                    color: AppTheme.accentAmber,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      children: const [
        PositionSection(),
        SatelliteDashboardSection(),
        SignalChartSection(),
        SatelliteListSection(),
        MapSection(),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off,
                color: AppTheme.accentRed, size: 48),
            const SizedBox(height: 16),
            const Text(
              'LOCATION ACCESS REQUIRED',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontFamily: 'monospace',
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCyan,
                foregroundColor: AppTheme.background,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

/// Floating Action Button for starting/stopping path tracking
/*class _TrackingFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GnssProvider>();
    final isTracking = provider.isTracking;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: isTracking
                ? AppTheme.accentRed.withOpacity(0.4)
                : AppTheme.accentGreen.withOpacity(0.4),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          if (isTracking) {
            provider.stopTracking();
          } else {
            provider.startTracking();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isTracking ? AppTheme.accentRed : AppTheme.accentGreen,
          foregroundColor: AppTheme.background,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          elevation: 0,
        ),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isTracking ? Icons.stop_rounded : Icons.play_arrow_rounded,
            key: ValueKey(isTracking),
            size: 22,
          ),
        ),
        label: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            isTracking ? 'STOP TRACKING' : 'START TRACKING',
            key: ValueKey(isTracking),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}*/

// ---------------------------------------------------------------------------

/// Top-right status dot (green = active, grey = inactive)
class _StatusIndicator extends StatelessWidget {
  final bool isActive;
  const _StatusIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.accentGreen : AppTheme.textMuted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 6)]
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isActive ? 'ACTIVE' : 'OFFLINE',
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontFamily: 'monospace',
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
