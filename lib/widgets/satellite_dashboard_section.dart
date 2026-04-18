// widgets/satellite_dashboard_section.dart
// Section 3: Summary statistics — total sats, used in fix, avg SNR, constellation breakdown.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/gnss_provider.dart';
import '../utils/app_theme.dart';
import 'section_card.dart';

class SatelliteDashboardSection extends StatelessWidget {
  const SatelliteDashboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GnssProvider>();
    final total = provider.totalSatellites;
    final used = provider.satellitesUsedInFix;
    final avgSnr = provider.averageSignalStrength;
    final counts = provider.constellationCounts;

    return SectionCard(
      title: 'Satellite Dashboard',
      subtitle: 'Summary statistics',
      accentColor: AppTheme.accentAmber,
      child: Column(
        children: [
          // Main counters row
          Row(
            children: [
              Expanded(
                child: _StatBadge(
                  value: total.toString(),
                  label: 'VISIBLE',
                  color: AppTheme.accentCyan,
                  icon: Icons.satellite_alt,
                ),
              ),
              Expanded(
                child: _StatBadge(
                  value: used.toString(),
                  label: 'IN FIX',
                  color: AppTheme.accentGreen,
                  icon: Icons.gps_fixed,
                ),
              ),
              Expanded(
                child: _StatBadge(
                  value: avgSnr > 0 ? avgSnr.toStringAsFixed(1) : '0.0',
                  label: 'AVG SNR (dB)',
                  color: AppTheme.accentAmber,
                  icon: Icons.signal_cellular_alt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Fix percentage bar
          if (total > 0) ...[
            Row(
              children: [
                const Text(
                  'FIX RATIO',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 9,
                    letterSpacing: 1.8,
                    fontFamily: 'monospace',
                  ),
                ),
                const Spacer(),
                Text(
                  '${used}/${total}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total > 0 ? used / total : 0,
                backgroundColor: AppTheme.surfaceHighlight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  used / total > 0.5
                      ? AppTheme.accentGreen
                      : AppTheme.accentAmber,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Constellation breakdown
          if (counts.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: counts.entries.map((entry) {
                final label = entry.key.label;
                final color = AppTheme.constellationColors[label] ??
                    AppTheme.textMuted;
                return _ConstellationChip(
                  label: label,
                  count: entry.value,
                  color: color,
                );
              }).toList(),
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Acquiring satellites...',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatBadge({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.08),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: value.length > 3 ? 13 : 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Icon(icon, color: color.withOpacity(0.6), size: 12),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.7),
            fontSize: 8,
            letterSpacing: 1.5,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ConstellationChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _ConstellationChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
