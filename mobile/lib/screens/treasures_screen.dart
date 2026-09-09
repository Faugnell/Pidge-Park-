import 'package:flutter/material.dart';

import '../collection/pigeon_collection_controller.dart';
import '../models/pigeon.dart';
import '../models/treasure.dart';
import '../theme/app_theme.dart';

class TreasuresScreen extends StatelessWidget {
  const TreasuresScreen({
    required this.collectionController,
    required this.isFrench,
    super.key,
  });

  final PigeonCollectionController collectionController;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: collectionController,
      builder: (context, _) {
        final unlockedCount = treasures.where(_isUnlocked).length;
        return ColoredBox(
          color: AppColors.placeholderBackground,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 18),
                Text(
                  isFrench ? 'TRÉSORS DE PIGEONS' : 'PIGEON TREASURES',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text('$unlockedCount / ${treasures.length}'),
                const SizedBox(height: 18),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.82,
                        ),
                    itemCount: treasures.length,
                    itemBuilder: (context, index) {
                      final treasure = treasures[index];
                      return _TreasureCard(
                        treasure: treasure,
                        unlocked: _isUnlocked(treasure),
                        isFrench: isFrench,
                        onTap: () => _showDetails(context, treasure),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_outline, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          isFrench
                              ? 'Atteins 10 cœurs avec un pigeon pour recevoir son trésor.'
                              : 'Reach 10 hearts with a pigeon to receive its treasure.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isUnlocked(PigeonTreasure treasure) {
    return collectionController.progressFor(treasure.pigeonId).affection >=
        treasure.requiredAffection;
  }

  void _showDetails(BuildContext context, PigeonTreasure treasure) {
    final unlocked = _isUnlocked(treasure);
    final pigeon = pigeons.firstWhere((item) => item.id == treasure.pigeonId);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.splashBackground,
        icon: Icon(unlocked ? treasure.icon : Icons.lock_outline, size: 54),
        title: Text(unlocked ? treasure.name(isFrench) : '???'),
        content: Text(
          unlocked
              ? treasure.description(isFrench)
              : '${pigeon.name} · ❤️ ${treasure.requiredAffection}/10',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isFrench ? 'Fermer' : 'Close'),
          ),
        ],
      ),
    );
  }
}

class _TreasureCard extends StatelessWidget {
  const _TreasureCard({
    required this.treasure,
    required this.unlocked,
    required this.isFrench,
    required this.onTap,
  });

  final PigeonTreasure treasure;
  final bool unlocked;
  final bool isFrench;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.navigationBackground,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFD8C9AA)),
      ),
      child: InkWell(
        key: ValueKey('treasure-${treasure.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Icon(
                  unlocked ? treasure.icon : Icons.question_mark,
                  size: 48,
                  color: unlocked
                      ? AppColors.selected
                      : const Color(0xFF948C7C),
                ),
              ),
              Text(
                unlocked ? treasure.name(isFrench) : '???',
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
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
