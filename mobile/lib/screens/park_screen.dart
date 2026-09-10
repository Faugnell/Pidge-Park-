import 'dart:async';

import 'package:flutter/material.dart';

import '../collection/pigeon_collection_controller.dart';
import '../game/game_controller.dart';
import '../game/friendship_activity_controller.dart';
import '../game/visit_journal_controller.dart';
import '../game/decoration_controller.dart';
import '../game/daily_challenge_controller.dart';
import '../models/food.dart';
import '../models/pigeon.dart';
import '../theme/app_theme.dart';
import '../widgets/pigeon_avatar.dart';
import '../widgets/pigeon_share_card.dart';
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
    required this.friendshipActivityController,
    required this.onOpenActivityPigeon,
    required this.onAchievementEvent,
    required this.visitJournalController,
    required this.onOpenJournal,
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
  final FriendshipActivityController friendshipActivityController;
  final VoidCallback onOpenActivityPigeon;
  final Future<void> Function({
    String? foodId,
    bool flockWelcomed,
    bool missionDayCompleted,
  })
  onAchievementEvent;
  final VisitJournalController visitJournalController;
  final VoidCallback onOpenJournal;

  @override
  State<ParkScreen> createState() => _ParkScreenState();
}

class _ParkScreenState extends State<ParkScreen> {
  Timer? _ticker;
  List<Pigeon> _ambientFlock = const [];
  List<Pigeon> _visitorFlock = const [];

