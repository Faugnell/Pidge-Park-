import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pidge_park_app/collection/pigeon_collection_controller.dart';
import 'package:pidge_park_app/game/game_controller.dart';
import 'package:pidge_park_app/main.dart';
import 'package:pidge_park_app/models/food.dart';
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
    expect(find.text('La boutique ouvrira bientôt.'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pigeondex'));
    await tester.pumpAndSettle();
    expect(find.text('Gilbert'), findsOneWidget);
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
    await tester.tap(find.byKey(const ValueKey('give-gift')));
    await tester.pump();
    expect(find.text('8/10'), findsOneWidget);

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
  );
}
