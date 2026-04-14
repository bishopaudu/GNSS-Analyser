# GNSS Analyzer

A professional GPS/GNSS diagnostic tool for Android, built with Flutter.
Inspired by GPSTest — visualizes satellite signals, fix quality, and path tracking in real time.

---

## Features

| Section | Description |
|---|---|
| **Current Position** | Live lat/lng, altitude, accuracy, speed, heading — updates every second |
| **Satellite Dashboard** | Total visible, satellites used in fix, average SNR, constellation breakdown |
| **Signal Chart** | Animated horizontal bar chart per satellite (SNR dB-Hz) |
| **Satellite List** | Table of all satellites: ID, constellation, signal bars, fix status |
| **Map View** | Current position with accuracy circle + path drawing (OSM-ready) |
| **Path Tracking** | FAB to record GPS path, compute total distance |

---

## Project Structure

```
lib/
├── main.dart                        # App entry point, Provider setup
├── models/
│   ├── gps_position.dart            # Position data model
│   └── satellite_info.dart          # Satellite + constellation model
├── services/
│   └── gps_service.dart             # Geolocator + flutter_gnss_status streams
├── providers/
│   └── gnss_provider.dart           # ChangeNotifier state manager
├── screens/
│   ├── home_screen.dart             # Main dashboard screen
│   └── permission_screen.dart       # First-launch permission flow
├── widgets/
│   ├── section_card.dart            # Reusable dark card container
│   ├── position_section.dart        # Section 1 — Current Position
│   ├── satellite_dashboard_section.dart  # Section 3 — Stats
│   ├── satellite_list_section.dart  # Section 2 — Satellite table
│   ├── map_section.dart             # Section 4 — Map view
│   └── signal_chart_section.dart    # Signal strength bars
└── utils/
    └── app_theme.dart               # Dark theme, colors, typography
```

---

## Setup & Installation

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Android Studio or VS Code with Flutter extension
- Android device or emulator with GPS hardware (emulator has limited GNSS support)

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Run on Android

```bash
flutter run
```

### 3. Enable live OpenStreetMap tiles (optional)

The map section currently shows a styled placeholder with path visualization.
To enable real OSM tiles:

1. Add to `pubspec.yaml`:
   ```yaml
   flutter_map: ^7.0.2
   latlong2: ^0.9.1
   ```

2. Run `flutter pub get`

3. In `lib/widgets/map_section.dart`, replace `_MapPlaceholder` with the
   `FlutterMap` widget shown in the inline comment block.

---

## Android Permissions

The following permissions are declared in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

The app requests `ACCESS_FINE_LOCATION` at runtime on first launch.
`ACCESS_BACKGROUND_LOCATION` is required for tracking when the app is backgrounded
(Android 10+ requires a separate runtime prompt).

---

## How It Works

### Location Updates (`gps_service.dart`)
- Uses `geolocator` with `LocationAccuracy.bestForNavigation`
- `distanceFilter: 0` ensures every position update is delivered
- `intervalDuration: Duration(seconds: 1)` targets 1 Hz updates
- Position objects are mapped to `GpsPosition` models and broadcast via a `StreamController`

### Satellite Data (`gps_service.dart`)
- Uses `flutter_gnss_status` which wraps Android's `GnssStatus.Callback`
- Each `GnssSatellite` provides: SVID, constellation type, C/N₀ (dB-Hz), elevation, azimuth, used-in-fix flag
- Constellation integers follow Android's `GnssStatus` constants:
  `1=GPS, 3=GLONASS, 4=QZSS, 5=BeiDou, 6=Galileo`
- Satellites are sorted: used-in-fix first, then by SNR descending

### State Management (`gnss_provider.dart`)
- `GnssProvider` extends `ChangeNotifier` and is provided at the root via `Provider`
- Widgets use `context.select<GnssProvider, T>()` for fine-grained rebuilds
- Path tracking accumulates Haversine distances between successive position fixes

### Distance Calculation
The Haversine formula is used for accurate great-circle distance between GPS coordinates:
```
a = sin²(Δlat/2) + cos(lat1)·cos(lat2)·sin²(Δlon/2)
d = 2R·atan2(√a, √(1−a))
```

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `geolocator` | ^12.0.0 | GPS position stream |
| `flutter_gnss_status` | ^0.0.2 | GNSS satellite status |
| `provider` | ^6.1.2 | State management |
| `permission_handler` | ^11.3.1 | Runtime permission requests |

---

## Notes

- **Real device recommended**: Android emulators provide simulated GPS but no real GNSS satellite data. Test on a physical Android device for full satellite visibility.
- **minSdk 23**: Required by `flutter_gnss_status` (Android 7.0+).
- **SNR units**: The app displays C/N₀ (carrier-to-noise density) in dB-Hz, which is the standard metric for GNSS signal quality. Typical range: 0–55 dB-Hz.
