// Represents the current GPS/GNSS position data from the geolocator 

class GpsPosition {
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy; // Horizontal accuracy in meters
  final double speed; // Speed in m/s (meters per second)
  final double heading; // Heading/bearing in degrees (0-360)
  final DateTime timestamp;

  const GpsPosition({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    required this.speed,
    required this.heading,
    required this.timestamp,
  });

  /// Converts speed from m/s to km/h
  double get speedKmh => speed * 3.6;

  /// Returns a human-readable cardinal direction from heading
  String get headingDirection {
    if (heading >= 337.5 || heading < 22.5) return 'N';
    if (heading < 67.5) return 'NE';
    if (heading < 112.5) return 'E';
    if (heading < 157.5) return 'SE';
    if (heading < 202.5) return 'S';
    if (heading < 247.5) return 'SW';
    if (heading < 292.5) return 'W';
    return 'NW';
  }

  factory GpsPosition.empty() => GpsPosition(
        latitude: 0.0,
        longitude: 0.0,
        altitude: 0.0,
        accuracy: 0.0,
        speed: 0.0,
        heading: 0.0,
        timestamp: DateTime.now(),
      );
}
