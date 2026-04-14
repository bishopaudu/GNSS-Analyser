// Central state manager for all GNSS data.
// Uses ChangeNotifier + Provider pattern so widgets rebuild only when needed.

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/gps_position.dart';
import '../models/satellite_info.dart';
import '../services/gps_service.dart';

class GnssProvider extends ChangeNotifier {
  final GpsService _gpsService = GpsService();

  // --- Current position state ---
  GpsPosition _currentPosition = GpsPosition.empty();
  GpsPosition get currentPosition => _currentPosition;

  // --- Satellite state ---
  List<SatelliteInfo> _satellites = [];
  List<SatelliteInfo> get satellites => _satellites;

  // Derived satellite statistics
  int get totalSatellites => _satellites.length;
  int get satellitesUsedInFix =>
      _satellites.where((s) => s.usedInFix).length;
  double get averageSignalStrength {
    final visible = _satellites.where((s) => s.snr > 0).toList();
    if (visible.isEmpty) return 0;
    return visible.map((s) => s.snr).reduce((a, b) => a + b) / visible.length;
  }

  // --- Tracking state ---
  bool _isTracking = false;
  bool get isTracking => _isTracking;

  // Path points recorded during active tracking session
  final List<GpsPosition> _trackingPath = [];
  List<GpsPosition> get trackingPath => List.unmodifiable(_trackingPath);

  // Total distance traveled in meters
  double _totalDistance = 0.0;
  double get totalDistance => _totalDistance;

  // Permission and service status
  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Stream subscriptions kept for clean disposal
  StreamSubscription<GpsPosition>? _positionSub;
  StreamSubscription<List<SatelliteInfo>>? _satelliteSub;

  /// Called on app startup — requests permissions then starts updates
  Future<void> initialize() async {
    _hasPermission = await GpsService.requestPermission();
    if (!_hasPermission) {
      _errorMessage = 'Location permission denied. Please enable it in Settings.';
      notifyListeners();
      return;
    }

    _isInitialized = true;
    _errorMessage = null;

    // Subscribe to position updates from GpsService
    _positionSub = _gpsService.positionStream.listen((pos) {
      // If tracking, record the point and accumulate distance
      if (_isTracking) {
        if (_trackingPath.isNotEmpty) {
          _totalDistance += GpsService.haversineDistance(
            _trackingPath.last.latitude,
            _trackingPath.last.longitude,
            pos.latitude,
            pos.longitude,
          );
        }
        _trackingPath.add(pos);
      }
      _currentPosition = pos;
      notifyListeners();
    });

    // Subscribe to satellite status updates from GpsService
    _satelliteSub = _gpsService.satelliteStream.listen((sats) {
      _satellites = sats;
      notifyListeners();
    });

    _gpsService.startPositionUpdates();
    notifyListeners();
  }

  /// Begins a new tracking session — records path and computes distance
  void startTracking() {
    if (!_isInitialized) return;
    _isTracking = true;
    _trackingPath.clear();
    _totalDistance = 0.0;
    // Seed the path with the current position so the line starts immediately
    if (_currentPosition.latitude != 0) {
      _trackingPath.add(_currentPosition);
    }
    notifyListeners();
  }

  /// Stops the tracking session — path remains for review
  void stopTracking() {
    _isTracking = false;
    notifyListeners();
  }

  /// Returns satellites filtered by constellation type
  List<SatelliteInfo> getSatellitesByConstellation(ConstellationType type) =>
      _satellites.where((s) => s.constellation == type).toList();

  /// Returns the count of each constellation type as a map
  Map<ConstellationType, int> get constellationCounts {
    final counts = <ConstellationType, int>{};
    for (final sat in _satellites) {
      counts[sat.constellation] = (counts[sat.constellation] ?? 0) + 1;
    }
    return counts;
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _satelliteSub?.cancel();
    _gpsService.dispose();
    super.dispose();
  }
}
