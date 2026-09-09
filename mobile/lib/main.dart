import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'settings/settings_controller.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PidgeParkApp());
}

class PidgeParkApp extends StatefulWidget {
  const PidgeParkApp({
    this.settingsController,
    this.minimumSplashDuration = const Duration(milliseconds: 1400),
    this.loadSettings = true,
    super.key,
  });

  final SettingsController? settingsController;
  final Duration minimumSplashDuration;
  final bool loadSettings;

  @override
  State<PidgeParkApp> createState() => _PidgeParkAppState();
}

class _PidgeParkAppState extends State<PidgeParkApp> {
  late final SettingsController _settingsController;
  late final Future<void> _initialization;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.settingsController == null;
    _settingsController = widget.settingsController ?? SettingsController();
    _initialization = Future.wait([
      if (widget.loadSettings) _settingsController.load(),
      Future<void>.delayed(widget.minimumSplashDuration),
    ]);
  }

  @override
  void dispose() {
    if (_ownsController) _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settingsController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Pidge Park!',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: Locale(_settingsController.isFrench ? 'fr' : 'en'),
          home: FutureBuilder<void>(
            future: _initialization,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SplashScreen();
              }

              return HomeScreen(settingsController: _settingsController);
            },
          ),
        );
      },
    );
  }
}
