// widgets/satellite_list_section.dart
// Section 2: Scrollable list of all visible satellites with signal strength visualization.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/gnss_provider.dart';
import '../models/satellite_info.dart';
import '../utils/app_theme.dart';
import 'section_card.dart';

class SatelliteListSection extends StatelessWidget {
  const SatelliteListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final satellites =
        context.select<GnssProvider, List<SatelliteInfo>>((p) => p.satellites);

    return SectionCard(
      title: 'Satellite Information',
      subtitle: '${satellites.length} satellites visible',
      accentColor: AppTheme.accentGreen,
      child: satellites.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Table header
                _buildHeader(),
                const SizedBox(height: 6),
                // Satellite rows — shrinkwrapped since parent is scrollable
                ...satellites.map((sat) => _SatelliteRow(satellite: sat)),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.satellite_alt, color: AppTheme.textMuted, size: 32),
            SizedBox(height: 8),
            Text(
              'Searching for satellites...',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    const style = TextStyle(
      color: AppTheme.textMuted,
      fontSize: 9,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
      fontFamily: 'monospace',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          const SizedBox(width: 36), // ID column
          const Expanded(
            flex: 2,
            child: Text('CONST.', style: style),
          ),
          const Expanded(
            flex: 3,
            child: Text('SIGNAL (dB-Hz)', style: style),
          ),
          const SizedBox(width: 16), // Used column
        ],
      ),
    );
  }
}

/// A single row in the satellite table
class _SatelliteRow extends StatelessWidget {
  final SatelliteInfo satellite;

  const _SatelliteRow({required this.satellite});

  @override
  Widget build(BuildContext context) {
    final color =
        AppTheme.constellationColors[satellite.constellation.label] ??
            AppTheme.textMuted;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: satellite.usedInFix
            ? AppTheme.accentGreen.withOpacity(0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: satellite.usedInFix
              ? AppTheme.accentGreen.withOpacity(0.15)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Satellite ID
          SizedBox(
            width: 36,
            child: Text(
              satellite.svid.toString().padLeft(3, '0'),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Constellation badge
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                satellite.constellation.label,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Signal strength bar visualization
          Expanded(
            flex: 3,
            child: _SignalStrengthBar(snr: satellite.snr),
          ),
          // Used-in-fix indicator
          SizedBox(
            width: 16,
            child: satellite.usedInFix
                ? const Icon(
                    Icons.check_circle,
                    color: AppTheme.accentGreen,
                    size: 13,
                  )
                : const Icon(
                    Icons.radio_button_unchecked,
                    color: AppTheme.textMuted,
                    size: 13,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Animated bar chart showing SNR signal strength.
/// SNR range is typically 0–55 dB-Hz. Displays 5 segmented bars.
class _SignalStrengthBar extends StatelessWidget {
  final double snr;
  // Maximum expected SNR for scaling (55 dB-Hz is excellent)
  static const double _maxSnr = 55.0;
  static const int _barCount = 5;

  const _SignalStrengthBar({required this.snr});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 5 progressively taller bars
        ...List.generate(_barCount, (i) {
          final threshold = (i + 1) / _barCount * _maxSnr;
          final isFilled = snr >= threshold;
          final barHeight = 6.0 + (i * 3.0); // 6, 9, 12, 15, 18 px
          final barColor = isFilled
              ? AppTheme.signalColors[i + 1]
              : AppTheme.surfaceHighlight;

          return Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Container(
              width: 6,
              height: barHeight,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(1.5),
                boxShadow: isFilled
                    ? [
                        BoxShadow(
                          color: barColor.withOpacity(0.5),
                          blurRadius: 4,
                        )
                      ]
                    : null,
              ),
            ),
          );
        }),
        const SizedBox(width: 5),
        // Numeric SNR value
        Text(
          snr > 0 ? snr.toStringAsFixed(0) : '--',
          style: TextStyle(
            color: _snrColor(snr),
            fontSize: 10,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _snrColor(double snr) {
    if (snr <= 0) return AppTheme.textMuted;
    if (snr < 15) return AppTheme.accentRed;
    if (snr < 25) return AppTheme.accentAmber;
    if (snr < 35) return AppTheme.accentCyan;
    return AppTheme.accentGreen;
  }
}
