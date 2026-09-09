import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pidge_park_app/main.dart';
import 'package:pidge_park_app/settings/settings_controller.dart';

void main() {
  testWidgets('shows the splash screen while the app initializes', (
    tester,
  ) async {
    final controller = SettingsController(persistChanges: false);
    await tester.pumpWidget(
      PidgeParkApp(
        settingsController: controller,
        minimumSplashDuration: const Duration(milliseconds: 200),
        loadSettings: false,
      ),
    );

    expect(find.text('Pidge Park!'), findsOneWidget);
    expect(find.text('a cosy game'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    expect(find.text('Le parc arrive bientôt'), findsOneWidget);
    controller.dispose();
  });

  testWidgets('navigates between the main sections and opens the shop', (
    tester,
  ) async {
    final controller = SettingsController(persistChanges: false);
    await tester.pumpWidget(_testApp(controller));
    await tester.pumpAndSettle();

    expect(find.text('Le parc arrive bientôt'), findsOneWidget);
    expect(find.text('Parc'), findsOneWidget);
    expect(find.text('Pigeondex'), findsOneWidget);
    expect(find.text('Trésors'), findsOneWidget);
    expect(find.text('Paramètres'), findsOneWidget);
    expect(find.text('Boutique'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('shop-button')));
    await tester.pumpAndSettle();
    expect(find.text('La boutique ouvrira bientôt.'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pigeondex'));
    await tester.pumpAndSettle();
    expect(
      find.text('Ta collection de pigeons apparaîtra ici.'),
      findsOneWidget,
    );
    controller.dispose();
  });

  testWidgets('updates settings and switches language', (tester) async {
    final controller = SettingsController(persistChanges: false);
    await tester.pumpWidget(_testApp(controller));
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
  });
}

Widget _testApp(SettingsController controller) {
  return PidgeParkApp(
    settingsController: controller,
    minimumSplashDuration: Duration.zero,
    loadSettings: false,
  );
}
