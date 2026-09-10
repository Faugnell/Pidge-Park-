import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pidge_park_app/collection/pigeon_collection_controller.dart';
import 'package:pidge_park_app/game/game_controller.dart';
import 'package:pidge_park_app/game/achievement_controller.dart';
import 'package:pidge_park_app/game/friendship_activity_controller.dart';
import 'package:pidge_park_app/game/visit_journal_controller.dart';
import 'package:pidge_park_app/game/decoration_controller.dart';
import 'package:pidge_park_app/game/daily_challenge_controller.dart';
import 'package:pidge_park_app/game/daily_cycle.dart';
import 'package:pidge_park_app/game/daily_gift_controller.dart';
import 'package:pidge_park_app/main.dart';
import 'package:pidge_park_app/models/decoration.dart';
import 'package:pidge_park_app/models/food.dart';
import 'package:pidge_park_app/models/pigeon.dart';
import 'package:pidge_park_app/notifications/local_notification_service.dart';
import 'package:pidge_park_app/settings/settings_controller.dart';
import 'package:pidge_park_app/screens/achievements_screen.dart';

void main() {
  testWidgets('shows the splash screen while the app initializes', (
    tester,
  ) async {
    final controller = SettingsController(persistChanges: false);
    final pigeonController = PigeonCollectionController(persistChanges: false);
    final gameController = GameController(persistChanges: false);
    await tester.pumpWidget(
      PidgeParkApp(
        settingsController: controller,
        pigeonCollectionController: pigeonController,
        gameController: gameController,
        minimumSplashDuration: const Duration(milliseconds: 200),
        loadSettings: false,
        showDailyGift: false,
      ),
    );

    expect(find.text('Pidge Park!'), findsOneWidget);
    expect(find.text('a cosy game'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    expect(
      find.text('Le parc attend ses prochains visiteurs.'),
      findsOneWidget,
    );
    final parkPigeons = find.byWidgetPredicate(
      (widget) => widget.key?.toString().contains('park-pigeon-') ?? false,
    );
    expect(parkPigeons.evaluate().length, inInclusiveRange(3, 4));
    controller.dispose();
    pigeonController.dispose();
    gameController.dispose();
  });

  testWidgets('shows and completes the onboarding once', (tester) async {
    final controller = SettingsController(persistChanges: false);
    final pigeonController = PigeonCollectionController(persistChanges: false);
    final gameController = GameController(persistChanges: false);
    await tester.pumpWidget(
      PidgeParkApp(
        settingsController: controller,
        pigeonCollectionController: pigeonController,
        gameController: gameController,
        minimumSplashDuration: Duration.zero,
        loadSettings: false,
        showDailyGift: false,
        showOnboarding: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('onboarding-screen')), findsOneWidget);
    expect(find.text('Bienvenue à Pidge Park !'), findsOneWidget);
    for (var index = 0; index < 4; index++) {
      await tester.tap(find.byKey(const ValueKey('next-onboarding')));
      await tester.pumpAndSettle();
    }
    expect(find.text('À demain ?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('finish-onboarding')));
    await tester.pumpAndSettle();

    expect(controller.onboardingComplete, isTrue);
    expect(find.byKey(const ValueKey('onboarding-screen')), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    pigeonController.dispose();
    gameController.dispose();
  });

  testWidgets('navigates between the main sections and opens the shop', (
    tester,
  ) async {
    final controller = SettingsController(persistChanges: false);
    final pigeonController = PigeonCollectionController(persistChanges: false);
    final gameController = GameController(persistChanges: false);
    await tester.pumpWidget(
      _testApp(controller, pigeonController, gameController),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Le parc attend ses prochains visiteurs.'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.tap(find.byKey(const ValueKey('park-pigeon-gilbert-0')));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('park-pigeon-preview-gilbert')),
      findsOneWidget,
    );
    expect(find.text('Amitié : 7/10'), findsOneWidget);
    await tester.tap(find.text('Fermer'));
    await tester.pump();
    expect(find.text('Parc'), findsOneWidget);
    expect(find.text('Pigeondex'), findsOneWidget);
    expect(find.text('Trésors'), findsOneWidget);
    expect(find.text('Paramètres'), findsOneWidget);
    expect(find.byKey(const ValueKey('shop-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('visit-journal-button')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('visit-journal-button')));
    await tester.pumpAndSettle();
    expect(find.text('Journal des visites'), findsOneWidget);
    expect(
      find.text('Tes prochaines visites seront notées ici.'),
      findsOneWidget,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('shop-button')));
    await tester.pumpAndSettle();
    expect(find.text('Boutique en préparation'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('buy-500-crumbs')));
    await tester.pumpAndSettle();
    expect(find.text('Échanger des plumes ?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm-buy-500-crumbs')));
    await tester.pumpAndSettle();
    expect(gameController.crumbs, 1740);
    expect(gameController.feathers, 10);
    await tester.tap(find.text('Thèmes'));
    await tester.pumpAndSettle();
    expect(find.text('Pack Gentlemen'), findsOneWidget);
    expect(find.text('3 pigeons exclusifs'), findsWidgets);
    expect(find.text('THÈME À VENIR'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pigeondex'));
    await tester.pumpAndSettle();
    expect(find.text('Gilbert'), findsOneWidget);
    expect(find.text('1 / 30'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('pigeon-michel')));
    await tester.pumpAndSettle();
    expect(find.text('« Une tranche classique. »'), findsOneWidget);
    await tester.tap(find.text('Je vais chercher'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('pigeondex-grid')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(find.text('???'), findsWidgets);
    controller.dispose();
    pigeonController.dispose();
    gameController.dispose();
  });

  testWidgets('updates settings and switches language', (tester) async {
    final controller = SettingsController(persistChanges: false);
    final pigeonController = PigeonCollectionController(persistChanges: false);
    final gameController = GameController(persistChanges: false);
    await tester.pumpWidget(
      _testApp(controller, pigeonController, gameController),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Paramètres'));
    await tester.pumpAndSettle();
    expect(find.text('Sons'), findsOneWidget);

    await tester.tap(find.text('Sons'));
    await tester.pump();
    expect(controller.soundEnabled, isFalse);

    await tester.tap(find.byKey(const ValueKey('language-setting')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(controller.language, AppLanguage.english);
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Sounds'), findsOneWidget);

    final replayTutorial = find.byKey(const ValueKey('replay-tutorial'));
    await tester.scrollUntilVisible(
      replayTutorial,
      150,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -100));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Replay tutorial'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('onboarding-screen')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('skip-onboarding')));
    await tester.pumpAndSettle();
    expect(controller.onboardingComplete, isTrue);
    controller.dispose();
    pigeonController.dispose();
    gameController.dispose();
  });

  testWidgets('opens the destination selected from a notification', (
    tester,
  ) async {
    final settingsController = SettingsController(persistChanges: false);
    final pigeonController = PigeonCollectionController(persistChanges: false);
    final gameController = GameController(persistChanges: false);
    final notificationService = LocalNotificationService(
      useNativePlugin: false,
    );
    await tester.pumpWidget(
      PidgeParkApp(
        settingsController: settingsController,
        pigeonCollectionController: pigeonController,
        gameController: gameController,
        notificationService: notificationService,
        minimumSplashDuration: Duration.zero,
        loadSettings: false,
        showDailyGift: false,
      ),
    );
    await tester.pumpAndSettle();

    notificationService.simulateNotificationTap('daily_challenge');
    await tester.pumpAndSettle();

    expect(find.text('PIGEON DU JOUR'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    notificationService.dispose();
    settingsController.dispose();
    pigeonController.dispose();
    gameController.dispose();
  });

  testWidgets('opens the right pigeon from an activity notification', (
    tester,
  ) async {
    final settingsController = SettingsController(persistChanges: false);
    final pigeonController = PigeonCollectionController(persistChanges: false);
    final gameController = GameController(persistChanges: false);
    final activityController = FriendshipActivityController(
      persistChanges: false,
    );
    final notificationService = LocalNotificationService(
      useNativePlugin: false,
    );
    await tester.pumpWidget(
      PidgeParkApp(
        settingsController: settingsController,
        pigeonCollectionController: pigeonController,
        gameController: gameController,
        friendshipActivityController: activityController,
        notificationService: notificationService,
        minimumSplashDuration: Duration.zero,
        loadSettings: false,
        showDailyGift: false,
      ),
    );
    await tester.pumpAndSettle();

    notificationService.simulateNotificationTap('pigeon_activity:gilbert');
    await tester.pumpAndSettle();

    expect(find.text('Gilbert'), findsWidgets);
    expect(
      find.byKey(const ValueKey('share-pigeon-from-pigeondex')),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    notificationService.dispose();
    activityController.dispose();
    settingsController.dispose();
    pigeonController.dispose();
    gameController.dispose();
  });

  testWidgets('feeds a pigeon and increases friendship progressively', (
    tester,
  ) async {
    final settingsController = SettingsController(persistChanges: false);
    final pigeonController = PigeonCollectionController(persistChanges: false);
    final gameController = GameController(persistChanges: false);
    await tester.pumpWidget(
      _testApp(settingsController, pigeonController, gameController),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pigeondex'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('pigeon-gilbert')));
    await tester.pumpAndSettle();

    expect(find.text('7/10'), findsOneWidget);
    expect(
      find.text('0 / 15 points · encore 15 avant le prochain cœur'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('share-pigeon-from-pigeondex')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('share-dialog-gilbert')), findsOneWidget);
    expect(find.byKey(const ValueKey('share-pigeon-gilbert')), findsOneWidget);
    await tester.tap(find.text('Fermer'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('give-favorite-food')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('give-favorite-food')));
    await tester.pumpAndSettle();
    expect(pigeonController.progressFor('gilbert').friendshipPoints, 45);
    expect(gameController.crumbs, 1215);
    for (var index = 0; index < 11; index++) {
      await gameController.spendCrumbs(25);
      await pigeonController.giveFood('gilbert', points: 5);
    }
    await tester.pump();
    expect(pigeonController.progressFor('gilbert').affection, 10);
    expect(pigeonController.progressFor('gilbert').isMaxFriendship, isTrue);
    expect(gameController.crumbs, 940);

    final treasureReward = find.byKey(
      const ValueKey('claim-friendship-milestone-6'),
    );
    await tester.scrollUntilVisible(
      treasureReward,
      -200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(treasureReward);
    await tester.pumpAndSettle();
    await tester.tap(treasureReward);
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trésors'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 10'), findsOneWidget);
    expect(find.text('Cuillère sale'), findsOneWidget);

    settingsController.dispose();
    pigeonController.dispose();
    gameController.dispose();
  });

  testWidgets('claims a friendship milestone reward from the pigeon card', (
    tester,
  ) async {
    final settingsController = SettingsController(persistChanges: false);
    final pigeonController = PigeonCollectionController(persistChanges: false);
    final gameController = GameController(persistChanges: false);
    await tester.pumpWidget(
      _testApp(settingsController, pigeonController, gameController),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pigeondex'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('pigeon-gilbert')));
    await tester.pumpAndSettle();

    final claimButton = find.byKey(
      const ValueKey('claim-friendship-milestone-2'),
    );
    await tester.scrollUntilVisible(
      claimButton,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(claimButton);
    await tester.pumpAndSettle();

    expect(gameController.crumbs, 1340);
    expect(
      pigeonController.hasClaimedFriendshipMilestone('gilbert', 2),
      isTrue,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    settingsController.dispose();
    pigeonController.dispose();
    gameController.dispose();
  });

  test('feeding completes the visitor loop and awards crumbs', () async {
    var now = DateTime(2026, 9, 9, 12);
    final gameController = GameController(
      persistChanges: false,
      useFastTimers: true,
      now: () => now,
    );
    final pigeonController = PigeonCollectionController(persistChanges: false);

    expect(await gameController.placeFood(foods.first), isTrue);
    expect(gameController.visitorReady, isFalse);

    now = now.add(const Duration(seconds: 9));
    expect(gameController.visitorReady, isTrue);

    final visitors = gameController.selectFoodVisitors(pigeonController);
    expect(visitors.length, inInclusiveRange(3, 4));
    expect(visitors.map((pigeon) => pigeon.id).toSet().length, visitors.length);

    final result = await gameController.meetVisitor(pigeonController);
    expect(result, isNotNull);
    expect(result!.reward, inInclusiveRange(20, 50));
    expect(gameController.crumbs, greaterThan(1240));
    expect(gameController.hasActiveFood, isFalse);

    gameController.dispose();
    pigeonController.dispose();
  });

  test('friendship increases ambient appearance weight', () async {
    final collection = PigeonCollectionController(persistChanges: false);
    await collection.discover('michel');
    final game = GameController(persistChanges: false, random: Random(42));
    var gilbertAppearances = 0;
    var michelAppearances = 0;

    for (var index = 0; index < 300; index++) {
      final flock = game.selectAmbientPigeons(collection);
      gilbertAppearances += flock.where((item) => item.id == 'gilbert').length;
      michelAppearances += flock.where((item) => item.id == 'michel').length;
    }

    expect(gilbertAppearances, greaterThan(michelAppearances));
    game.dispose();
    collection.dispose();
  });

  test('friendship levels require multiple visits', () async {
    final collection = PigeonCollectionController(persistChanges: false);
    await collection.discover('michel');

    expect(collection.progressFor('michel').affection, 1);
    expect(collection.progressFor('michel').friendshipPoints, 0);
    await collection.recordVisit('michel');
    expect(collection.progressFor('michel').affection, 1);
    expect(collection.progressFor('michel').friendshipPoints, 1);
    await collection.recordVisit('michel');
    expect(collection.progressFor('michel').affection, 1);
    expect(collection.progressFor('michel').friendshipPoints, 2);
    await collection.recordVisit('michel');
    expect(collection.progressFor('michel').affection, 2);
    expect(collection.progressFor('michel').friendshipPoints, 3);

    collection.dispose();
  });

  test('friendship milestone rewards can only be claimed once', () async {
    final collection = PigeonCollectionController(persistChanges: false);

    expect(collection.progressFor('gilbert').affection, 7);
    expect(collection.canClaimFriendshipMilestone('gilbert', 2), isTrue);
    expect(await collection.claimFriendshipMilestone('gilbert', 2), isTrue);
    expect(collection.hasClaimedFriendshipMilestone('gilbert', 2), isTrue);
    expect(await collection.claimFriendshipMilestone('gilbert', 2), isFalse);
    expect(collection.canClaimFriendshipMilestone('gilbert', 6), isTrue);
    expect(collection.canClaimFriendshipMilestone('gilbert', 10), isFalse);

    collection.dispose();
  });

  test('only one timed friendship activity can run at a time', () async {
    var now = DateTime(2026, 9, 10, 12);
    final collection = PigeonCollectionController(persistChanges: false);
    final activities = FriendshipActivityController(
      persistChanges: false,
      useFastTimers: true,
      now: () => now,
    );
    final pointsBefore = collection.progressFor('gilbert').friendshipPoints;

    expect(await activities.start('gilbert', FriendshipActivity.play), isTrue);
    expect(await activities.start('michel', FriendshipActivity.photo), isFalse);
    expect(activities.isComplete, isFalse);
    now = now.add(const Duration(seconds: 9));
    expect(activities.isComplete, isTrue);
    expect(await activities.claim(collection), 5);
    expect(
      collection.progressFor('gilbert').friendshipPoints,
      pointsBefore + 5,
    );
    expect(activities.completedInteractionsFor('gilbert'), 1);
    expect(activities.canInteractWith('gilbert'), isFalse);

    now = now.add(const Duration(days: 1));
    expect(activities.canInteractWith('gilbert'), isTrue);

    activities.dispose();
    collection.dispose();
  });

  testWidgets('park refreshes when a friendship activity completes', (
    tester,
  ) async {
    var now = DateTime(2026, 9, 10, 12);
    final settingsController = SettingsController(persistChanges: false);
    final pigeonController = PigeonCollectionController(persistChanges: false);
    final gameController = GameController(persistChanges: false);
    final activityController = FriendshipActivityController(
      persistChanges: false,
      useFastTimers: true,
      now: () => now,
    );
    await activityController.start('gilbert', FriendshipActivity.pet);
    await tester.pumpWidget(
      PidgeParkApp(
        settingsController: settingsController,
        pigeonCollectionController: pigeonController,
        gameController: gameController,
        friendshipActivityController: activityController,
        minimumSplashDuration: Duration.zero,
        loadSettings: false,
        showDailyGift: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Caresser avec Gilbert'), findsOneWidget);
    now = now.add(const Duration(seconds: 7));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Activité avec Gilbert terminée !'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('active-friendship-activity-park')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('share-pigeon-from-pigeondex')),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    activityController.dispose();
    settingsController.dispose();
    pigeonController.dispose();
    gameController.dispose();
  });

  test('expensive food attracts four pigeons more often', () async {
    var now = DateTime(2026, 9, 9, 12);
    final collection = PigeonCollectionController(persistChanges: false);
    final seedsGame = GameController(
      persistChanges: false,
      useFastTimers: true,
      now: () => now,
      random: Random(7),
    );
    final premiumGame = GameController(
      persistChanges: false,
      useFastTimers: true,
      now: () => now,
      random: Random(7),
    );
    await seedsGame.placeFood(foods.first);
    await premiumGame.placeFood(
      foods.firstWhere((food) => food.id == 'premium_seeds'),
    );
    now = now.add(const Duration(seconds: 20));

    var seedsWithFour = 0;
    var premiumWithFour = 0;
    for (var index = 0; index < 200; index++) {
      if (seedsGame.selectFoodVisitors(collection).length == 4) {
        seedsWithFour++;
      }
      if (premiumGame.selectFoodVisitors(collection).length == 4) {
        premiumWithFour++;
      }
    }

    expect(premiumWithFour, greaterThan(seedsWithFour));
    seedsGame.dispose();
    premiumGame.dispose();
    collection.dispose();
  });

  test('exchanges feathers for crumbs atomically', () async {
    final gameController = GameController(persistChanges: false);

    expect(
      await gameController.exchangeFeathersForCrumbs(
        featherCost: 25,
        crumbAmount: 500,
      ),
      isTrue,
    );
    expect(gameController.crumbs, 1740);
    expect(gameController.feathers, 10);
    expect(
      await gameController.exchangeFeathersForCrumbs(
        featherCost: 60,
        crumbAmount: 1500,
      ),
      isFalse,
    );
    expect(gameController.crumbs, 1740);
    expect(gameController.feathers, 10);

    gameController.dispose();
  });

  test('decorations can be bought, equipped, and attract visitors', () async {
    var now = DateTime(2026, 9, 9, 22);
    final gameController = GameController(
      persistChanges: false,
      useFastTimers: true,
      now: () => now,
    );
    final decorationController = DecorationController(persistChanges: false);
    final pigeonController = PigeonCollectionController(persistChanges: false);
    final radio = decorations.firstWhere((item) => item.id == 'radio');

    expect(await decorationController.buy(radio, gameController), isTrue);
    expect(gameController.crumbs, 790);
    await decorationController.toggleEquipped(radio);
    expect(decorationController.equippedIds, contains('radio'));
    expect(decorationController.equippedIds, contains('bench'));

    await gameController.placeFood(foods.first);
    now = now.add(const Duration(seconds: 9));
    final result = await gameController.meetVisitor(
      pigeonController,
      decorationIds: decorationController.equippedIds.toSet(),
    );
    expect(result?.pigeon.id, 'disco_pigeon');
    expect(result?.isNew, isTrue);

    final fountain = decorations.firstWhere((item) => item.id == 'fountain');
    expect(await decorationController.buy(fountain, gameController), isTrue);
    await decorationController.toggleEquipped(fountain);
    expect(decorationController.equippedIds, contains('fountain'));
    expect(decorationController.equippedIds, isNot(contains('bench')));
    expect(
      decorationController.equippedIds
          .map((id) => decorations.firstWhere((item) => item.id == id).size)
          .toSet()
          .length,
      decorationController.equippedIds.length,
    );

    gameController.dispose();
    decorationController.dispose();
    pigeonController.dispose();
  });

  test('all pigeon decoration requirements fit the three park categories', () {
    for (final pigeon in pigeons) {
      final requiredDecorations = pigeon.decorationIds.map(
        (id) => decorations.firstWhere(
          (decoration) => decoration.id == id,
          orElse: () => throw StateError(
            '${pigeon.name} requires unknown decoration $id',
          ),
        ),
      );
      final requiredSizes = requiredDecorations
          .map((decoration) => decoration.size)
          .toList();
      expect(
        requiredSizes.toSet().length,
        requiredSizes.length,
        reason:
            '${pigeon.name} requires two decorations from the same category',
      );
    }
  });

  test('daily challenge rewards once and maintains the streak', () async {
    var now = DateTime(2026, 9, 9, 12);
    final dailyController = DailyChallengeController(
      persistChanges: false,
      now: () => now,
    );
    final gameController = GameController(persistChanges: false);
    await dailyController.load();

    final firstReward = await dailyController.recordEncounter(
      dailyController.targetId,
      gameController,
    );
    expect(firstReward?.crumbs, 250);
    expect(dailyController.streak, 1);
    expect(gameController.crumbs, 1490);
    expect(
      await dailyController.recordEncounter(
        dailyController.targetId,
        gameController,
      ),
      isNull,
    );

    now = now.add(const Duration(days: 1));
    await dailyController.refreshDay();
    await dailyController.recordEncounter(
      dailyController.targetId,
      gameController,
    );
    expect(dailyController.streak, 2);

    dailyController.dispose();
    gameController.dispose();
  });

  test('daily missions track, reward, and reset at 4 AM', () async {
    var now = DateTime(2026, 9, 9, 12);
    final dailyController = DailyChallengeController(
      persistChanges: false,
      now: () => now,
    );
    final gameController = GameController(persistChanges: false);
    await dailyController.load();

    await dailyController.recordParkFed();
    await dailyController.recordFriendshipInteraction();
    await dailyController.recordWelcomedPigeons(4);
    for (final mission in dailyMissions) {
      expect(dailyController.isMissionComplete(mission), isTrue);
      expect(
        await dailyController.claimMission(mission, gameController),
        isTrue,
      );
      expect(
        await dailyController.claimMission(mission, gameController),
        isFalse,
      );
    }
    expect(dailyController.canClaimMissionChest, isTrue);
    expect(await dailyController.claimMissionChest(gameController), isTrue);
    expect(await dailyController.claimMissionChest(gameController), isFalse);
    expect(gameController.crumbs, 1515);
    expect(gameController.feathers, 43);

    now = DateTime(2026, 9, 10, 4);
    await dailyController.refreshDay();
    expect(dailyController.missionProgress(dailyMissions.first), 0);
    expect(dailyController.isMissionClaimed(dailyMissions.first), isFalse);
    expect(dailyController.missionChestClaimed, isFalse);

    dailyController.dispose();
    gameController.dispose();
  });

  test('achievements unlock once and keep permanent progress', () async {
    final controller = AchievementController(persistChanges: false);
    final collection = PigeonCollectionController(persistChanges: false);
    final decorations = DecorationController(persistChanges: false);

    final firstUnlock = await controller.update(
      flockWelcomed: true,
      collection: collection,
      decorations: decorations,
    );
    expect(
      firstUnlock.map((item) => item.type),
      contains(AchievementType.firstFlock),
    );
    final secondUnlock = await controller.update(
      collection: collection,
      decorations: decorations,
    );
    expect(secondUnlock, isEmpty);
    for (var index = 0; index < 5; index++) {
      await controller.update(
        foodId: 'food-$index',
        collection: collection,
        decorations: decorations,
      );
    }
    expect(
      controller.isUnlocked(
        achievements.firstWhere(
          (item) => item.type == AchievementType.foodExplorer,
        ),
      ),
      isTrue,
    );

    controller.dispose();
    collection.dispose();
    decorations.dispose();
  });

  test('visit journal keeps only the 20 most recent visits', () async {
    final journal = VisitJournalController(persistChanges: false);
    for (var index = 0; index < 22; index++) {
      await journal.record(
        VisitJournalEntry(
          visitedAt: DateTime(2026, 9, 10, 12, index),
          foodId: 'seeds',
          pigeonIds: const ['gilbert'],
          newPigeonIds: index == 0 ? const ['gilbert'] : const [],
          crumbReward: index,
          treasureIds: const [],
        ),
      );
    }

    expect(journal.entries.length, 20);
    expect(journal.entries.first.crumbReward, 21);
    expect(journal.entries.last.crumbReward, 2);
    journal.dispose();
  });

  testWidgets('achievement sorting cycles and unlocked icons are specific', (
    tester,
  ) async {
    final controller = AchievementController(persistChanges: false);
    final collection = PigeonCollectionController(persistChanges: false);
    final decorations = DecorationController(persistChanges: false);
    for (var index = 0; index < 5; index++) {
      await controller.update(
        foodId: 'food-$index',
        collection: collection,
        decorations: decorations,
      );
    }
    await tester.pumpWidget(
      MaterialApp(
        home: AchievementsScreen(
          controller: controller,
          collection: collection,
          decorations: decorations,
          isFrench: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tous les succès'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('achievement-sort-button')));
    await tester.pumpAndSettle();
    expect(find.text('Terminés d’abord'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey('achievement-foodExplorer')))
          .dy,
      lessThan(
        tester
            .getTopLeft(find.byKey(const ValueKey('achievement-firstFlock')))
            .dy,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('achievement-sort-button')));
    await tester.pumpAndSettle();
    expect(find.text('À terminer d’abord'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('achievement-sort-button')));
    await tester.pumpAndSettle();
    expect(find.text('Tous les succès'), findsOneWidget);

    controller.dispose();
    collection.dispose();
    decorations.dispose();
  });

  test('daily gift resets at 4 AM local time', () async {
    var now = DateTime(2026, 9, 9, 3, 59);
    const cycle = DailyCycle(resetHour: 4);
    final giftController = DailyGiftController(
      persistChanges: false,
      now: () => now,
      cycle: cycle,
    );
    final gameController = GameController(persistChanges: false);

    expect(cycle.keyFor(now), '2026-09-08');
    expect(await giftController.claim(gameController), isTrue);
    expect(gameController.crumbs, 1340);
    expect(await giftController.claim(gameController), isFalse);

    now = DateTime(2026, 9, 9, 4);
    expect(cycle.keyFor(now), '2026-09-09');
    expect(giftController.isAvailable, isTrue);
    expect(await giftController.claim(gameController), isTrue);
    expect(gameController.crumbs, 1440);

    giftController.dispose();
    gameController.dispose();
  });
}

Widget _testApp(
  SettingsController controller,
  PigeonCollectionController pigeonController,
  GameController gameController,
) {
  return PidgeParkApp(
    settingsController: controller,
    pigeonCollectionController: pigeonController,
    gameController: gameController,
    minimumSplashDuration: Duration.zero,
    loadSettings: false,
    showDailyGift: false,
  );
}
