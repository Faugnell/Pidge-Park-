import 'dart:async';

import 'package:flutter/material.dart';

import '../collection/pigeon_collection_controller.dart';
import '../game/game_controller.dart';
import '../game/decoration_controller.dart';
import '../game/daily_challenge_controller.dart';
import '../game/daily_gift_controller.dart';
import '../notifications/local_notification_service.dart';
import '../settings/settings_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_navigation.dart';
import 'park_screen.dart';
import 'decorations_screen.dart';
import 'daily_challenge_screen.dart';
import 'pigeondex_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';
import 'treasures_screen.dart';

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

  Future<void> _synchronizeNotifications() {
    return notificationService.synchronize(
      enabled: settingsController.notificationsEnabled,
      isFrench: settingsController.isFrench,
      game: gameController,
      challenge: dailyChallengeController,
      gift: dailyGiftController,
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
        onOpenDecorations: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DecorationsScreen(
                controller: widget.decorationController,
                gameController: widget.gameController,
                isFrench: isFrench,
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
        isFrench: isFrench,
      ),
      TreasuresScreen(
        collectionController: widget.pigeonCollectionController,
        isFrench: isFrench,
      ),
      SettingsScreen(
        controller: widget.settingsController,
        onResetProgress: () async {
          await widget.pigeonCollectionController.resetAllData();
          await widget.gameController.resetAllData();
          await widget.decorationController.resetAllData();
          await widget.dailyChallengeController.resetAllData();
          await widget.dailyGiftController.resetAllData();
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
}
