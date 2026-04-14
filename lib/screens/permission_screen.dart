// screens/permission_screen.dart
// Shown when the app is first launched or when permissions are denied.
// Explains why location access is needed before requesting it.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/gnss_provider.dart';
import '../utils/app_theme.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // App icon area
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.accentCyan.withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentCyan.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.satellite_alt,
                  color: AppTheme.accentCyan,
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'GNSS ANALYZER',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: 4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Professional GPS Diagnostic Tool',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontFamily: 'monospace',
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Permission explanation cards
              _PermissionItem(
                icon: Icons.location_on,
                color: AppTheme.accentCyan,
                title: 'Precise Location',
                description:
                    'Required to access GPS/GNSS hardware for satellite data and positioning.',
              ),
              const SizedBox(height: 12),
              _PermissionItem(
                icon: Icons.satellite_alt,
                color: AppTheme.accentGreen,
                title: 'GNSS Status',
                description:
                    'Reads satellite signal strengths, IDs, and fix quality from the GNSS chipset.',
              ),
              const SizedBox(height: 12),
              _PermissionItem(
                icon: Icons.route,
                color: AppTheme.accentAmber,
                title: 'Path Tracking',
                description:
                    'Records your GPS path and computes total distance traveled during sessions.',
              ),
              const Spacer(),
              // Grant permission button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    await context.read<GnssProvider>().initialize();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCyan,
                    foregroundColor: AppTheme.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'GRANT ACCESS & START',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Location data is processed on-device only\nand never sent to any server.',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontFamily: 'monospace',
                  fontSize: 9,
                  letterSpacing: 0.5,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _PermissionItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontFamily: 'monospace',
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
