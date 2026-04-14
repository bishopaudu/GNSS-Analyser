// widgets/position_section.dart
// Section 1: Displays real-time GPS position data (lat, lon, alt, accuracy, speed, heading).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/gnss_provider.dart';
import '../models/gps_position.dart';
import '../utils/app_theme.dart';
import 'section_card.dart';

class PositionSection extends StatelessWidget {
  const PositionSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Use select to rebuild only when position changes
    final pos = context.select<GnssProvider, GpsPosition>(
      (p) => p.currentPosition,
    );

    return SectionCard(
      title: 'Current Position',
      subtitle: 'Real-time GPS fix',
      accentColor: AppTheme.accentCyan,
      trailing: _LiveIndicator(),
      child: Column(
        children: [
          // Primary coordinates row
          Row(
            children: [
              Expanded(
                child: _CoordTile(
                  label: 'LATITUDE',
                  value: pos.latitude != 0
                      ? '${pos.latitude.toStringAsFixed(6)}°'
                      : '---',
                  color: AppTheme.accentCyan,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CoordTile(
                  label: 'LONGITUDE',
                  value: pos.longitude != 0
                      ? '${pos.longitude.toStringAsFixed(6)}°'
                      : '---',
                  color: AppTheme.accentCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Secondary metrics grid
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'ALTITUDE',
                  value: pos.altitude != 0
                      ? '${pos.altitude.toStringAsFixed(1)} m'
                      : '--- m',
                  icon: Icons.terrain,
                ),
              ),
              Expanded(
                child: _MetricTile(
                  label: 'ACCURACY',
                  value: pos.accuracy != 0
                      ? '±${pos.accuracy.toStringAsFixed(1)} m'
                      : '--- m',
                  icon: Icons.adjust,
                  valueColor: _accuracyColor(pos.accuracy),
                ),
              ),
              Expanded(
                child: _MetricTile(
                  label: 'SPEED',
                  value: '${pos.speedKmh.toStringAsFixed(1)} km/h',
                  icon: Icons.speed,
                ),
              ),
              Expanded(
                child: _MetricTile(
                  label: 'HEADING',
                  value: pos.heading != 0 || pos.speed > 0
                      ? '${pos.heading.toStringAsFixed(0)}° ${pos.headingDirection}'
                      : '---',
                  icon: Icons.navigation,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _accuracyColor(double accuracy) {
    if (accuracy <= 0) return AppTheme.textMuted;
    if (accuracy <= 5) return AppTheme.accentGreen;
    if (accuracy <= 15) return AppTheme.accentAmber;
    return AppTheme.accentRed;
  }
}

/// Blinking green dot to show live data feed
class _LiveIndicator extends StatefulWidget {
  @override
  State<_LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<_LiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: AppTheme.accentGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentGreen.withOpacity(0.8),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'LIVE',
            style: TextStyle(
              color: AppTheme.accentGreen,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

/// Large coordinate display tile
class _CoordTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CoordTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceHighlight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact metric tile for secondary data
class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.textMuted, size: 14),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 9,
            letterSpacing: 1.2,
            fontFamily: 'monospace',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
