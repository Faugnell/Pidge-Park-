import 'dart:async';

import 'package:flutter/material.dart';

import '../collection/pigeon_collection_controller.dart';
import '../game/game_controller.dart';
import '../game/decoration_controller.dart';
import '../game/daily_challenge_controller.dart';
import '../models/food.dart';
import '../theme/app_theme.dart';
import '../widgets/pigeon_avatar.dart';
import '../widgets/park_scene.dart';

class ParkScreen extends StatefulWidget {
  const ParkScreen({
    required this.gameController,
    required this.collectionController,
    required this.isFrench,
    required this.onOpenShop,
    required this.decorationController,
    required this.onOpenDecorations,
    required this.dailyChallengeController,
    required this.onOpenDailyChallenge,
    required this.onGameStateChanged,
    super.key,
  });

  final GameController gameController;
  final PigeonCollectionController collectionController;
  final bool isFrench;
  final VoidCallback onOpenShop;
  final DecorationController decorationController;
  final VoidCallback onOpenDecorations;
  final DailyChallengeController dailyChallengeController;
  final VoidCallback onOpenDailyChallenge;
  final Future<void> Function() onGameStateChanged;

  @override
  State<ParkScreen> createState() => _ParkScreenState();
}

class _ParkScreenState extends State<ParkScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && widget.gameController.hasActiveFood) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.gameController,
        widget.decorationController,
      ]),
      builder: (context, _) {
        final game = widget.gameController;
        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.park),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _CurrencyPill(
                          icon: Icons.monetization_on,
                          iconColor: const Color(0xFFE7AD28),
                          value: game.crumbs,
                        ),
                        const SizedBox(width: 8),
                        _CurrencyPill(
                          icon: Icons.auto_awesome,
                          iconColor: const Color(0xFF7193C5),
                          value: game.feathers,
                        ),
                        const Spacer(),
                        IconButton.filledTonal(
                          key: const ValueKey('daily-challenge-button'),
                          tooltip: widget.isFrench
                              ? 'Pigeon du jour'
                              : 'Pigeon of the day',
                          onPressed: widget.onOpenDailyChallenge,
                          icon: const Icon(Icons.calendar_today_outlined),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.navigationBackground,
                            foregroundColor: AppColors.selected,
                            side: const BorderSide(color: Color(0xFFCDBE9D)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton.filledTonal(
                          key: const ValueKey('decorations-button'),
                          tooltip: widget.isFrench
                              ? 'Décorations'
                              : 'Decorations',
                          onPressed: widget.onOpenDecorations,
                          icon: const Icon(Icons.chair_alt_outlined),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.navigationBackground,
                            foregroundColor: AppColors.selected,
                            side: const BorderSide(color: Color(0xFFCDBE9D)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton.filledTonal(
                          key: const ValueKey('shop-button'),
                          tooltip: widget.isFrench ? 'Boutique' : 'Shop',
                          onPressed: widget.onOpenShop,
                          icon: const Icon(Icons.storefront_outlined),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.navigationBackground,
                            foregroundColor: AppColors.selected,
                            side: const BorderSide(color: Color(0xFFCDBE9D)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ParkScene(
                        gameController: game,
                        decorationController: widget.decorationController,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ParkStatus(
                      gameController: game,
                      isFrench: widget.isFrench,
                    ),
                    const SizedBox(height: 12),
                    if (game.visitorReady)
                      FilledButton.icon(
                        key: const ValueKey('meet-visitor'),
                        onPressed: _meetVisitor,
                        icon: const Icon(Icons.flutter_dash),
                        label: Text(
                          widget.isFrench
                              ? 'DÉCOUVRIR LE VISITEUR'
                              : 'MEET THE VISITOR',
                        ),
                        style: _primaryButtonStyle(),
                      )
                    else if (!game.hasActiveFood)
                      FilledButton.icon(
                        key: const ValueKey('feed-button'),
                        onPressed: _chooseFood,
                        icon: const Icon(Icons.add),
                        label: Text(widget.isFrench ? 'NOURRIR' : 'FEED'),
                        style: _primaryButtonStyle(),
                      ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: const Color(0xFFFFCC5C),
      foregroundColor: const Color(0xFF3F321A),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFF8B6729), width: 1.5),
      ),
    );
  }

  Future<void> _chooseFood() async {
    final food = await showModalBottomSheet<Food>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.splashBackground,
      builder: (context) => _FoodPicker(
        gameController: widget.gameController,
        isFrench: widget.isFrench,
      ),
    );
    if (food == null || !mounted) return;

    final placed = await widget.gameController.placeFood(food);
    if (placed) await widget.onGameStateChanged();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          placed
              ? (widget.isFrench
                    ? '${food.nameFr} déposés dans le parc.'
                    : '${food.nameEn} placed in the park.')
              : (widget.isFrench
                    ? 'Pas assez de miettes.'
                    : 'Not enough crumbs.'),
        ),
      ),
    );
  }

  Future<void> _meetVisitor() async {
    final result = await widget.gameController.meetVisitor(
      widget.collectionController,
      decorationIds: widget.decorationController.equippedIds.toSet(),
    );
    if (result == null || !mounted) return;
    final dailyReward = await widget.dailyChallengeController.recordEncounter(
      result.pigeon.id,
      widget.gameController,
    );
    await widget.onGameStateChanged();
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.splashBackground,
        title: Text(
          result.isNew
              ? (widget.isFrench ? 'NOUVEAU PIGEON !' : 'NEW PIGEON!')
              : (widget.isFrench ? 'IL EST DE RETOUR !' : 'WELCOME BACK!'),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PigeonAvatar(pigeon: result.pigeon, size: 130),
            const SizedBox(height: 12),
            Text(
              result.pigeon.name,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              '+${result.reward} ${widget.isFrench ? 'miettes' : 'crumbs'}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (result.unlockedTreasure != null) ...[
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 8),
              Icon(result.unlockedTreasure!.icon, size: 34),
              const SizedBox(height: 6),
              Text(
                widget.isFrench ? 'NOUVEAU TRÉSOR !' : 'NEW TREASURE!',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(result.unlockedTreasure!.name(widget.isFrench)),
            ],
            if (dailyReward != null) ...[
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                widget.isFrench
                    ? 'DÉFI DU JOUR RÉUSSI !'
                    : 'DAILY CHALLENGE COMPLETE!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text('+${dailyReward.crumbs} 🪙'),
              if (dailyReward.feathers > 0) Text('+${dailyReward.feathers} ✨'),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.isFrench ? 'Super !' : 'Great!'),
          ),
        ],
      ),
    );
  }
}

