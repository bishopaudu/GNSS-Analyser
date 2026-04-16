<div align="center">

# 🛰 GNSS Analyzer

### A Professional GPS/GNSS Diagnostic Tool for Android

*Visualize satellite signals, track location accuracy, map your path, and inspect every GNSS constellation — in real time.*

---

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)
![Version](https://img.shields.io/badge/Version-1.0.0-blue)

</div>

---

## Overview

GNSS Analyzer is a Flutter-based diagnostic application for Android that surfaces raw GNSS data from the device chipset. Inspired by GPSTest, it provides a professional dark-themed UI across multiple screens: a live dashboard, an animated satellite radar view, a real OpenStreetMap map with path tracking, and an educational glossary — all running at 1 Hz refresh using Android's native `GnssStatus.Callback` API.

It uses a locally patched version of the `raw_gnss` plugin (`local_packages/raw_gnss`) to correctly stream satellite data on physical Android hardware.

---

## Screenshots

> Install on a physical Android device for best results — emulators only provide simulated GPS and no real GNSS satellite data.

---

## Features

### 📡 Current Position
- **Live coordinates** updated at ~1 Hz (latitude, longitude to 6 decimal places)
- **Altitude** (metres), **horizontal accuracy** (colour-coded: green ≤5 m, amber ≤15 m, red >15 m)
- **Speed** (km/h) and **heading** (degrees + cardinal direction: N, NE, E …)
- Animated pulsing **LIVE** indicator while data is streaming
- **One-tap location sharing** — generates a Google Maps link with coordinates and posts via the system share sheet

### 🛰 Satellite Dashboard
- **Total visible satellites** across all constellations
- **Satellites used in fix** — satellites actively contributing to position calculation
- **Average Signal-to-Noise Ratio** (C/N₀ in dB-Hz)
- **Fix ratio progress bar** — animated bar showing `used / total`, colour shifts green when >50%
- **Constellation breakdown chips** — per-system satellite counts (GPS · GLONASS · Galileo · BeiDou · QZSS · SBAS), each colour-coded

### 📊 Signal Strength Chart
- Horizontal bar chart, one row per satellite with signal > 0 dB-Hz
- Bars are **colour-coded by constellation** and animate smoothly when SNR updates
- Reference **threshold markers** at 15 / 25 / 35 dB-Hz (poor / fair / good / excellent)
- Numeric SNR value printed at bar end; a ✓ icon marks satellites used in the current fix

### 📋 Satellite List
- Full table of all visible satellites sorted: **used-in-fix first**, then by SNR descending
- Shows: SVID, constellation label, signal quality bars, fix status flag
- Empty state when no satellite data is available

### 🗺 Map View (OpenStreetMap)
- Renders **live OSM raster tiles** via `flutter_map` (no API key required) as soon as a GPS fix is obtained
- **Navigation marker** indicating current position
- **Path polyline** drawn on the map during an active tracking session
- **Distance badge** showing accumulated distance in metres / kilometres (live)
- Falls back to a styled vector grid placeholder while awaiting the first fix

### 🔴 Path Tracking
- **Start / Stop FAB** at the bottom of the home screen triggers a tracking session
- Each incoming position fix is appended to the path; Haversine distance is accumulated between consecutive points
- Path persists on screen after stopping for review

### 🎯 Radar / Skyplot View
- Full-screen **polar plot** — overhead projection of all visible satellites
  - **Azimuth** (compass direction 0°–360°) = angular position around the circle
  - **Elevation** (0°–90°) = radial distance from edge (horizon) to centre (zenith)
- Animated **radar sweep** — a 60° cyan cone rotates at one revolution per 4 seconds
- Satellites rendered as **colour-coded dots** (by constellation); used-in-fix dots have a glowing white border
- Dot size scales with SNR; glow intensity scales with signal strength
- Concentric elevation rings at **0° / 30° / 60°** with N / E / S / W cardinal labels
- **Tap any satellite dot** to open a detail bottom-sheet showing: SVID, constellation, SNR, elevation, azimuth, and fix status
- **Real-time compass heading** displayed above the plot via `flutter_compass`

### 📖 GNSS Glossary
- In-app educational screen accessible from the AppBar
- Plain-English explanations of: SVID/PRN, constellations, SNR (dB-Hz), "used in fix", elevation & azimuth

### 🔐 Permission Onboarding
- Dedicated first-launch screen explaining why each permission is needed before requesting it
- Animated hero icon with glowing border
- Privacy note: *"Location data is processed on-device only and never sent to any server."*
- Automatically skipped on subsequent launches if permission was already granted

---

## Architecture

```
lib/
├── main.dart                        # App entry point — Provider setup, orientation lock,
│                                    # system UI styling, permission-aware routing
│
├── models/
│   ├── gps_position.dart            # GpsPosition — lat/lng/alt/accuracy/speed/heading
│   │                                  Computed: speedKmh, headingDirection (cardinal)
│   └── satellite_info.dart          # SatelliteInfo — svid, constellation, snr,
│                                    # elevation, azimuth, usedInFix, signalQuality (0–4)
│                                    # ConstellationType enum (GPS/GLO/GAL/BDS/QZSS/SBAS/UNK)
│
├── services/
│   └── gps_service.dart             # All platform I/O:
│                                    #  • Geolocator position stream (1 Hz, distanceFilter=0)
│                                    #  • raw_gnss GNSS status stream → SatelliteInfo mapping
│                                    #  • Constellation integer → ConstellationType mapping
│                                    #  • Static haversineDistance() helper
│                                    #  • Static requestPermission() helper
│
├── providers/
│   └── gnss_provider.dart           # GnssProvider (ChangeNotifier):
│                                    #  • Subscribes to both GpsService streams
│                                    #  • Tracks current position, satellites, tracking session
│                                    #  • Derived getters: totalSatellites, satellitesUsedInFix,
│                                    #    averageSignalStrength, constellationCounts
│                                    #  • startTracking() / stopTracking() + path accumulation
│
├── screens/
│   ├── permission_screen.dart       # First-launch permission onboarding UI
│   ├── home_screen.dart             # Main scrollable dashboard + tracking FAB + status dot
│   ├── skyplot_screen.dart          # Full-screen radar view + compass + tap-to-detail sheet
│   └── about_screen.dart           # GNSS Glossary
│
├── widgets/
│   ├── section_card.dart            # Reusable dark card container with title/subtitle/accent
│   ├── position_section.dart        # Section 1 — Current Position + LIVE indicator + share
│   ├── satellite_dashboard_section.dart  # Section 2 — Stats + fix bar + constellation chips
│   ├── signal_chart_section.dart    # Section 3 — Animated SNR bar chart
│   ├── satellite_list_section.dart  # Section 4 — Per-satellite table
│   ├── map_section.dart             # Section 5 — flutter_map OSM + path polyline + badge
│   └── skyplot_view.dart            # Custom painter: radar sweep, grid, satellite dots
│
└── utils/
    └── app_theme.dart               # Design system — palette, typography, constellation colours

local_packages/
└── raw_gnss/                        # Locally patched raw_gnss plugin
                                     # Fixes GnssStatus.Callback registration on physical
                                     # Android devices (hardware GNSS acquisition)
```

---

## Design System

The app uses a unified dark, monospace-forward design language inspired by professional RF and navigation tools.

### Colour Palette

| Token | Hex | Usage |
|---|---|---|
| `background` | `#080C10` | App scaffold |
| `surface` | `#0D1520` | Cards, bottom bar |
| `surfaceElevated` | `#121D2C` | Elevated cards, bottom sheet |
| `surfaceHighlight` | `#1A2840` | Bar tracks, chip backgrounds |
| `border` | `#1E3050` | Card borders, dividers |
| `accentCyan` | `#00D4FF` | Primary accent — position, GPS |
| `accentGreen` | `#00FF9D` | Fix status, tracking active |
| `accentAmber` | `#FFB700` | SNR average, BeiDou, warnings |
| `accentRed` | `#FF3D5A` | Stop tracking, poor accuracy, errors |
| `accentPurple` | `#9B6DFF` | Radar, Galileo, skyplot |

### Constellation Colours

| System | Colour |
|---|---|
| GPS (USA) | Cyan `#00D4FF` |
| GLONASS (Russia) | Orange `#FF6B35` |
| Galileo (EU) | Purple `#9B6DFF` |
| BeiDou (China) | Amber `#FFB700` |
| QZSS (Japan) | Green `#00FF9D` |
| SBAS | Grey `#7A9EC0` |

### Signal Quality Scale

| Level | dB-Hz range | Colour |
|---|---|---|
| 0 — No signal | ≤ 0 | `#3D5A78` |
| 1 — Poor | < 15 | Red `#FF3D5A` |
| 2 — Fair | < 25 | Amber `#FFB700` |
| 3 — Good | < 35 | Cyan `#00D4FF` |
| 4 — Excellent | ≥ 35 | Green `#00FF9D` |

---

## Technical Details

### Location Updates (`gps_service.dart`)

```dart
AndroidSettings(
  accuracy: LocationAccuracy.bestForNavigation,
  distanceFilter: 0,                         // Every update, no movement threshold
  intervalDuration: const Duration(seconds: 1), // ~1 Hz
  forceLocationManager: false,               // Use fused provider for best GNSS data
)
```

### Satellite Data (`raw_gnss`)

- Wraps Android's `GnssStatus.Callback` to deliver per-satellite data via a Dart stream
- Each satellite object provides: **SVID**, **constellation type** (int), **C/N₀** (dB-Hz), **elevation** (°), **azimuth** (°), **usedInFix** flag
- Constellation integers follow Android `GnssStatus` constants:

| Int | Constellation |
|---|---|
| 1 | GPS |
| 2 | SBAS |
| 3 | GLONASS |
| 4 | QZSS |
| 5 | BeiDou |
| 6 | Galileo |
| 7 | IRNSS |

> **Note:** The `raw_gnss` package is used via a **local path override** (`local_packages/raw_gnss`). The upstream pub.dev version did not correctly register the `GnssStatus.Callback` on physical Android hardware. The local copy patches `GnssStatusHandlerImpl.java` and `RawGnssPlugin.java` to resolve this.

### State Management (`gnss_provider.dart`)

- `GnssProvider` extends `ChangeNotifier`, provided at the root
- Widgets use `context.select<GnssProvider, T>()` for fine-grained rebuilds to avoid unnecessary UI redraws
- Path tracking accumulates `GpsPosition` objects and calls `haversineDistance()` between each consecutive pair

### Distance Calculation

The Haversine formula calculates great-circle distance between two WGS-84 coordinates:

```
a = sin²(Δlat/2) + cos(φ₁) · cos(φ₂) · sin²(Δlon/2)
d = 2R · atan2(√a, √(1 − a))     where R = 6,371,000 m
```

### Radar / Skyplot Geometry

Satellite screen position is computed from polar coordinates:

```
r      = plotRadius × (1 − elevation / 90°)   // centre = zenith, edge = horizon
angle  = (azimuth − 90°) × π / 180            // rotate so 0° azimuth = North (top)
x      = centreX + r × cos(angle)
y      = centreY + r × sin(angle)
```

The animated sweep cone uses a `SweepGradient` shader on a rotating canvas arc, driven by an `AnimationController` repeating every 4 seconds.

---

## Setup & Installation

### Prerequisites

| Requirement | Version |
|---|---|
| Flutter SDK | ≥ 3.0.0 |
| Dart SDK | ≥ 3.0.0 |
| Android SDK | API 23+ (Android 7.0+) |
| Physical Android device | **Recommended** — emulators provide no real GNSS data |

### 1. Clone and install dependencies

```bash
git clone <repository-url>
cd gnss_analyzer
flutter pub get
```

### 2. Run on a connected Android device

```bash
flutter run
```

For verbose output (useful for debugging GNSS plugin issues):

```bash
flutter run -v
```

### 3. Build a release APK

```bash
flutter build apk --release
```

---

## Android Configuration

### Permissions (`AndroidManifest.xml`)

```xml
<!-- Required for GPS/GNSS hardware access -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Required for background path recording (Android 10+) -->
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

<!-- Required for OpenStreetMap tile fetching -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- GPS hardware feature declaration (not required — allows non-GPS installs) -->
<uses-feature android:name="android.hardware.location.gps" android:required="false" />
```

The app requests `ACCESS_FINE_LOCATION` at runtime on first launch. `ACCESS_BACKGROUND_LOCATION` is required for GNSS streaming while the app is backgrounded and triggers a separate system prompt on Android 10+.

### Build Configuration

- **`minSdkVersion`**: 23 (Android 7.0 — minimum for `GnssStatus.Callback` API)
- **`targetSdkVersion`**: 34
- Orientation locked to **portrait** via `SystemChrome.setPreferredOrientations`
- **Transparent status bar** with light icons to blend with the dark background

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `geolocator` | `^12.0.0` | GPS position stream via Android Fused Location Provider |
| `raw_gnss` | local override | GNSS satellite status stream (patched for physical devices) |
| `flutter_map` | `^7.0.2` | OpenStreetMap tile rendering — no API key required |
| `latlong2` | `^0.9.1` | Strongly-typed lat/lng coordinate type for flutter_map |
| `flutter_compass` | `^0.8.1` | Real-time device compass heading stream |
| `share_plus` | `^12.0.2` | System share sheet for location sharing |
| `provider` | `^6.1.2` | ChangeNotifier-based state management |
| `permission_handler` | `^11.3.1` | Runtime location permission requests |

### Local Package Override

```yaml
# pubspec.yaml
dependency_overrides:
  raw_gnss:
    path: ./local_packages/raw_gnss
```

The upstream `raw_gnss` package was not correctly acquiring GNSS satellite data on physical Android devices. The local copy patches the Android plugin's Java layer to properly register the `GnssStatus.Callback` with `LocationManager`, enabling real satellite streaming on physical hardware.

---

## Important Notes

- **Real device required**: Android emulators supply only simulated GPS coordinates — no authentic constellation data, SNR values, or satellite geometry is available. All satellite-related screens will show empty or placeholder states on an emulator.
- **SNR units**: The app displays C/N₀ (carrier-to-noise density ratio) in **dB-Hz**, which is the standard GNSS signal quality metric. Typical range on a phone: 0–55 dB-Hz. A value of 35+ dB-Hz is considered excellent.
- **Privacy**: All GNSS and location processing happens entirely **on-device**. No data is transmitted to any remote server. The only network activity is fetching OpenStreetMap raster tiles.
- **Compass availability**: The compass heading on the Skyplot screen requires a physical magnetometer. On devices without one, the heading row is hidden gracefully.

---

## Roadmap

- [ ] Export tracked path as GPX file
- [ ] NMEA sentence logging
- [ ] Per-satellite elevation/SNR history graphs
- [ ] iOS CoreLocation / CoreGNSS support
- [ ] Widget-based lock screen GNSS status tile

---

<div align="center">

Built with Flutter · Powered by Android GNSS APIs · Maps © OpenStreetMap contributors

</div>
