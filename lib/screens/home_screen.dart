// Main scrollable screen containing all 4 GNSS sections + tracking FAB.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/gnss_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/position_section.dart';
import '../widgets/satellite_dashboard_section.dart';
import '../widgets/satellite_list_section.dart';
import '../widgets/map_section.dart';
import '../widgets/signal_chart_section.dart';
import 'skyplot_screen.dart';
import 'about_screen.dart';

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
      floatingActionButton: _TrackingFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, GnssProvider provider) {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      title: Row(
        children: [
          // Satellite icon with glow
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentCyan.withValues(alpha: 0.1),
              border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
            ),
            child: const Icon(
              Icons.satellite_alt,
              color: AppTheme.accentCyan,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GNSS ANALYZER',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'DIAGNOSTIC TOOL',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 8,
                  letterSpacing: 3,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: AppTheme.accentPurple),
          tooltip: 'GNSS Glossary',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.radar, color: AppTheme.accentCyan),
          tooltip: 'Radar View',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SkyplotScreen()),
            );
          },
        ),
        // Status indicator
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _StatusIndicator(isActive: provider.isInitialized),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppTheme.border,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      children: const [
        // Current Position
        PositionSection(),
        // Satellite Dashboard (shown before list for quick overview)
        SatelliteDashboardSection(),
        // Signal chart visualization
        SignalChartSection(),
        // Satellite List
        SatelliteListSection(),
        // Map View
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
            const Icon(
              Icons.location_off,
              color: AppTheme.accentRed,
              size: 48,
            ),
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
              onPressed: () {
                // Re-attempt initialization
              },
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

/// Floating Action Button for starting/stopping path tracking
class _TrackingFab extends StatelessWidget {
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
          backgroundColor: isTracking ? AppTheme.accentRed : AppTheme.accentGreen,
          foregroundColor: AppTheme.background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
}

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
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.6),
                      blurRadius: 6,
                    )
                  ]
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
