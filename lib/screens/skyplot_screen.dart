import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/gnss_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/skyplot_view.dart';
import '../models/satellite_info.dart';

class SkyplotScreen extends StatelessWidget {
  const SkyplotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GnssProvider>();
    final satellites = provider.satellites;
    
    // Sort satellites to plot used-in-fix to be on top layer (drawn last)
    final sortedSatellites = List<SatelliteInfo>.from(satellites)
      ..sort((a, b) {
        if (a.usedInFix != b.usedInFix) {
          return a.usedInFix ? 1 : -1;
        }
        return a.snr.compareTo(b.snr);
      });

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'RADAR VIEW',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            fontFamily: 'monospace',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'SATELLITE SKYPLOT',
              style: TextStyle(
                color: AppTheme.accentPurple,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Shows overhead projection of satellites based on local Azimuth (direction) and Elevation (height).\nDot size indicates Signal-to-Noise Ratio (SNR).',
              style: TextStyle(
                color: AppTheme.textMuted.withOpacity(0.8),
                fontSize: 10,
                height: 1.5,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: sortedSatellites.isEmpty
                  ? const Text(
                      'No satellite data available',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontFamily: 'monospace',
                      ),
                    )
                  : SkyplotView(satellites: sortedSatellites),
            ),
          ),
          _buildLegend(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceHighlight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(
                  color: AppTheme.accentGreen,
                  label: 'Used In Fix',
                  glow: true,
                ),
                _LegendItem(
                  color: AppTheme.textMuted,
                  label: 'Visible Only',
                  glow: false,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: AppTheme.constellationColors.entries.map((e) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: e.value,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      e.key,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 9,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool glow;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.glow,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: glow
                ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4, spreadRadius: 2)]
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 10,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