class _CurrencyPill extends StatelessWidget {
  const _CurrencyPill({
    required this.icon,
    required this.iconColor,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.navigationBackground,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFCDBE9D)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 21),
          const SizedBox(width: 6),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _ParkStatus extends StatelessWidget {
  const _ParkStatus({required this.gameController, required this.isFrench});

  final GameController gameController;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    if (!gameController.hasActiveFood) {
      return Text(
        isFrench
            ? 'Le parc attend ses prochains visiteurs.'
            : 'The park is waiting for its next visitors.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      );
    }

    if (gameController.visitorReady) {
      return Text(
        isFrench ? 'Un pigeon est arrivé !' : 'A pigeon has arrived!',
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w800),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.navigationBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCDBE9D)),
      ),
      child: Column(
        children: [
          Text(
            isFrench ? 'Les pigeons arrivent dans' : 'Pigeons arrive in',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            _formatDuration(gameController.remaining),
            key: const ValueKey('arrival-countdown'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 3),
          Text(
            gameController.activeFood!.name(isFrench),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _FoodPicker extends StatelessWidget {
  const _FoodPicker({required this.gameController, required this.isFrench});

  final GameController gameController;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Text(
                    isFrench ? 'Choisir la nourriture' : 'Choose food',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: foods.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final food = foods[index];
                  final affordable = gameController.canAfford(food);
                  return Material(
                    color: AppColors.navigationBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFFD8C9AA)),
                    ),
                    child: ListTile(
                      key: ValueKey('food-${food.id}'),
                      enabled: affordable,
                      onTap: () => Navigator.pop(context, food),
                      leading: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: food.color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(food.icon, color: food.color),
                      ),
                      title: Text(
                        food.name(isFrench),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${food.description(isFrench)} · ${_foodDuration(food.duration, isFrench)}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: affordable
                              ? const Color(0xFFFFE4A0)
                              : const Color(0xFFE2DED5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          food.price == 0
                              ? (isFrench ? 'GRATUIT' : 'FREE')
                              : '🪙 ${food.price}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String _foodDuration(Duration duration, bool isFrench) {
  if (duration.inHours > 0) return '${duration.inHours} h';
  return '${duration.inMinutes} min';
}
