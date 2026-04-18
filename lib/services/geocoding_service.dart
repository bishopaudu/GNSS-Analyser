// services/geocoding_service.dart
// Reverse geocoding via OSM Nominatim — no API key required.
// Converts a lat/lng pair into a human-readable address string.

import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  // Nominatim usage policy: max 1 req/sec, must identify the app via User-Agent.
  static const _userAgent = 'GNSSAnalyzer/1.0 (Flutter diagnostic app)';

  /// Fetches a short address string for the given coordinates.
  /// Returns null on any network or parse failure — callers must handle null gracefully.
  static Future<String?> fetchAddress(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json&lat=$lat&lon=$lng&zoom=16&addressdetails=1',
      );

      final response = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _formatAddress(data);
    } catch (_) {
      // Network error, timeout, or JSON parse error — fail silently
      return null;
    }
  }

  /// Picks the most useful parts out of the Nominatim response.
  /// Prefers road + suburb/neighbourhood + city, falling back to display_name.
  static String? _formatAddress(Map<String, dynamic> data) {
    final address = data['address'] as Map<String, dynamic>?;
    if (address == null) {
      // Fall back to full display_name, truncated
      final display = data['display_name'] as String?;
      if (display == null) return null;
      final parts = display.split(',');
      return parts.take(3).map((p) => p.trim()).join(', ');
    }

    final parts = <String>[];

    // Road / building
    final road = address['road'] as String? ??
        address['pedestrian'] as String? ??
        address['path'] as String?;
    if (road != null) parts.add(road);

    // Neighbourhood / suburb
    final neighbourhood = address['neighbourhood'] as String? ??
        address['suburb'] as String? ??
        address['village'] as String?;
    if (neighbourhood != null) parts.add(neighbourhood);

    // City / town
    final city = address['city'] as String? ??
        address['town'] as String? ??
        address['municipality'] as String?;
    if (city != null) parts.add(city);

    if (parts.isEmpty) {
      // Last resort — first 3 components of display_name
      final display = data['display_name'] as String?;
      if (display == null) return null;
      return display.split(',').take(3).map((p) => p.trim()).join(', ');
    }

    return parts.join(', ');
  }
}
