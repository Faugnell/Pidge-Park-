import 'dart:async';

import 'package:flutter/material.dart';

import '../collection/pigeon_collection_controller.dart';
import '../game/game_controller.dart';
import '../game/friendship_activity_controller.dart';
import '../game/park_ambience.dart';
import '../game/visit_journal_controller.dart';
import '../game/decoration_controller.dart';
import '../game/daily_challenge_controller.dart';
import '../models/food.dart';
import '../models/pigeon.dart';
import '../models/pigeon_keepsake.dart';
import '../models/treasure.dart';
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
    required this.onOpenPigeon,
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
  final Future<void> Function(Pigeon pigeon) onOpenPigeon;

  @override
  State<ParkScreen> createState() => _ParkScreenState();
}

class _ParkScreenState extends State<ParkScreen> {
  Timer? _ticker;
  List<Pigeon> _ambientFlock = const [];
  List<Pigeon> _visitorFlock = const [];
  late ParkAmbience _ambience;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ambience = ParkAmbience.forDate(_currentTime);
    _refreshAmbientFlock();
    _prepareVisitorsIfReady();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final now = DateTime.now();
      final ambience = ParkAmbience.forDate(now);
      if (ambience.slotKey != _ambience.slotKey ||
          now.minute != _currentTime.minute) {
        setState(() {
          _currentTime = now;
          if (ambience.slotKey != _ambience.slotKey) {
            _ambience = ambience;
            _refreshAmbientFlock();
          }
        });
      }
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
      weather: _ambience.pigeonWeather,
    );
  }

  void _prepareVisitorsIfReady() {
    if (!widget.gameController.visitorReady || _visitorFlock.isNotEmpty) return;
    _visitorFlock = widget.gameController.selectFoodVisitors(
      widget.collectionController,
      decorationIds: widget.decorationController.equippedIds.toSet(),
      weather: _ambience.pigeonWeather,
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
                              ambience: _ambience,
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
                              conditionMatchPigeonIds: {
                                if (game.activeFood case final food?)
                                  for (final pigeon in _visitorFlock)
                                    if (!widget.collectionController
                                            .progressFor(pigeon.id)
                                            .discovered &&
                                        game.matchesCurrentConditions(
                                          pigeon,
                                          food: food,
                                          decorationIds: widget
                                              .decorationController
                                              .equippedIds
                                              .toSet(),
                                          weather: _ambience.pigeonWeather,
                                        ))
                                      pigeon.id,
                              },
                              accessoryIcons: {
                                for (final pigeon in pigeons)
                                  if (keepsakeById(
                                        widget.collectionController
                                            .equippedAccessoryId(pigeon.id),
                                      )
                                      case final item?)
                                    pigeon.id: item.icon,
                              },
                              companionIcons: {
                                for (final pigeon in pigeons)
                                  if (keepsakeById(
                                        widget.collectionController
                                            .equippedCompanionId(pigeon.id),
                                      )
                                      case final item?)
                                    pigeon.id: item.icon,
                              },
                              accessoryIds: _equippedAssetIds(companion: false),
                              companionIds: _equippedAssetIds(companion: true),
                              onPigeonTap: _showPigeonPreview,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: _AmbiencePill(
                              ambience: _ambience,
                              currentTime: _currentTime,
                              isFrench: widget.isFrench,
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

  Map<String, String> _equippedAssetIds({required bool companion}) {
    final result = <String, String>{};
    for (final pigeon in pigeons) {
      final id = companion
          ? widget.collectionController.equippedCompanionId(pigeon.id)
          : widget.collectionController.equippedAccessoryId(pigeon.id);
      if (id != null) result[pigeon.id] = id;
    }
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

    final pigeonToOpen = await showDialog<Pigeon>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _VisitorRevealDialog(
        result: result,
        collectionController: widget.collectionController,
        dailyReward: dailyReward,
        isFrench: widget.isFrench,
      ),
    );
    if (pigeonToOpen != null && mounted) {
      await widget.collectionController.markPigeonSeen(pigeonToOpen.id);
      await widget.onOpenPigeon(pigeonToOpen);
    }
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

class _VisitorRevealDialog extends StatefulWidget {
  const _VisitorRevealDialog({
    required this.result,
    required this.collectionController,
    required this.dailyReward,
    required this.isFrench,
  });

  final FlockEncounterResult result;
  final PigeonCollectionController collectionController;
  final DailyReward? dailyReward;
  final bool isFrench;

  @override
  State<_VisitorRevealDialog> createState() => _VisitorRevealDialogState();
}

class _VisitorRevealDialogState extends State<_VisitorRevealDialog> {
  late final Set<String> _revealedIds = {
    for (final encounter in widget.result.encounters)
      if (!encounter.isNew) encounter.pigeon.id,
  };

  bool get _allRevealed => widget.result.encounters.every(
    (encounter) => _revealedIds.contains(encounter.pigeon.id),
  );

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final treasure = widget.result.encounters
        .map((item) => item.unlockedTreasure)
        .whereType<PigeonTreasure>()
        .firstOrNull;
    return AlertDialog(
      key: const ValueKey('visitor-reveal-dialog'),
      backgroundColor: AppColors.splashBackground,
      title: Text(
        widget.result.encounters.any((item) => item.isNew)
            ? (widget.isFrench ? 'QUI EST VENU ?' : 'WHO CAME TO VISIT?')
            : (widget.isFrench ? 'LA BANDE EST LÀ !' : 'THE FLOCK IS HERE!'),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_allRevealed)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  widget.isFrench
                      ? 'Touche chaque silhouette pour découvrir le visiteur.'
                      : 'Tap each silhouette to discover the visitor.',
                  textAlign: TextAlign.center,
                ),
              ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 10,
              children: [
                for (final encounter in widget.result.encounters)
                  _VisitorRevealCard(
                    encounter: encounter,
                    revealed: _revealedIds.contains(encounter.pigeon.id),
                    canOpen: _allRevealed,
                    reduceMotion: reduceMotion,
                    isFrench: widget.isFrench,
                    onReveal: () =>
                        setState(() => _revealedIds.add(encounter.pigeon.id)),
                    onOpen: () => Navigator.pop(context, encounter.pigeon),
                    onShare: () => showPigeonShareCard(
                      context,
                      pigeon: encounter.pigeon,
                      progress: widget.collectionController.progressFor(
                        encounter.pigeon.id,
                      ),
                      isFrench: widget.isFrench,
                      isNew: encounter.isNew,
                      accessoryIcon: pigeonKeepsakes
                          .where(
                            (item) =>
                                item.id ==
                                widget.collectionController.equippedAccessoryId(
                                  encounter.pigeon.id,
                                ),
                          )
                          .firstOrNull
                          ?.icon,
                      companionIcon: pigeonKeepsakes
                          .where(
                            (item) =>
                                item.id ==
                                widget.collectionController.equippedCompanionId(
                                  encounter.pigeon.id,
                                ),
                          )
                          .firstOrNull
                          ?.icon,
                      accessoryId: widget.collectionController
                          .equippedAccessoryId(encounter.pigeon.id),
                      companionId: widget.collectionController
                          .equippedCompanionId(encounter.pigeon.id),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '+${widget.result.totalReward} ${widget.isFrench ? 'miettes' : 'crumbs'}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            if (widget.result.totalFeatherReward > 0)
              Text(
                '+${widget.result.totalFeatherReward} ${widget.isFrench ? 'plume${widget.result.totalFeatherReward > 1 ? 's' : ''} de découverte' : 'discovery feather${widget.result.totalFeatherReward > 1 ? 's' : ''}'}',
                key: const ValueKey('discovery-feather-reward'),
                style: const TextStyle(
                  color: AppColors.selected,
                  fontWeight: FontWeight.w800,
                ),
              ),
            for (final drop
                in widget.result.encounters
                    .map((item) => item.keepsakeDrop)
                    .whereType<KeepsakeDrop>()) ...[
              const SizedBox(height: 10),
              Container(
                key: ValueKey('keepsake-drop-${drop.keepsake.id}'),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5A3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(drop.keepsake.icon, color: AppColors.selected),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        drop.isDuplicate
                            ? (widget.isFrench
                                  ? '${drop.keepsake.name(true)} déjà trouvé · +${drop.featherReward} plumes'
                                  : '${drop.keepsake.name(false)} duplicate · +${drop.featherReward} feathers')
                            : (widget.isFrench
                                  ? 'Objet rapporté : ${drop.keepsake.name(true)} !\n« ${drop.keepsake.discoveryLine(true)} »'
                                  : 'Keepsake found: ${drop.keepsake.name(false)}!\n“${drop.keepsake.discoveryLine(false)}”'),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (treasure != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              Icon(treasure.icon, size: 32),
              Text(
                widget.isFrench ? 'NOUVEAU TRÉSOR !' : 'NEW TREASURE!',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(treasure.name(widget.isFrench)),
            ],
            if (widget.dailyReward case final reward?) ...[
              const SizedBox(height: 12),
              const Divider(),
              Text(
                widget.isFrench
                    ? 'DÉFI DU JOUR RÉUSSI !'
                    : 'DAILY CHALLENGE COMPLETE!',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text('+${reward.crumbs} 🪙'),
              if (reward.feathers > 0) Text('+${reward.feathers} ✨'),
            ],
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          key: const ValueKey('close-visitor-reveal'),
          onPressed: _allRevealed ? () => Navigator.pop(context) : null,
          child: Text(widget.isFrench ? 'Continuer' : 'Continue'),
        ),
      ],
    );
  }
}

class _VisitorRevealCard extends StatelessWidget {
  const _VisitorRevealCard({
    required this.encounter,
    required this.revealed,
    required this.canOpen,
    required this.reduceMotion,
    required this.isFrench,
    required this.onReveal,
    required this.onOpen,
    required this.onShare,
  });

  final EncounterResult encounter;
  final bool revealed;
  final bool canOpen;
  final bool reduceMotion;
  final bool isFrench;
  final VoidCallback onReveal;
  final VoidCallback onOpen;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      child: Material(
        color: AppColors.navigationBackground,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('reveal-visitor-${encounter.pigeon.id}'),
          onTap: revealed ? (canOpen ? onOpen : null) : onReveal,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: AnimatedSwitcher(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 450),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: revealed
                  ? Column(
                      key: const ValueKey('revealed'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PigeonAvatar(pigeon: encounter.pigeon, size: 64),
                        Text(
                          encounter.pigeon.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          encounter.isNew
                              ? '+${encounter.featherReward} ✨'
                              : (isFrench ? '+1 amitié' : '+1 friendship'),
                          style: const TextStyle(
                            color: AppColors.selected,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (encounter.isNew)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                canOpen
                                    ? (isFrench ? 'Fiche' : 'Profile')
                                    : (isFrench ? 'Nouveau !' : 'New!'),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              IconButton(
                                key: ValueKey(
                                  'share-new-pigeon-${encounter.pigeon.id}',
                                ),
                                tooltip: isFrench ? 'Partager' : 'Share',
                                visualDensity: VisualDensity.compact,
                                onPressed: onShare,
                                icon: const Icon(Icons.ios_share, size: 17),
                              ),
                            ],
                          )
                        else
                          Text(
                            canOpen
                                ? (isFrench ? 'Voir la fiche' : 'View profile')
                                : (isFrench ? 'Déjà connu' : 'Already known'),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                      ],
                    )
                  : Column(
                      key: const ValueKey('hidden'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PigeonAvatar(
                          pigeon: encounter.pigeon,
                          locked: true,
                          size: 64,
                        ),
                        const Text(
                          '???',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          isFrench ? 'Toucher' : 'Tap',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AmbiencePill extends StatelessWidget {
  const _AmbiencePill({
    required this.ambience,
    required this.currentTime,
    required this.isFrench,
  });

  final ParkAmbience ambience;
  final DateTime currentTime;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    final time =
        '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}';
    return Container(
      key: const ValueKey('park-ambience-pill'),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.navigationBackground.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCDBE9D)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ambience.icon, size: 16, color: AppColors.selected),
          const SizedBox(width: 5),
          Text(
            '$time · ${ambience.weatherLabel(isFrench)}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
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
