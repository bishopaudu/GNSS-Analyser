import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('GNSS GLOSSARY'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(
            title: 'SVID / PRN',
            subtitle: 'Space Vehicle ID / Pseudo-Random Noise',
            icon: Icons.tag,
            content: 'The unique identifying number of the satellite currently flying above you in space. For example, GPS-8 means your phone is receiving a signal from USA Navstar GPS Satellite PRN-8.',
          ),
          _buildInfoCard(
            title: 'Constellations',
            subtitle: 'Global Navigation Satellite Systems',
            icon: Icons.public,
            content: 'There are multiple satellite networks orbiting the Earth.\n• GPS: United States\n• GLONASS (GLO): Russia\n• Galileo (GAL): European Union\n• BeiDou (BDS): China\n• QZSS: Japan\n• SBAS: Augmentation systems for higher accuracy.',
          ),
          _buildInfoCard(
            title: 'SNR (dB-Hz)',
            subtitle: 'Signal-To-Noise Ratio',
            icon: Icons.signal_cellular_alt,
            content: 'The raw signal strength of the satellite measured in Decibel-Hertz. It typically ranges from 0 (no signal) to roughly 55 (excellent signal). Higher numbers mean your device has a clearer, unobstructed connection to that specific satellite.',
          ),
          _buildInfoCard(
            title: 'Used in Fix',
            subtitle: 'Active Positioning',
            icon: Icons.gps_fixed,
            content: 'A boolean flag. If YES (usually indicated by a lock icon or a glowing dot), Android\'s internal location algorithm actively trusts and uses this specific satellite\'s data to triangulate your Latitude and Longitude. If NO, the satellite is visible but currently ignored.',
          ),
          _buildInfoCard(
            title: 'Elevation & Azimuth',
            subtitle: 'Spatial Coordinates',
            icon: Icons.explore,
            content: '• Elevation: How high the satellite is sitting in the sky, ranging from 0° (directly on the horizon) to 90° (directly overhead).\n• Azimuth: The compass direction of the satellite ranging from 0° to 360° (where 0° is North, 90° is East). These two coordinates are used to plot satellites on the Radar View.',
          ),
          const SizedBox(height: 40),
          const Center(
            child: Text(
              'GNSS Analyzer Tool\nDiagnostic Build',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12,
                fontFamily: 'monospace',
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required String content,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.accentCyan, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.accentPurple,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.surfaceHighlight),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.5,
              fontFamily: 'sans-serif',
            ),
          ),
        ],
      ),
    );
  }
}