  @override
  void initState() {
    super.initState();
    _refreshAmbientFlock();
    _prepareVisitorsIfReady();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final hasActiveFood = widget.gameController.hasActiveFood;
      final hasFriendshipActivity =
          widget.friendshipActivityController.hasActiveActivity;
      if (!hasActiveFood && !hasFriendshipActivity) return;
      if (hasActiveFood &&
          widget.gameController.visitorReady &&
          _visitorFlock.isEmpty) {
        setState(_prepareVisitorsIfReady);
      } else {
        setState(() {});
      }
    });
  }

  void _refreshAmbientFlock() {
    _ambientFlock = widget.gameController.selectAmbientPigeons(
      widget.collectionController,
    );
  }

  void _prepareVisitorsIfReady() {
    if (!widget.gameController.visitorReady || _visitorFlock.isNotEmpty) return;
    _visitorFlock = widget.gameController.selectFoodVisitors(
      widget.collectionController,
      decorationIds: widget.decorationController.equippedIds.toSet(),
    );
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
        widget.friendshipActivityController,
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
                              ? 'Défis du jour'
                              : 'Daily challenges',
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
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ParkScene(
                              gameController: game,
                              decorationController: widget.decorationController,
                              pigeons: game.hasActiveFood
                                  ? (game.visitorReady
                                        ? _visitorFlock
                                        : const [])
                                  : _ambientPigeonsWithoutBusyPigeon(),
                              knownPigeonIds: {
                                for (final pigeon in pigeons)
                                  if (widget.collectionController
                                      .progressFor(pigeon.id)
                                      .discovered)
                                    pigeon.id,
                              },
                              onPigeonTap: _showPigeonPreview,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton.filledTonal(
                              key: const ValueKey('visit-journal-button'),
                              tooltip: widget.isFrench
                                  ? 'Journal des visites'
                                  : 'Visit journal',
                              onPressed: widget.onOpenJournal,
                              icon: const Icon(Icons.menu_book_outlined),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.navigationBackground,
                                foregroundColor: AppColors.selected,
                                side: const BorderSide(
                                  color: Color(0xFFCDBE9D),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (widget.friendshipActivityController.hasActiveActivity)
                      _ActiveFriendshipActivity(
                        controller: widget.friendshipActivityController,
                        isFrench: widget.isFrench,
                        onOpenPigeon: widget.onOpenActivityPigeon,
                      ),
                    if (widget.friendshipActivityController.hasActiveActivity)
                      const SizedBox(height: 8),
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
                              ? 'DÉCOUVRIR LES VISITEURS'
                              : 'MEET THE VISITORS',
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

  List<Pigeon> _ambientPigeonsWithoutBusyPigeon() {
    final busyId = widget.friendshipActivityController.activePigeonId;
    if (busyId == null) return _ambientFlock;
    final result = List<Pigeon>.of(_ambientFlock);
    final index = result.indexWhere((pigeon) => pigeon.id == busyId);
    if (index >= 0 && result.length > 1) result.removeAt(index);
    return result;
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
    if (placed) _visitorFlock = const [];
    if (placed) await widget.dailyChallengeController.recordParkFed();
    if (placed) await widget.onAchievementEvent(foodId: food.id);
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
    _prepareVisitorsIfReady();
    final usedFoodId = widget.gameController.activeFoodId;
    final result = await widget.gameController.meetVisitors(
      widget.collectionController,
      _visitorFlock,
    );
    if (result == null || !mounted) return;
    DailyReward? dailyReward;
    for (final encounter in result.encounters) {
      dailyReward ??= await widget.dailyChallengeController.recordEncounter(
        encounter.pigeon.id,
        widget.gameController,
      );
    }
    await widget.dailyChallengeController.recordWelcomedPigeons(
      result.encounters.length,
    );
    await widget.onAchievementEvent(flockWelcomed: true);
    if (usedFoodId != null) {
      await widget.visitJournalController.record(
        VisitJournalEntry(
          visitedAt: DateTime.now(),
          foodId: usedFoodId,
          pigeonIds: result.encounters.map((item) => item.pigeon.id).toList(),
          newPigeonIds: result.encounters
              .where((item) => item.isNew)
              .map((item) => item.pigeon.id)
              .toList(),
          crumbReward: result.totalReward,
          treasureIds: result.encounters
              .map((item) => item.unlockedTreasure?.id)
              .whereType<String>()
              .toList(),
        ),
      );
    }
    _visitorFlock = const [];
    _refreshAmbientFlock();
    await widget.onGameStateChanged();
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.splashBackground,
        title: Text(
          result.encounters.any((item) => item.isNew)
              ? (widget.isFrench ? 'NOUVEAUX VISITEURS !' : 'NEW VISITORS!')
              : (widget.isFrench ? 'LA BANDE EST LÀ !' : 'THE FLOCK IS HERE!'),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final encounter in result.encounters)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PigeonAvatar(pigeon: encounter.pigeon, size: 72),
                      Text(
                        encounter.pigeon.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (encounter.isNew)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.isFrench ? 'Nouveau !' : 'New!',
                              style: const TextStyle(color: AppColors.selected),
                            ),
                            IconButton(
                              key: ValueKey(
                                'share-new-pigeon-${encounter.pigeon.id}',
                              ),
                              tooltip: widget.isFrench ? 'Partager' : 'Share',
                              visualDensity: VisualDensity.compact,
                              onPressed: () => showPigeonShareCard(
                                context,
                                pigeon: encounter.pigeon,
                                progress: widget.collectionController
                                    .progressFor(encounter.pigeon.id),
                                isFrench: widget.isFrench,
                                isNew: true,
                              ),
                              icon: const Icon(Icons.ios_share, size: 18),
                            ),
                          ],
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '+${result.totalReward} ${widget.isFrench ? 'miettes' : 'crumbs'}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (result.encounters.any(
              (item) => item.unlockedTreasure != null,
            )) ...[
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 8),
              Icon(
                result.encounters
                    .firstWhere((item) => item.unlockedTreasure != null)
                    .unlockedTreasure!
                    .icon,
                size: 34,
              ),
              const SizedBox(height: 6),
              Text(
                widget.isFrench ? 'NOUVEAU TRÉSOR !' : 'NEW TREASURE!',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                result.encounters
                    .firstWhere((item) => item.unlockedTreasure != null)
                    .unlockedTreasure!
                    .name(widget.isFrench),
              ),
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

  Future<void> _showPigeonPreview(Pigeon pigeon) async {
    final progress = widget.collectionController.progressFor(pigeon.id);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        key: ValueKey('park-pigeon-preview-${pigeon.id}'),
        backgroundColor: AppColors.splashBackground,
        icon: PigeonAvatar(pigeon: pigeon, size: 92),
        title: Text(pigeon.name, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: pigeon.rarity.color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                pigeon.rarity.label(widget.isFrench),
                style: TextStyle(
                  color: pigeon.rarity.color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              progress.discovered
                  ? (widget.isFrench
                        ? 'Amitié : ${progress.affection}/10'
                        : 'Friendship: ${progress.affection}/10')
                  : (widget.isFrench
                        ? 'Nouveau visiteur — récupère le groupe pour l’ajouter au Pigeondex.'
                        : 'New visitor — collect the flock to add it to the Pigeondex.'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(pigeon.hint(widget.isFrench), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.isFrench ? 'Fermer' : 'Close'),
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

class _ActiveFriendshipActivity extends StatelessWidget {
  const _ActiveFriendshipActivity({
    required this.controller,
    required this.isFrench,
    required this.onOpenPigeon,
  });

  final FriendshipActivityController controller;
  final bool isFrench;
  final VoidCallback onOpenPigeon;

  @override
  Widget build(BuildContext context) {
    final pigeon = pigeons
        .where((item) => item.id == controller.activePigeonId)
        .firstOrNull;
    final activity = controller.activeActivity;
    if (pigeon == null || activity == null) return const SizedBox.shrink();
    return Material(
      key: const ValueKey('active-friendship-activity-park'),
      color: AppColors.navigationBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFCDBE9D)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: controller.isComplete ? onOpenPigeon : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                controller.isComplete ? Icons.check_circle : Icons.schedule,
                size: 18,
                color: AppColors.selected,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  controller.isComplete
                      ? (isFrench
                            ? 'Activité avec ${pigeon.name} terminée !'
                            : 'Activity with ${pigeon.name} complete!')
                      : (isFrench
                            ? '${activity.label(true)} avec ${pigeon.name}'
                            : '${activity.label(false)} with ${pigeon.name}'),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              if (controller.isComplete) ...[
                const SizedBox(width: 5),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ],
          ),
        ),
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
        isFrench ? 'Les pigeons sont arrivés !' : 'The pigeons have arrived!',
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
