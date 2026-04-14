// services/gps_service.dart
// Central service layer for GPS/GNSS data.
// Uses geolocator for position updates and flutter_gnss_status for satellite data.

import 'dart:async';
import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
import 'package:raw_gnss/raw_gnss.dart';
import 'package:raw_gnss/gnss_status_model.dart';

import '../models/gps_position.dart';
import '../models/satellite_info.dart';

class GpsService {
  // Stream controllers for broadcasting position and satellite updates
  final _positionController = StreamController<GpsPosition>.broadcast();
  final _satelliteController = StreamController<List<SatelliteInfo>>.broadcast();

  // Internal subscriptions to platform streams
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<GnssStatusModel>? _gnssSubscription;

  // Public streams for consumers (Provider/widgets) to listen to
  Stream<GpsPosition> get positionStream => _positionController.stream;
  Stream<List<SatelliteInfo>> get satelliteStream => _satelliteController.stream;

  bool _isTracking = false;
  bool get isTracking => _isTracking;

  /// Starts listening to GPS position updates using geolocator.
  /// Updates are requested with high accuracy at ~1 second intervals (500ms distance filter).
  void startPositionUpdates() {
    if (_isTracking) return;
    _isTracking = true;

    // LocationSettings optimized for real-time GNSS diagnostic use
    final locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0, // Receive every update regardless of movement
      intervalDuration: const Duration(seconds: 1),
      forceLocationManager: false, // Use fused provider for best satellite data
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position pos) {
        // Map geolocator Position to our GpsPosition model
        final gpsPos = GpsPosition(
          latitude: pos.latitude,
          longitude: pos.longitude,
          altitude: pos.altitude,
          accuracy: pos.accuracy,
          speed: pos.speed < 0 ? 0 : pos.speed, // Negative speed = invalid
          heading: pos.heading < 0 ? 0 : pos.heading,
          timestamp: pos.timestamp,
        );
        _positionController.add(gpsPos);
      },
      onError: (error) {
        // Emit empty position on error so UI stays responsive
        _positionController.add(GpsPosition.empty());
      },
    );

    // Start satellite (GNSS status) updates via flutter_gnss_status
    _startSatelliteUpdates();
  }

  /// Starts listening to GNSS satellite status updates.
  /// raw_gnss provides SVIDs, SNR, elevation, azimuth, and fix flags.
  void _startSatelliteUpdates() {
    _gnssSubscription = RawGnss().gnssStatusEvents.listen(
      (GnssStatusModel statusModel) {
        final satellites = statusModel.status ?? [];
        // Map each Status to our SatelliteInfo model
        final mappedSats = satellites.map((sat) {
          return SatelliteInfo(
            svid: sat.svid ?? 0,
            constellation: _mapConstellation(sat.constellationType),
            snr: sat.cn0DbHz ?? 0.0, // Carrier-to-noise density in dB-Hz
            elevation: sat.elevationDegrees ?? 0.0,
            azimuth: sat.azimuthDegrees ?? 0.0,
            usedInFix: sat.usedInFix ?? false,
          );
        }).toList();

        // Sort: used-in-fix first, then by SNR descending
        mappedSats.sort((a, b) {
          if (a.usedInFix != b.usedInFix) {
            return a.usedInFix ? -1 : 1;
          }
          return b.snr.compareTo(a.snr);
        });

        _satelliteController.add(mappedSats);
      },
      onError: (_) {
        // On error emit empty list — UI handles the "no data" state
        _satelliteController.add([]);
      },
    );
  }

  /// Maps the platform constellation integer code to our ConstellationType enum.
  /// Android constellation type constants are defined in GnssStatus:
  /// 1=GPS, 2=SBAS, 3=GLONASS, 4=QZSS, 5=BeiDou, 6=Galileo, 7=IRNSS
  ConstellationType _mapConstellation(int? type) {
    switch (type) {
      case 1:
        return ConstellationType.gps;
      case 3:
        return ConstellationType.glonass;
      case 5:
        return ConstellationType.beidou;
      case 6:
        return ConstellationType.galileo;
      case 4:
        return ConstellationType.qzss;
      case 2:
        return ConstellationType.sbas;
      default:
        return ConstellationType.unknown;
    }
  }

  /// Stops all location and satellite streams
  void stopUpdates() {
    _positionSubscription?.cancel();
    _gnssSubscription?.cancel();
    _positionSubscription = null;
    _gnssSubscription = null;
    _isTracking = false;
  }

  /// Calculates the Haversine distance (meters) between two lat/lng points.
  /// Used by the provider to compute total path distance during tracking.
  static double haversineDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const R = 6371000.0; // Earth radius in meters
    final phi1 = lat1 * math.pi / 180;
    final phi2 = lat2 * math.pi / 180;
    final dPhi = (lat2 - lat1) * math.pi / 180;
    final dLambda = (lon2 - lon1) * math.pi / 180;

    final a = math.sin(dPhi / 2) * math.sin(dPhi / 2) +
        math.cos(phi1) * math.cos(phi2) *
            math.sin(dLambda / 2) * math.sin(dLambda / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  /// Requests location permission. Returns true if granted.
  static Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  void dispose() {
    stopUpdates();
    _positionController.close();
    _satelliteController.close();
  }
}
