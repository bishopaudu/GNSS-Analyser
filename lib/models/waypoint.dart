// models/waypoint.dart
// Represents a user-saved named location (pin dropped on the map).

class Waypoint {
  final String id;           // Unique ID — timestamp-based string
  final String name;         // User-supplied name
  final double latitude;
  final double longitude;
  final double? altitude;    // Altitude at the time of drop (optional)
  final String? address;     // Reverse-geocoded address snapshot at drop time
  final DateTime createdAt;

  const Waypoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.address,
    required this.createdAt,
  });

  /// Creates a Waypoint from a JSON map (for shared_preferences deserialization).
  factory Waypoint.fromJson(Map<String, dynamic> json) {
    return Waypoint(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: json['altitude'] != null
          ? (json['altitude'] as num).toDouble()
          : null,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Converts to a JSON map for persistence.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Formatted coordinate string for display.
  String get coordString =>
      '${latitude.toStringAsFixed(5)}°, ${longitude.toStringAsFixed(5)}°';
}
