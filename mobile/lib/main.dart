import 'package:flutter/material.dart';

import 'collection/pigeon_collection_controller.dart';
import 'game/game_controller.dart';
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
    this.pigeonCollectionController,
    this.gameController,
    this.minimumSplashDuration = const Duration(milliseconds: 1400),
    this.loadSettings = true,
    super.key,
  });

  final SettingsController? settingsController;
  final PigeonCollectionController? pigeonCollectionController;
  final GameController? gameController;
  final Duration minimumSplashDuration;
  final bool loadSettings;

  @override
  State<PidgeParkApp> createState() => _PidgeParkAppState();
}

class _PidgeParkAppState extends State<PidgeParkApp> {
  late final SettingsController _settingsController;
  late final PigeonCollectionController _pigeonCollectionController;
  late final GameController _gameController;
  late final Future<void> _initialization;
  late final bool _ownsController;
  late final bool _ownsPigeonController;
  late final bool _ownsGameController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.settingsController == null;
    _ownsPigeonController = widget.pigeonCollectionController == null;
    _ownsGameController = widget.gameController == null;
    _settingsController = widget.settingsController ?? SettingsController();
    _pigeonCollectionController =
        widget.pigeonCollectionController ?? PigeonCollectionController();
    _gameController = widget.gameController ?? GameController();
    _initialization = Future.wait([
      if (widget.loadSettings) _settingsController.load(),
      if (widget.loadSettings) _pigeonCollectionController.load(),
      if (widget.loadSettings) _gameController.load(),
      Future<void>.delayed(widget.minimumSplashDuration),
    ]);
  }

  @override
  void dispose() {
    if (_ownsController) _settingsController.dispose();
    if (_ownsPigeonController) _pigeonCollectionController.dispose();
    if (_ownsGameController) _gameController.dispose();
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

              return HomeScreen(
                settingsController: _settingsController,
                pigeonCollectionController: _pigeonCollectionController,
                gameController: _gameController,
              );
            },
          ),
        );
      },
    );
  }
}
