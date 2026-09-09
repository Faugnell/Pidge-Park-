import 'package:flutter/material.dart';

import '../game/decoration_controller.dart';
import '../game/game_controller.dart';
import '../models/decoration.dart';
import '../theme/app_theme.dart';

class DecorationsScreen extends StatelessWidget {
  const DecorationsScreen({
    required this.controller,
    required this.gameController,
    required this.isFrench,
    super.key,
  });

  final DecorationController controller;
  final GameController gameController;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, gameController]),
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.placeholderBackground,
        appBar: AppBar(
          backgroundColor: AppColors.placeholderBackground,
          title: Text(isFrench ? 'Décorations' : 'Decorations'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '🪙 ${gameController.crumbs}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                child: Row(
                  children: List.generate(DecorationSize.values.length, (
                    index,
                  ) {
                    final size = DecorationSize.values[index];
                    final decoration = controller.equippedFor(size);
                    return Expanded(
                      child: Container(
                        height: 86,
                        margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                        decoration: BoxDecoration(
                          color: AppColors.navigationBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFD8C9AA)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (decoration == null)
                              const Icon(Icons.add, color: Color(0xFF9B927F))
                            else
                              Icon(decoration.icon, color: AppColors.selected),
                            const SizedBox(height: 5),
                            Text(
                              decoration?.name(isFrench) ?? size.name(isFrench),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Text(
                isFrench
                    ? 'Une décoration maximum par catégorie'
                    : 'One decoration maximum per category',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    for (final size in DecorationSize.values)
                      _DecorationSection(
                        size: size,
                        decorations: decorations
                            .where((item) => item.size == size)
                            .toList(),
                        controller: controller,
                        isFrench: isFrench,
                        onSelected: (decoration) =>
                            _select(context, decoration),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _select(BuildContext context, ParkDecoration decoration) async {
    if (!controller.isOwned(decoration)) {
      final bought = await controller.buy(decoration, gameController);
      if (!bought && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFrench ? 'Pas assez de miettes.' : 'Not enough crumbs.',
            ),
          ),
        );
      }
      return;
    }
    await controller.toggleEquipped(decoration);
  }
}

class _DecorationSection extends StatelessWidget {
  const _DecorationSection({
    required this.size,
    required this.decorations,
    required this.controller,
    required this.isFrench,
    required this.onSelected,
  });

  final DecorationSize size;
  final List<ParkDecoration> decorations;
  final DecorationController controller;
  final bool isFrench;
  final ValueChanged<ParkDecoration> onSelected;

  @override
  Widget build(BuildContext context) {
    final equipped = controller.equippedFor(size);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFDDE9D6),
                  shape: BoxShape.circle,
                ),
                child: Icon(_categoryIcon, size: 20, color: AppColors.selected),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (equipped != null)
                Text(
                  isFrench ? '1 équipée' : '1 equipped',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.82,
            ),
            itemCount: decorations.length,
            itemBuilder: (context, index) {
              final decoration = decorations[index];
              return _DecorationCard(
                decoration: decoration,
                owned: controller.isOwned(decoration),
                equipped: controller.isEquipped(decoration),
                isFrench: isFrench,
                onTap: () => onSelected(decoration),
              );
            },
          ),
        ],
      ),
    );
  }

  String get _title => switch (size) {
    DecorationSize.large =>
      isFrench
          ? 'Grandes décorations · arrière-plan'
          : 'Large decorations · background',
    DecorationSize.medium =>
      isFrench
          ? 'Décorations moyennes · milieu'
          : 'Medium decorations · middle',
    DecorationSize.small =>
      isFrench
          ? 'Petites décorations · premier plan à droite'
          : 'Small decorations · right foreground',
  };

  IconData get _categoryIcon => switch (size) {
    DecorationSize.large => Icons.park_outlined,
    DecorationSize.medium => Icons.chair_alt_outlined,
    DecorationSize.small => Icons.radio_outlined,
  };
}

class _DecorationCard extends StatelessWidget {
  const _DecorationCard({
    required this.decoration,
    required this.owned,
    required this.equipped,
    required this.isFrench,
    required this.onTap,
  });

  final ParkDecoration decoration;
  final bool owned;
  final bool equipped;
  final bool isFrench;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: equipped
          ? const Color(0xFFDDE9D6)
          : AppColors.navigationBackground,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: equipped ? AppColors.selected : const Color(0xFFD8C9AA),
        ),
      ),
      child: InkWell(
        key: ValueKey('decoration-${decoration.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(decoration.icon, size: 42, color: AppColors.selected),
              const SizedBox(height: 8),
              Text(
                decoration.name(isFrench),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                equipped
                    ? (isFrench ? 'ÉQUIPÉ' : 'EQUIPPED')
                    : owned
                    ? (isFrench ? 'Possédé' : 'Owned')
                    : '🪙 ${decoration.price}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
