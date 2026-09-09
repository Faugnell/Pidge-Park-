import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../theme/app_theme.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({
    required this.gameController,
    required this.isFrench,
    super.key,
  });

  final GameController gameController;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.placeholderBackground,
        appBar: AppBar(
          backgroundColor: AppColors.placeholderBackground,
          title: Text(isFrench ? 'Boutique' : 'Shop'),
          actions: [
            AnimatedBuilder(
              animation: gameController,
              builder: (context, _) => Row(
                children: [
                  _Balance(
                    icon: Icons.monetization_on,
                    value: gameController.crumbs,
                  ),
                  const SizedBox(width: 6),
                  _Balance(
                    icon: Icons.auto_awesome,
                    value: gameController.feathers,
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: isFrench ? 'Offres' : 'Offers'),
              Tab(text: isFrench ? 'Plumes' : 'Feathers'),
              Tab(text: isFrench ? 'Thèmes' : 'Themes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OffersTab(isFrench: isFrench, gameController: gameController),
            _FeathersTab(isFrench: isFrench),
            _ThemesTab(isFrench: isFrench),
          ],
        ),
      ),
    );
  }
}

class _Balance extends StatelessWidget {
  const _Balance({required this.icon, required this.value});

  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.navigationBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8C9AA)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFE0A527)),
          const SizedBox(width: 4),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _OffersTab extends StatelessWidget {
  const _OffersTab({required this.isFrench, required this.gameController});

  final bool isFrench;
  final GameController gameController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _IntroCard(
          icon: Icons.storefront_outlined,
          title: isFrench ? 'Boutique en préparation' : 'Shop in progress',
          message: isFrench
              ? 'Échange tes plumes gagnées en jouant contre des miettes pour nourrir les pigeons.'
              : 'Exchange feathers earned by playing for crumbs to feed the pigeons.',
        ),
        const SizedBox(height: 16),
        Text(
          isFrench ? 'Packs de miettes' : 'Crumb packs',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: gameController,
          builder: (context, _) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _OfferCard(
                  key: const ValueKey('crumb-pack-small'),
                  icon: Icons.grain,
                  title: isFrench ? 'Petit sachet' : 'Small bag',
                  amount: 500,
                  featherCost: 25,
                  isFrench: isFrench,
                  gameController: gameController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OfferCard(
                  key: const ValueKey('crumb-pack-large'),
                  icon: Icons.inventory_2_outlined,
                  title: isFrench ? 'Grande réserve' : 'Large supply',
                  amount: 1500,
                  featherCost: 60,
                  isFrench: isFrench,
                  gameController: gameController,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeathersTab extends StatelessWidget {
  const _FeathersTab({required this.isFrench});

  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _IntroCard(
          icon: Icons.auto_awesome,
          title: isFrench ? 'Plumes spéciales' : 'Special feathers',
          message: isFrench
              ? 'Les plumes servent aux objets rares. Elles resteront aussi gagnables en jouant.'
              : 'Feathers are used for rare items. They will remain earnable by playing.',
        ),
        const SizedBox(height: 16),
        _OfferCard(
          icon: Icons.auto_awesome,
          title: isFrench ? 'Boîte de plumes' : 'Feather box',
          amount: 150,
          isFrench: isFrench,
          comingSoon: true,
        ),
      ],
    );
  }
}

class _ThemesTab extends StatelessWidget {
  const _ThemesTab({required this.isFrench});

  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    final themes = [
      (
        nameFr: 'Pack Gentlemen',
        nameEn: 'Gentlemen Pack',
        icon: Icons.workspace_premium_outlined,
        colors: const [Color(0xFFB7C49B), Color(0xFFE9DDBB)],
      ),
      (
        nameFr: 'Pack Pirates',
        nameEn: 'Pirate Pack',
        icon: Icons.sailing_outlined,
        colors: const [Color(0xFF8EB4BA), Color(0xFFD6B17C)],
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _IntroCard(
          icon: Icons.palette_outlined,
          title: isFrench ? 'Collections thématiques' : 'Theme collections',
          message: isFrench
              ? 'Chaque thème sera une collection visuelle complète, sans avantage de progression.'
              : 'Each theme will be a complete visual collection, with no progression advantage.',
        ),
        const SizedBox(height: 16),
        for (final theme in themes) ...[
          _ThemeCard(
            name: isFrench ? theme.nameFr : theme.nameEn,
            icon: theme.icon,
            colors: theme.colors,
            isFrench: isFrench,
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.name,
    required this.icon,
    required this.colors,
    required this.isFrench,
  });

  final String name;
  final IconData icon;
  final List<Color> colors;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: AppColors.navigationBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFD8C9AA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 125,
            decoration: BoxDecoration(gradient: LinearGradient(colors: colors)),
            child: Icon(icon, size: 64, color: AppColors.selected),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _IncludedLine(
                  icon: Icons.park_outlined,
                  text: isFrench
                      ? '1 ambiance complète du parc'
                      : '1 complete park atmosphere',
                ),
                _IncludedLine(
                  icon: Icons.flutter_dash,
                  text: isFrench
                      ? '3 pigeons exclusifs'
                      : '3 exclusive pigeons',
                ),
                _IncludedLine(
                  icon: Icons.chair_alt_outlined,
                  text: isFrench
                      ? '3 décorations assorties'
                      : '3 matching decorations',
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.schedule),
                    label: Text(isFrench ? 'THÈME À VENIR' : 'COMING SOON'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IncludedLine extends StatelessWidget {
  const _IncludedLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.selected),
          const SizedBox(width: 9),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBC2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8C9AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 34, color: AppColors.selected),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.icon,
    required this.title,
    required this.amount,
    required this.isFrench,
    this.featherCost,
    this.gameController,
    this.comingSoon = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final int amount;
  final bool isFrench;
  final int? featherCost;
  final GameController? gameController;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.navigationBackground,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, size: 48, color: const Color(0xFFC58E27)),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
            Text('$amount', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (comingSoon)
              FilledButton(
                onPressed: null,
                child: Text(isFrench ? 'À VENIR' : 'COMING SOON'),
              )
            else
              FilledButton.icon(
                key: ValueKey('buy-$amount-crumbs'),
                onPressed: gameController!.feathers >= featherCost!
                    ? () => _confirmPurchase(context)
                    : null,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: Text('$featherCost'),
              ),
            if (!comingSoon && gameController!.feathers < featherCost!) ...[
              const SizedBox(height: 5),
              Text(
                isFrench ? 'Plumes insuffisantes' : 'Not enough feathers',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmPurchase(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isFrench ? 'Échanger des plumes ?' : 'Exchange feathers?'),
        content: Text(
          isFrench
              ? 'Dépenser $featherCost plumes pour recevoir $amount miettes ?'
              : 'Spend $featherCost feathers to receive $amount crumbs?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isFrench ? 'Annuler' : 'Cancel'),
          ),
          FilledButton(
            key: ValueKey('confirm-buy-$amount-crumbs'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(isFrench ? 'Échanger' : 'Exchange'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final purchased = await gameController!.exchangeFeathersForCrumbs(
      featherCost: featherCost!,
      crumbAmount: amount,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          purchased
              ? (isFrench
                    ? '+$amount miettes ajoutées !'
                    : '+$amount crumbs added!')
              : (isFrench
                    ? 'Tu n’as pas assez de plumes.'
                    : 'You do not have enough feathers.'),
        ),
      ),
    );
  }
}
