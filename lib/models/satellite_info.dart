// Represents data for a single GNSS satellite

/// Enumeration for GNSS constellation types
enum ConstellationType {
  gps,
  glonass,
  galileo,
  beidou,
  qzss,
  sbas,
  unknown;

  /// Returns a short label for display
  String get label {
    switch (this) {
      case ConstellationType.gps:
        return 'GPS';
      case ConstellationType.glonass:
        return 'GLO';
      case ConstellationType.galileo:
        return 'GAL';
      case ConstellationType.beidou:
        return 'BDS';
      case ConstellationType.qzss:
        return 'QZSS';
      case ConstellationType.sbas:
        return 'SBAS';
      case ConstellationType.unknown:
        return 'UNK';
    }
  }

  /// Returns the full name of the constellation
  String get fullName {
    switch (this) {
      case ConstellationType.gps:
        return 'GPS (USA)';
      case ConstellationType.glonass:
        return 'GLONASS (Russia)';
      case ConstellationType.galileo:
        return 'Galileo (EU)';
      case ConstellationType.beidou:
        return 'BeiDou (China)';
      case ConstellationType.qzss:
        return 'QZSS (Japan)';
      case ConstellationType.sbas:
        return 'SBAS';
      case ConstellationType.unknown:
        return 'Unknown';
    }
  }
}

class SatelliteInfo {
  final int svid; // Satellite Vehicle ID
  final ConstellationType constellation;
  final double snr; // Signal-to-Noise Ratio in dB-Hz (0–55 typical)
  final double elevation; // Elevation angle in degrees (0–90)
  final double azimuth; // Azimuth angle in degrees (0–360)
  final bool usedInFix; // Whether this satellite contributed to the position fix

  const SatelliteInfo({
    required this.svid,
    required this.constellation,
    required this.snr,
    required this.elevation,
    required this.azimuth,
    required this.usedInFix,
  });

  /// SNR quality level: 0=none, 1=poor, 2=fair, 3=good, 4=excellent
  int get signalQuality {
    if (snr <= 0) return 0;
    if (snr < 15) return 1;
    if (snr < 25) return 2;
    if (snr < 35) return 3;
    return 4;
  }
}
