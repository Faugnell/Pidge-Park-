import 'package:flutter/material.dart';

import '../settings/settings_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_navigation.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.settingsController, super.key});

  final SettingsController settingsController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isFrench = widget.settingsController.isFrench;
    final pages = <Widget>[
      _ParkPage(isFrench: isFrench),
      _PlaceholderPage(
        icon: Icons.menu_book,
        title: 'Pigeondex',
        message: isFrench
            ? 'Ta collection de pigeons apparaîtra ici.'
            : 'Your pigeon collection will appear here.',
      ),
      _PlaceholderPage(
        icon: Icons.diamond,
        title: isFrench ? 'Trésors' : 'Treasures',
        message: isFrench
            ? 'Tes trésors apparaîtront ici.'
            : 'Your treasures will appear here.',
      ),
      SettingsScreen(controller: widget.settingsController),
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

class _ParkPage extends StatelessWidget {
  const _ParkPage({required this.isFrench});

  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.park),
        SafeArea(
          bottom: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.park,
                    size: 72,
                    color: AppColors.selected.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isFrench ? 'Le parc arrive bientôt' : 'The park is coming',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isFrench
                        ? 'Cette couleur sera remplacée par le mockup du parc.'
                        : 'This colour will be replaced by the park artwork.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _ShopButton(
                isFrench: isFrench,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _ShopPage(isFrench: isFrench),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShopButton extends StatelessWidget {
  const _ShopButton({required this.isFrench, required this.onPressed});

  final bool isFrench;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      key: const ValueKey('shop-button'),
      onPressed: onPressed,
      icon: const Icon(Icons.storefront_outlined),
      label: Text(isFrench ? 'Boutique' : 'Shop'),
      style: FilledButton.styleFrom(
        foregroundColor: AppColors.selected,
        backgroundColor: AppColors.navigationBackground,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFCDBE9D)),
        ),
      ),
    );
  }
}

class _ShopPage extends StatelessWidget {
  const _ShopPage({required this.isFrench});

  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.placeholderBackground,
      appBar: AppBar(
        backgroundColor: AppColors.placeholderBackground,
        title: Text(isFrench ? 'Boutique' : 'Shop'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storefront, size: 64, color: AppColors.selected),
              const SizedBox(height: 16),
              Text(
                isFrench
                    ? 'La boutique ouvrira bientôt.'
                    : 'The shop will open soon.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.placeholderBackground,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 56, color: AppColors.selected),
                const SizedBox(height: 16),
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
