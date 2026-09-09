import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pidge_park_app/collection/pigeon_collection_controller.dart';
import 'package:pidge_park_app/game/game_controller.dart';
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
    expect(find.text('Parc'), findsOneWidget);
    expect(find.text('Pigeondex'), findsOneWidget);
    expect(find.text('Trésors'), findsOneWidget);
    expect(find.text('Paramètres'), findsOneWidget);
    expect(find.byKey(const ValueKey('shop-button')), findsOneWidget);

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

  testWidgets('opens a pigeon profile and increases affection', (tester) async {
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
    for (var index = 0; index < 3; index++) {
      await tester.tap(find.byKey(const ValueKey('give-gift')));
      await tester.pump();
    }
    expect(find.text('10/10'), findsOneWidget);

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

    final result = await gameController.meetVisitor(pigeonController);
    expect(result, isNotNull);
    expect(result!.reward, inInclusiveRange(20, 50));
    expect(gameController.crumbs, greaterThan(1240));
    expect(gameController.hasActiveFood, isFalse);

    gameController.dispose();
    pigeonController.dispose();
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
