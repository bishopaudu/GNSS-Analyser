// providers/waypoint_provider.dart
// Manages saved waypoints — CRUD operations + shared_preferences persistence.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/waypoint.dart';

class WaypointProvider extends ChangeNotifier {
  static const _prefsKey = 'gnss_analyzer_waypoints';

  List<Waypoint> _waypoints = [];
  List<Waypoint> get waypoints => List.unmodifiable(_waypoints);

  WaypointProvider() {
    _load();
  }

  // ---------------------------------------------------------------------------
  // Public API

  /// Adds a new waypoint and persists the list.
  Future<void> addWaypoint(Waypoint waypoint) async {
    _waypoints = [waypoint, ..._waypoints]; // Prepend so newest is first
    notifyListeners();
    await _save();
  }

  /// Deletes a waypoint by ID and persists the updated list.
  Future<void> deleteWaypoint(String id) async {
    _waypoints = _waypoints.where((w) => w.id != id).toList();
    notifyListeners();
    await _save();
  }

  // ---------------------------------------------------------------------------
  // Persistence

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final list = jsonDecode(raw) as List<dynamic>;
      _waypoints = list
          .map((e) => Waypoint.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {
      // Corrupt prefs — start fresh
      _waypoints = [];
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(_waypoints.map((w) => w.toJson()).toList());
      await prefs.setString(_prefsKey, raw);
    } catch (_) {
      // Ignore persistence errors — data in memory remains correct
    }
  }
}
