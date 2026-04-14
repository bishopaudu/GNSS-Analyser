// main.dart
// App entry point. Sets up Provider state management and routes to the correct screen
// based on whether location permission has been granted.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/gnss_provider.dart';
import 'services/gps_service.dart';
import 'screens/home_screen.dart';
import 'screens/permission_screen.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation for the diagnostic dashboard
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar to blend with dark background
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    // Provide GnssProvider at the root so all descendants can access it
    ChangeNotifierProvider(
      create: (_) => GnssProvider(),
      child: const GnssAnalyzerApp(),
    ),
  );
}

class GnssAnalyzerApp extends StatelessWidget {
  const GnssAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GNSS Analyzer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const _AppRoot(),
    );
  }
}

/// Root widget that decides whether to show the permission screen or main app.
/// Listens to GnssProvider.isInitialized to route appropriately.
class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  @override
  void initState() {
    super.initState();
    // Check if permission is already granted and auto-initialize
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<GnssProvider>();
      final alreadyGranted = await GpsService.requestPermission().catchError(
        (_) => false,
      );
      if (alreadyGranted) {
        await provider.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isInitialized =
        context.select<GnssProvider, bool>((p) => p.isInitialized);

    // Animated transition between permission screen and main app
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: isInitialized
          ? const HomeScreen(key: ValueKey('home'))
          : const PermissionScreen(key: ValueKey('permission')),
    );
  }
}
