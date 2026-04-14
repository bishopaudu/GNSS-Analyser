// widgets/signal_chart_section.dart
// Section 5: Horizontal bar chart of all satellite signal strengths — like GPSTest's chart view.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/gnss_provider.dart';
import '../models/satellite_info.dart';
import '../utils/app_theme.dart';
import 'section_card.dart';

class SignalChartSection extends StatelessWidget {
  const SignalChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    final satellites =
        context.select<GnssProvider, List<SatelliteInfo>>((p) => p.satellites);

    // Only show satellites with some signal
    final activeSats = satellites.where((s) => s.snr > 0).toList();

    return SectionCard(
      title: 'Signal Strength',
      subtitle: 'Carrier-to-Noise density (dB-Hz)',
      accentColor: AppTheme.accentRed,
      child: activeSats.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No signal data available',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ),
            )
          : Column(
              children: [
                // Scale reference row
                _ScaleRow(),
                const SizedBox(height: 8),
                // One bar per satellite, sorted by constellation then SVid
                ...activeSats.map(
                  (sat) => _SignalBar(satellite: sat),
                ),
              ],
            ),
    );
  }
}

/// Reference scale showing 0, 15, 25, 35, 55 dB-Hz thresholds
class _ScaleRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 48), // align with bar start
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _ScaleLabel('0'),
              _ScaleLabel('15'),
              _ScaleLabel('25'),
              _ScaleLabel('35'),
              _ScaleLabel('55'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScaleLabel extends StatelessWidget {
  final String text;
  const _ScaleLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textMuted,
        fontSize: 8,
        fontFamily: 'monospace',
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Animated horizontal bar for one satellite's SNR
class _SignalBar extends StatelessWidget {
  final SatelliteInfo satellite;
  static const double _maxSnr = 55.0;

  const _SignalBar({required this.satellite});

  @override
  Widget build(BuildContext context) {
    final constellation = satellite.constellation.label;
    final color = AppTheme.constellationColors[constellation] ?? AppTheme.textMuted;
    final fillFraction = (satellite.snr / _maxSnr).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // ID + constellation label
          SizedBox(
            width: 48,
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${constellation} ${satellite.svid}',
                    style: TextStyle(
                      color: color,
                      fontSize: 8,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Signal bar
          Expanded(
            child: Stack(
              children: [
                // Background track
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHighlight,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // Threshold markers (15, 25, 35 dB-Hz)
                ...[15, 25, 35].map((threshold) {
                  final x = threshold / _maxSnr;
                  return FractionallySizedBox(
                    widthFactor: x,
                    child: Container(
                      height: 12,
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: AppTheme.surface,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                // Fill bar
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  widthFactor: fillFraction,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.6),
                          color,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                // Used-in-fix indicator
                if (satellite.usedInFix)
                  Positioned.fill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: Icon(
                            Icons.check,
                            color: Colors.white.withOpacity(0.9),
                            size: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Numeric value
          SizedBox(
            width: 28,
            child: Text(
              satellite.snr.toStringAsFixed(0),
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
