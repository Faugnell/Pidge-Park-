import 'package:flutter/material.dart';

import 'collection/pigeon_collection_controller.dart';
import 'game/game_controller.dart';
import 'game/achievement_controller.dart';
import 'game/friendship_activity_controller.dart';
import 'game/visit_journal_controller.dart';
import 'game/decoration_controller.dart';
import 'game/daily_challenge_controller.dart';
import 'game/daily_gift_controller.dart';
import 'notifications/local_notification_service.dart';
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
    this.decorationController,
    this.dailyChallengeController,
    this.dailyGiftController,
    this.notificationService,
    this.friendshipActivityController,
    this.minimumSplashDuration = const Duration(milliseconds: 1400),
    this.loadSettings = true,
    this.showDailyGift = true,
    this.showOnboarding,
    this.achievementController,
    this.visitJournalController,
    super.key,
  });

  final SettingsController? settingsController;
  final PigeonCollectionController? pigeonCollectionController;
  final GameController? gameController;
  final DecorationController? decorationController;
  final DailyChallengeController? dailyChallengeController;
  final DailyGiftController? dailyGiftController;
  final LocalNotificationService? notificationService;
  final FriendshipActivityController? friendshipActivityController;
  final Duration minimumSplashDuration;
  final bool loadSettings;
  final bool showDailyGift;
  final bool? showOnboarding;
  final AchievementController? achievementController;
  final VisitJournalController? visitJournalController;

  @override
  State<PidgeParkApp> createState() => _PidgeParkAppState();
}

class _PidgeParkAppState extends State<PidgeParkApp> {
  late final SettingsController _settingsController;
  late final PigeonCollectionController _pigeonCollectionController;
  late final GameController _gameController;
  late final DecorationController _decorationController;
  late final DailyChallengeController _dailyChallengeController;
  late final DailyGiftController _dailyGiftController;
  late final LocalNotificationService _notificationService;
  late final FriendshipActivityController _friendshipActivityController;
  late final AchievementController _achievementController;
  late final VisitJournalController _visitJournalController;
  late final Future<void> _initialization;
  late final bool _ownsController;
  late final bool _ownsPigeonController;
  late final bool _ownsGameController;
  late final bool _ownsDecorationController;
  late final bool _ownsDailyController;
  late final bool _ownsDailyGiftController;
  late final bool _ownsNotificationService;
  late final bool _ownsFriendshipActivityController;
  late final bool _ownsAchievementController;
  late final bool _ownsVisitJournalController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.settingsController == null;
    _ownsPigeonController = widget.pigeonCollectionController == null;
    _ownsGameController = widget.gameController == null;
    _ownsDecorationController = widget.decorationController == null;
    _ownsDailyController = widget.dailyChallengeController == null;
    _ownsDailyGiftController = widget.dailyGiftController == null;
    _ownsNotificationService = widget.notificationService == null;
    _ownsFriendshipActivityController =
        widget.friendshipActivityController == null;
    _ownsAchievementController = widget.achievementController == null;
    _ownsVisitJournalController = widget.visitJournalController == null;
    _settingsController = widget.settingsController ?? SettingsController();
    _pigeonCollectionController =
        widget.pigeonCollectionController ?? PigeonCollectionController();
    _gameController = widget.gameController ?? GameController();
    _decorationController =
        widget.decorationController ??
        DecorationController(persistChanges: widget.loadSettings);
    _dailyChallengeController =
        widget.dailyChallengeController ??
        DailyChallengeController(persistChanges: widget.loadSettings);
    _dailyGiftController =
        widget.dailyGiftController ??
        DailyGiftController(persistChanges: widget.loadSettings);
    _notificationService =
        widget.notificationService ??
        LocalNotificationService(useNativePlugin: widget.loadSettings);
    _friendshipActivityController =
        widget.friendshipActivityController ??
        FriendshipActivityController(persistChanges: widget.loadSettings);
    _achievementController =
        widget.achievementController ??
        AchievementController(persistChanges: widget.loadSettings);
    _visitJournalController =
        widget.visitJournalController ??
        VisitJournalController(persistChanges: widget.loadSettings);
    _initialization = _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([
      if (widget.loadSettings) _settingsController.load(),
      if (widget.loadSettings) _pigeonCollectionController.load(),
      if (widget.loadSettings) _gameController.load(),
      if (widget.loadSettings) _decorationController.load(),
      if (widget.loadSettings) _dailyChallengeController.load(),
      if (widget.loadSettings) _dailyGiftController.load(),
      if (widget.loadSettings) _friendshipActivityController.load(),
      if (widget.loadSettings) _achievementController.load(),
      if (widget.loadSettings) _visitJournalController.load(),
      Future<void>.delayed(widget.minimumSplashDuration),
    ]);
    await _notificationService.initialize();
    await _synchronizeNotifications();
  }

  Future<void> _synchronizeNotifications() {
    return _notificationService.synchronize(
      enabled: _settingsController.notificationsEnabled,
      isFrench: _settingsController.isFrench,
      game: _gameController,
      challenge: _dailyChallengeController,
      gift: _dailyGiftController,
      friendshipActivity: _friendshipActivityController,
    );
  }

  @override
  void dispose() {
    if (_ownsController) _settingsController.dispose();
    if (_ownsPigeonController) _pigeonCollectionController.dispose();
    if (_ownsGameController) _gameController.dispose();
    if (_ownsDecorationController) _decorationController.dispose();
    if (_ownsDailyController) _dailyChallengeController.dispose();
    if (_ownsDailyGiftController) _dailyGiftController.dispose();
    if (_ownsNotificationService) _notificationService.dispose();
    if (_ownsFriendshipActivityController) {
      _friendshipActivityController.dispose();
    }
    if (_ownsAchievementController) _achievementController.dispose();
    if (_ownsVisitJournalController) _visitJournalController.dispose();
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
                decorationController: _decorationController,
                dailyChallengeController: _dailyChallengeController,
                dailyGiftController: _dailyGiftController,
                notificationService: _notificationService,
                friendshipActivityController: _friendshipActivityController,
                showDailyGift: widget.showDailyGift,
                showOnboarding: widget.showOnboarding ?? widget.loadSettings,
                achievementController: _achievementController,
                visitJournalController: _visitJournalController,
              );
            },
          ),
        );
      },
    );
  }
}
