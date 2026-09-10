import 'dart:async';

import 'package:flutter/material.dart';

import '../collection/pigeon_collection_controller.dart';
import '../game/game_controller.dart';
import '../game/visit_journal_controller.dart';
import '../game/achievement_controller.dart';
import '../game/friendship_activity_controller.dart';
import '../game/decoration_controller.dart';
import '../game/daily_challenge_controller.dart';
import '../game/daily_gift_controller.dart';
import '../notifications/local_notification_service.dart';
import '../models/pigeon.dart';
import '../settings/settings_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_navigation.dart';
import 'park_screen.dart';
import 'onboarding_screen.dart';
import 'decorations_screen.dart';
import 'daily_challenge_screen.dart';
import 'pigeondex_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';
import 'treasures_screen.dart';
import 'achievements_screen.dart';
import 'visit_journal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.settingsController,
    required this.pigeonCollectionController,
    required this.gameController,
    required this.decorationController,
    required this.dailyChallengeController,
    required this.dailyGiftController,
    required this.showDailyGift,
    required this.notificationService,
    required this.friendshipActivityController,
    required this.showOnboarding,
    required this.achievementController,
    required this.visitJournalController,
    super.key,
  });

  final SettingsController settingsController;
  final PigeonCollectionController pigeonCollectionController;
  final GameController gameController;
  final DecorationController decorationController;
  final DailyChallengeController dailyChallengeController;
  final DailyGiftController dailyGiftController;
  final bool showDailyGift;
  final LocalNotificationService notificationService;
  final FriendshipActivityController friendshipActivityController;
  final bool showOnboarding;
  final AchievementController achievementController;
  final VisitJournalController visitJournalController;

  Future<void> _synchronizeNotifications() {
    return notificationService.synchronize(
      enabled: settingsController.notificationsEnabled,
      isFrench: settingsController.isFrench,
      game: gameController,
      challenge: dailyChallengeController,
      gift: dailyGiftController,
      friendshipActivity: friendshipActivityController,
    );
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.notificationService.selectedDestination.addListener(
      _onNotificationSelected,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final handledNotification = await _handleSelectedNotification();
      if (!handledNotification && widget.showDailyGift) {
        await _offerDailyGift();
      }
      if (!handledNotification &&
          widget.showOnboarding &&
          !widget.settingsController.onboardingComplete) {
        await _openOnboarding();
      }
    });
  }

  @override
  void dispose() {
    widget.notificationService.selectedDestination.removeListener(
      _onNotificationSelected,
    );
    super.dispose();
  }

  void _onNotificationSelected() {
    unawaited(_handleSelectedNotification());
  }

  Future<bool> _handleSelectedNotification() async {
    if (!mounted) return false;
    final destination = widget.notificationService.takeSelectedDestination();
    if (destination == null) return false;

    Navigator.of(context).popUntil((route) => route.isFirst);
    switch (destination) {
      case 'park':
        setState(() => _selectedIndex = 0);
        break;
      case 'daily_challenge':
        setState(() => _selectedIndex = 0);
        await _openDailyChallenge();
        break;
      case 'daily_gift':
        setState(() => _selectedIndex = 0);
        await _offerDailyGift();
        break;
      default:
        if (destination.startsWith('pigeon_activity:')) {
          final pigeonId = destination.substring('pigeon_activity:'.length);
          final matches = pigeons.where((item) => item.id == pigeonId);
          if (matches.isNotEmpty) {
            setState(() => _selectedIndex = 1);
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PigeonDetailScreen(
                  pigeon: matches.first,
                  controller: widget.pigeonCollectionController,
                  gameController: widget.gameController,
                  activityController: widget.friendshipActivityController,
                  isFrench: widget.settingsController.isFrench,
                  onActivityChanged: widget._synchronizeNotifications,
                  dailyChallengeController: widget.dailyChallengeController,
                  onProgressChanged: _updateAchievements,
                ),
              ),
            );
          }
        }
    }
    return true;
  }

  Future<void> _offerDailyGift() async {
    if (!mounted || !widget.dailyGiftController.isAvailable) return;
    final isFrench = widget.settingsController.isFrench;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        key: const ValueKey('daily-gift-dialog'),
        backgroundColor: AppColors.splashBackground,
        icon: const Icon(
          Icons.card_giftcard,
          size: 54,
          color: AppColors.selected,
        ),
        title: Text(isFrench ? 'Cadeau quotidien !' : 'Daily gift!'),
        content: Text(
          isFrench
              ? 'Voici 100 miettes pour prendre soin de ton parc.'
              : 'Here are 100 crumbs to care for your park.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            key: const ValueKey('claim-daily-gift'),
            onPressed: () async {
              await widget.dailyGiftController.claim(widget.gameController);
              await widget._synchronizeNotifications();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(isFrench ? 'Récupérer 100 🪙' : 'Claim 100 🪙'),
          ),
        ],
      ),
    );
  }

  Future<void> _openDailyChallenge() async {
    await widget.dailyChallengeController.refreshDay();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DailyChallengeScreen(
          controller: widget.dailyChallengeController,
          isFrench: widget.settingsController.isFrench,
          giftController: widget.dailyGiftController,
          gameController: widget.gameController,
          onMissionDayCompleted: () =>
              _updateAchievements(missionDayCompleted: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFrench = widget.settingsController.isFrench;
    final pages = <Widget>[
      ParkScreen(
        gameController: widget.gameController,
        collectionController: widget.pigeonCollectionController,
        isFrench: isFrench,
        onOpenShop: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ShopScreen(
                gameController: widget.gameController,
                isFrench: isFrench,
              ),
            ),
          );
        },
        decorationController: widget.decorationController,
        dailyChallengeController: widget.dailyChallengeController,
        onGameStateChanged: widget._synchronizeNotifications,
        onAchievementEvent: _updateAchievements,
        visitJournalController: widget.visitJournalController,
        onOpenJournal: _openVisitJournal,
        friendshipActivityController: widget.friendshipActivityController,
        onOpenActivityPigeon: _openActiveActivityPigeon,
        onOpenDecorations: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DecorationsScreen(
                controller: widget.decorationController,
                gameController: widget.gameController,
                isFrench: isFrench,
                onChanged: _updateAchievements,
              ),
            ),
          );
        },
        onOpenDailyChallenge: () {
          _openDailyChallenge();
        },
      ),
      PigeondexScreen(
        controller: widget.pigeonCollectionController,
        gameController: widget.gameController,
        activityController: widget.friendshipActivityController,
        dailyChallengeController: widget.dailyChallengeController,
        isFrench: isFrench,
        onActivityChanged: widget._synchronizeNotifications,
        onProgressChanged: _updateAchievements,
      ),
      TreasuresScreen(
        collectionController: widget.pigeonCollectionController,
        isFrench: isFrench,
      ),
      SettingsScreen(
        controller: widget.settingsController,
        onReplayTutorial: () => _openOnboarding(allowDismiss: true),
        onOpenAchievements: _openAchievements,
        onResetProgress: () async {
          await widget.pigeonCollectionController.resetAllData();
          await widget.gameController.resetAllData();
          await widget.decorationController.resetAllData();
          await widget.dailyChallengeController.resetAllData();
          await widget.dailyGiftController.resetAllData();
          await widget.friendshipActivityController.resetAllData();
          await widget.achievementController.resetAllData();
          await widget.visitJournalController.resetAllData();
          await widget.notificationService.cancelAll();
        },
        onNotificationsChanged: (enabled) async {
          if (!enabled) {
            await widget.settingsController.setNotificationsEnabled(false);
            await widget.notificationService.cancelAll();
            return;
          }
          final granted = await widget.notificationService.requestPermission();
          await widget.settingsController.setNotificationsEnabled(granted);
          await widget._synchronizeNotifications();
          if (!granted && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isFrench
                      ? 'Autorisation refusée dans les réglages du téléphone.'
                      : 'Permission denied in the phone settings.',
                ),
              ),
            );
          }
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: _selectedIndex,
        isFrench: isFrench,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  Future<void> _openActiveActivityPigeon() async {
    final pigeonId = widget.friendshipActivityController.activePigeonId;
    if (pigeonId == null || !mounted) return;
    final matches = pigeons.where((item) => item.id == pigeonId);
    if (matches.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PigeonDetailScreen(
          pigeon: matches.first,
          controller: widget.pigeonCollectionController,
          gameController: widget.gameController,
          activityController: widget.friendshipActivityController,
          isFrench: widget.settingsController.isFrench,
          onActivityChanged: widget._synchronizeNotifications,
          dailyChallengeController: widget.dailyChallengeController,
          onProgressChanged: _updateAchievements,
        ),
      ),
    );
  }

  Future<void> _openOnboarding({bool allowDismiss = false}) async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => OnboardingScreen(
          isFrench: widget.settingsController.isFrench,
          allowDismiss: allowDismiss,
          onComplete: widget.settingsController.completeOnboarding,
        ),
      ),
    );
  }

  Future<void> _updateAchievements({
    String? foodId,
    bool flockWelcomed = false,
    bool missionDayCompleted = false,
  }) async {
    final unlocked = await widget.achievementController.update(
      foodId: foodId,
      flockWelcomed: flockWelcomed,
      missionDayCompleted: missionDayCompleted,
      collection: widget.pigeonCollectionController,
      decorations: widget.decorationController,
    );
    if (unlocked.isEmpty) return;
    await widget.gameController.addReward(
      crumbs: 0,
      feathers: unlocked.fold(0, (sum, item) => sum + item.feathers),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.settingsController.isFrench
              ? 'Succès débloqué ! +${unlocked.fold(0, (sum, item) => sum + item.feathers)} plumes'
              : 'Achievement unlocked! +${unlocked.fold(0, (sum, item) => sum + item.feathers)} feathers',
        ),
      ),
    );
  }

  Future<void> _openAchievements() async {
    await _updateAchievements();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AchievementsScreen(
          controller: widget.achievementController,
          collection: widget.pigeonCollectionController,
          decorations: widget.decorationController,
          isFrench: widget.settingsController.isFrench,
        ),
      ),
    );
  }

  void _openVisitJournal() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VisitJournalScreen(
          controller: widget.visitJournalController,
          isFrench: widget.settingsController.isFrench,
          onOpenPigeon: _openPigeon,
        ),
      ),
    );
  }

  void _openPigeon(Pigeon pigeon) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PigeonDetailScreen(
          pigeon: pigeon,
          controller: widget.pigeonCollectionController,
          gameController: widget.gameController,
          activityController: widget.friendshipActivityController,
          isFrench: widget.settingsController.isFrench,
          onActivityChanged: widget._synchronizeNotifications,
          dailyChallengeController: widget.dailyChallengeController,
          onProgressChanged: _updateAchievements,
        ),
      ),
    );
  }
}
