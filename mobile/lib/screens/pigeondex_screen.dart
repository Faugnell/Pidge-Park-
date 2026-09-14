import 'dart:async';

import 'package:flutter/material.dart';

import '../collection/pigeon_collection_controller.dart';
import '../game/friendship_activity_controller.dart';
import '../game/game_controller.dart';
import '../game/decoration_controller.dart';
import '../game/daily_challenge_controller.dart';
import '../models/food.dart';
import '../models/decoration.dart';
import '../models/pigeon.dart';
import '../models/pigeon_keepsake.dart';
import '../models/treasure.dart';
import '../theme/app_theme.dart';
import '../widgets/pigeon_avatar.dart';
import '../widgets/pigeon_share_card.dart';

class PigeondexScreen extends StatefulWidget {
  const PigeondexScreen({
    required this.controller,
    required this.gameController,
    required this.activityController,
    required this.isFrench,
    required this.onActivityChanged,
    required this.dailyChallengeController,
    required this.decorationController,
    required this.onProgressChanged,
    super.key,
  });

  final PigeonCollectionController controller;
  final GameController gameController;
  final FriendshipActivityController activityController;
  final bool isFrench;
  final Future<void> Function() onActivityChanged;
  final DailyChallengeController dailyChallengeController;
  final DecorationController decorationController;
  final Future<void> Function({
    String? foodId,
    bool flockWelcomed,
    bool missionDayCompleted,
  })
  onProgressChanged;

  @override
  State<PigeondexScreen> createState() => _PigeondexScreenState();
}

class _PigeondexScreenState extends State<PigeondexScreen> {
  PigeonRarity? _selectedRarity;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.controller,
        widget.activityController,
      ]),
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final visiblePigeons = _selectedRarity == null
        ? pigeons
        : pigeons.where((pigeon) => pigeon.rarity == _selectedRarity).toList();
    final discoveredCount = pigeons
        .where((pigeon) => widget.controller.progressFor(pigeon.id).discovered)
        .length;

    return ColoredBox(
      color: AppColors.placeholderBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 18),
            Text(
              'PIGEONDEX',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$discoveredCount / ${pigeons.length}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _CollectionProgressCard(
                controller: widget.controller,
                gameController: widget.gameController,
                decorationController: widget.decorationController,
                isFrench: widget.isFrench,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _FilterChip(
                    label: widget.isFrench ? 'Tous' : 'All',
                    selected: _selectedRarity == null,
                    onSelected: () => setState(() => _selectedRarity = null),
                  ),
                  for (final rarity in PigeonRarity.values)
                    _FilterChip(
                      label: rarity.label(widget.isFrench),
                      selected: _selectedRarity == rarity,
                      onSelected: () {
                        setState(() => _selectedRarity = rarity);
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                key: const ValueKey('pigeondex-grid'),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.78,
                ),
                itemCount: visiblePigeons.length,
                itemBuilder: (context, index) {
                  final pigeon = visiblePigeons[index];
                  final progress = widget.controller.progressFor(pigeon.id);
                  return _PigeonCard(
                    pigeon: pigeon,
                    progress: progress,
                    isFrench: widget.isFrench,
                    isBusy:
                        widget.activityController.activePigeonId == pigeon.id,
                    isNew: widget.controller.newPigeonIds.contains(pigeon.id),
                    accessoryIcon: pigeonKeepsakes
                        .where(
                          (item) =>
                              item.id ==
                              widget.controller.equippedAccessoryId(pigeon.id),
                        )
                        .firstOrNull
                        ?.icon,
                    companionIcon: pigeonKeepsakes
                        .where(
                          (item) =>
                              item.id ==
                              widget.controller.equippedCompanionId(pigeon.id),
                        )
                        .firstOrNull
                        ?.icon,
                    accessoryId: widget.controller.equippedAccessoryId(
                      pigeon.id,
                    ),
                    companionId: widget.controller.equippedCompanionId(
                      pigeon.id,
                    ),
                    onTap: () async {
                      if (!progress.discovered) {
                        _showHint(context, pigeon);
                        return;
                      }
                      await widget.controller.markPigeonSeen(pigeon.id);
                      if (!context.mounted) return;
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PigeonDetailScreen(
                            pigeon: pigeon,
                            controller: widget.controller,
                            gameController: widget.gameController,
                            activityController: widget.activityController,
                            isFrench: widget.isFrench,
                            onActivityChanged: widget.onActivityChanged,
                            dailyChallengeController:
                                widget.dailyChallengeController,
                            onProgressChanged: widget.onProgressChanged,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHint(BuildContext context, Pigeon pigeon) {
    final discoveredCount = pigeons
        .where((item) => widget.controller.progressFor(item.id).discovered)
        .length;
    final revealedConditions = discoveredCount >= 12
        ? 4
        : discoveredCount >= 8
        ? 3
        : discoveredCount >= 5
        ? 2
        : discoveredCount >= 3
        ? 1
        : 0;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.splashBackground,
        icon: const Icon(Icons.help_outline, size: 38),
        title: Text('#${pigeon.number.toString().padLeft(3, '0')} — ???'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '« ${pigeon.hint(widget.isFrench)} »',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _DiscoveryConditions(
              pigeon: pigeon,
              isFrench: widget.isFrench,
              revealedCount: revealedConditions,
            ),
            if (revealedConditions < 4) ...[
              const SizedBox(height: 10),
              Text(
                widget.isFrench
                    ? 'Découvre davantage de pigeons pour obtenir de nouveaux indices.'
                    : 'Discover more pigeons to reveal new clues.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              widget.isFrench ? 'Je vais chercher' : 'I’ll investigate',
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionProgressCard extends StatelessWidget {
  const _CollectionProgressCard({
    required this.controller,
    required this.gameController,
    required this.decorationController,
    required this.isFrench,
  });

  final PigeonCollectionController controller;
  final GameController gameController;
  final DecorationController decorationController;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    final progress = controller.discoveredCount / pigeons.length;
    final claimable = collectionGoals
        .where(controller.canClaimCollectionGoal)
        .length;
    return Material(
      color: AppColors.navigationBackground,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        key: const ValueKey('collection-goals-button'),
        borderRadius: BorderRadius.circular(15),
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => _CollectionGoalsDialog(
            controller: controller,
            gameController: gameController,
            decorationController: decorationController,
            isFrench: isFrench,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              const Icon(
                Icons.emoji_events_outlined,
                color: AppColors.selected,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFrench ? 'Objectifs de collection' : 'Collection goals',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 5),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      borderRadius: BorderRadius.circular(8),
                      backgroundColor: const Color(0xFFE5DCC8),
                      color: AppColors.selected,
                    ),
                  ],
                ),
              ),
              if (claimable > 0) ...[
                const SizedBox(width: 8),
                Badge(
                  key: const ValueKey('claimable-collection-goals'),
                  label: Text('$claimable'),
                  child: const Icon(Icons.card_giftcard),
                ),
              ] else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionGoalsDialog extends StatefulWidget {
  const _CollectionGoalsDialog({
    required this.controller,
    required this.gameController,
    required this.decorationController,
    required this.isFrench,
  });

  final PigeonCollectionController controller;
  final GameController gameController;
  final DecorationController decorationController;
  final bool isFrench;

  @override
  State<_CollectionGoalsDialog> createState() => _CollectionGoalsDialogState();
}

class _CollectionGoalsDialogState extends State<_CollectionGoalsDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.splashBackground,
      title: Text(
        widget.isFrench ? 'Objectifs du Pigeondex' : 'Pigeondex goals',
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: 380,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              widget.isFrench ? 'Collection générale' : 'Main collection',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            for (final goal in collectionGoals.where(
              (item) => item.rarity == null,
            ))
              _goalTile(goal),
            const SizedBox(height: 12),
            Text(
              widget.isFrench ? 'Collections par rareté' : 'Rarity collections',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            for (final goal in collectionGoals.where(
              (item) => item.rarity != null,
            ))
              _goalTile(goal),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.isFrench ? 'Fermer' : 'Close'),
        ),
      ],
    );
  }

  Widget _goalTile(CollectionGoal goal) {
    final current = widget.controller.progressForGoal(goal);
    final target = widget.controller.targetForGoal(goal);
    final claimed = widget.controller.isCollectionGoalClaimed(goal.id);
    final canClaim = widget.controller.canClaimCollectionGoal(goal);
    final label = goal.rarity == null
        ? (widget.isFrench
              ? '$target pigeons découverts'
              : '$target pigeons discovered')
        : '${goal.rarity!.label(widget.isFrench)} · $target/$target';
    return Card(
      margin: const EdgeInsets.only(bottom: 7),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(
              claimed ? Icons.check_circle : Icons.lock_open_outlined,
              color: claimed ? const Color(0xFF4F9D58) : AppColors.selected,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '$current/$target · ${goal.crumbs} 🪙 · ${goal.feathers} ✨'
                    '${goal.decorationId == null ? '' : ' · 🎏'}'
                    '${goal.completionReward ? (widget.isFrench ? ' · Thème à venir' : ' · Theme coming soon') : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (claimed)
              Text(widget.isFrench ? 'Reçu' : 'Claimed')
            else
              FilledButton(
                key: ValueKey('claim-collection-goal-${goal.id}'),
                onPressed: canClaim ? () => _claim(goal) : null,
                child: Text(widget.isFrench ? 'Prendre' : 'Claim'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _claim(CollectionGoal goal) async {
    if (!await widget.controller.claimCollectionGoal(goal)) return;
    await widget.gameController.addReward(
      crumbs: goal.crumbs,
      feathers: goal.feathers,
    );
    if (goal.decorationId case final decorationId?) {
      await widget.decorationController.grant(decorationId);
    }
    if (!mounted) return;
    setState(() {});
    if (goal.completionReward) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.auto_awesome, size: 52),
          title: const Text('PIGEONDEX 100 % !'),
          content: Text(
            widget.isFrench
                ? 'Tous les pigeons ont été découverts. Un thème commémoratif arrivera prochainement !'
                : 'Every pigeon has been discovered. A commemorative theme is coming soon!',
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(widget.isFrench ? 'Incroyable !' : 'Amazing!'),
            ),
          ],
        ),
      );
    }
  }
}

class _DiscoveryConditions extends StatelessWidget {
  const _DiscoveryConditions({
    required this.pigeon,
    required this.isFrench,
    required this.revealedCount,
  });

  final Pigeon pigeon;
  final bool isFrench;
  final int revealedCount;

  @override
  Widget build(BuildContext context) {
    final conditions = <({IconData icon, String label, String value})>[
      (
        icon: Icons.restaurant_outlined,
        label: isFrench ? 'Nourriture' : 'Food',
        value: _foodCondition,
      ),
      (
        icon: Icons.chair_alt_outlined,
        label: isFrench ? 'Décoration' : 'Decoration',
        value: _decorationCondition,
      ),
      (
        icon: Icons.schedule,
        label: isFrench ? 'Moment' : 'Time',
        value: _periodCondition,
      ),
      (
        icon: Icons.cloud_outlined,
        label: isFrench ? 'Météo' : 'Weather',
        value: _weatherCondition,
      ),
    ];
    return Column(
      children: [
        for (var index = 0; index < conditions.length; index++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  conditions[index].icon,
                  size: 18,
                  color: AppColors.selected,
                ),
                const SizedBox(width: 8),
                Text(
                  '${conditions[index].label} : ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Expanded(
                  child: Text(
                    key: ValueKey('discovery-condition-$index'),
                    index < revealedCount ? conditions[index].value : '???',
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String get _foodCondition {
    if (pigeon.foodIds.isEmpty) {
      return isFrench ? 'Peu importe' : 'Any food';
    }
    return pigeon.foodIds
        .map((id) => foodById(id)?.name(isFrench) ?? id)
        .join(', ');
  }

  String get _decorationCondition {
    if (pigeon.decorationIds.isEmpty) {
      return isFrench ? 'Aucune en particulier' : 'Nothing special';
    }
    return pigeon.decorationIds
        .map(
          (id) =>
              decorations
                  .where((item) => item.id == id)
                  .map((item) => item.name(isFrench))
                  .firstOrNull ??
              id,
        )
        .join(', ');
  }

  String get _periodCondition => switch (pigeon.period) {
    VisitPeriod.any => isFrench ? 'Toute la journée' : 'Any time',
    VisitPeriod.morning => isFrench ? 'Le matin' : 'Morning',
    VisitPeriod.night => isFrench ? 'La nuit' : 'Night',
  };

  String get _weatherCondition => switch (pigeon.weather) {
    PigeonWeather.any => isFrench ? 'Peu importe' : 'Any weather',
    PigeonWeather.sunny => isFrench ? 'Soleil' : 'Sunny',
    PigeonWeather.cloudy => isFrench ? 'Nuages' : 'Cloudy',
    PigeonWeather.rainy => isFrench ? 'Petite pluie' : 'Light rain',
  };
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        selectedColor: AppColors.park,
        backgroundColor: AppColors.navigationBackground,
        side: const BorderSide(color: Color(0xFFCDBE9D)),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        showCheckmark: false,
      ),
    );
  }
}

class _PigeonCard extends StatelessWidget {
  const _PigeonCard({
    required this.pigeon,
    required this.progress,
    required this.isFrench,
    required this.onTap,
    required this.isBusy,
    required this.isNew,
    required this.accessoryIcon,
    required this.companionIcon,
    required this.accessoryId,
    required this.companionId,
  });

  final Pigeon pigeon;
  final PigeonProgress progress;
  final bool isFrench;
  final VoidCallback? onTap;
  final bool isBusy;
  final bool isNew;
  final IconData? accessoryIcon;
  final IconData? companionIcon;
  final String? accessoryId;
  final String? companionId;

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
        key: ValueKey('pigeon-${pigeon.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    pigeon.number.toString().padLeft(3, '0'),
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: const Color(0xFF958A76)),
                  ),
                  if (isBusy) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.schedule,
                      key: ValueKey('busy-pigeon-indicator'),
                      size: 13,
                      color: AppColors.selected,
                    ),
                  ],
                  if (isNew) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.fiber_new,
                      key: ValueKey('new-pigeon-indicator'),
                      size: 16,
                      color: AppColors.selected,
                    ),
                  ],
                ],
              ),
              const Spacer(),
              PigeonAvatar(
                pigeon: pigeon,
                locked: !progress.discovered,
                size: 64,
                accessoryIcon: accessoryIcon,
                companionIcon: companionIcon,
                accessoryId: accessoryId,
                companionId: companionId,
              ),
              const Spacer(),
              Text(
                progress.discovered ? pigeon.name : '???',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: pigeon.rarity.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  progress.discovered ? pigeon.rarity.label(isFrench) : '???',
                  style: TextStyle(
                    color: pigeon.rarity.color,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PigeonDetailScreen extends StatelessWidget {
  const PigeonDetailScreen({
    required this.pigeon,
    required this.controller,
    required this.gameController,
    required this.activityController,
    required this.isFrench,
    required this.onActivityChanged,
    required this.dailyChallengeController,
    required this.onProgressChanged,
    super.key,
  });

  final Pigeon pigeon;
  final PigeonCollectionController controller;
  final GameController gameController;
  final FriendshipActivityController activityController;
  final bool isFrench;
  final Future<void> Function() onActivityChanged;
  final DailyChallengeController dailyChallengeController;
  final Future<void> Function({
    String? foodId,
    bool flockWelcomed,
    bool missionDayCompleted,
  })
  onProgressChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        controller,
        gameController,
        activityController,
      ]),
      builder: (context, _) {
        final progress = controller.progressFor(pigeon.id);
        return Scaffold(
          backgroundColor: AppColors.splashBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(pigeon.name),
            actions: [
              IconButton(
                key: const ValueKey('share-pigeon-from-pigeondex'),
                tooltip: isFrench ? 'Partager la fiche' : 'Share card',
                onPressed: () => showPigeonShareCard(
                  context,
                  pigeon: pigeon,
                  progress: progress,
                  isFrench: isFrench,
                  accessoryIcon: _equippedAccessory?.icon,
                  companionIcon: _equippedCompanion?.icon,
                  accessoryId: _equippedAccessory?.id,
                  companionId: _equippedCompanion?.id,
                ),
                icon: const Icon(Icons.ios_share),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              children: [
                const SizedBox(height: 12),
                Center(
                  child: PigeonAvatar(
                    pigeon: pigeon,
                    size: 190,
                    accessoryIcon: _equippedAccessory?.icon,
                    companionIcon: _equippedCompanion?.icon,
                    accessoryId: _equippedAccessory?.id,
                    companionId: _equippedCompanion?.id,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  pigeon.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: pigeon.rarity.color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pigeon.rarity.label(isFrench).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                if (controller.hasClaimedFriendshipMilestone(
                  pigeon.id,
                  10,
                )) ...[
                  const SizedBox(height: 8),
                  Chip(
                    avatar: const Icon(Icons.workspace_premium, size: 18),
                    label: Text(
                      isFrench ? 'MEILLEUR AMI' : 'BEST FRIEND',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    backgroundColor: const Color(0xFFFFE5A3),
                    side: const BorderSide(color: Color(0xFFD49A35)),
                  ),
                ],
                const SizedBox(height: 24),
                _DetailCard(
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: Color(0xFFE35F55)),
                      const SizedBox(width: 10),
                      Text(
                        '${progress.affection}/10',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        key: const ValueKey('give-gift'),
                        onPressed:
                            progress.isMaxFriendship ||
                                gameController.crumbs < 25
                            ? null
                            : () => _giveFood(context, points: 2, cost: 25),
                        icon: const Icon(Icons.restaurant, size: 19),
                        label: Text(isFrench ? 'Friandise · 25' : 'Treat · 25'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress.isMaxFriendship ? 1 : progress.levelProgress,
                  minHeight: 9,
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: const Color(0xFFE5DCC8),
                  color: const Color(0xFFE35F55),
                ),
                const SizedBox(height: 7),
                Text(
                  progress.isMaxFriendship
                      ? (isFrench ? 'Amitié maximale !' : 'Maximum friendship!')
                      : (isFrench
                            ? '${progress.pointsIntoLevel} / ${progress.pointsRequiredForNextLevel} points · encore ${progress.pointsUntilNextLevel} avant le prochain cœur'
                            : '${progress.pointsIntoLevel} / ${progress.pointsRequiredForNextLevel} points · ${progress.pointsUntilNextLevel} until the next heart'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                _DetailCard(
                  child: Column(
                    children: [
                      Text(
                        isFrench
                            ? 'Conditions de rencontre'
                            : 'Meeting conditions',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      _DiscoveryConditions(
                        pigeon: pigeon,
                        isFrench: isFrench,
                        revealedCount: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _FriendshipMilestonesCard(
                  pigeon: pigeon,
                  collectionController: controller,
                  gameController: gameController,
                  isFrench: isFrench,
                  onProgressChanged: onProgressChanged,
                ),
                const SizedBox(height: 12),
                _KeepsakeCard(
                  pigeon: pigeon,
                  controller: controller,
                  isFrench: isFrench,
                ),
                const SizedBox(height: 12),
                _DetailCard(
                  child: Column(
                    children: [
                      Text(
                        isFrench ? 'Personnalité' : 'Personality',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pigeon.personality.temperament(isFrench),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '« ${pigeon.personality.catchphrase(isFrench)} »',
                        key: const ValueKey('pigeon-catchphrase'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppColors.selected,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Chip(
                        avatar: const Icon(Icons.favorite_outline, size: 17),
                        label: Text(
                          '${isFrench ? 'Activité préférée' : 'Favourite activity'} : '
                          '${activityController.favoriteActivityFor(pigeon.id).label(isFrench)}',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _DetailCard(
                  child: Column(
                    children: [
                      Text(
                        isFrench ? 'Aliment préféré' : 'Favourite food',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        _favoriteFood.icon,
                        size: 34,
                        color: _favoriteFood.color,
                      ),
                      const SizedBox(height: 4),
                      Text(_favoriteFood.name(isFrench)),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        key: const ValueKey('give-favorite-food'),
                        onPressed:
                            progress.isMaxFriendship ||
                                gameController.crumbs < _favoriteFoodCost
                            ? null
                            : () => _giveFood(
                                context,
                                points: 5,
                                cost: _favoriteFoodCost,
                              ),
                        icon: const Icon(Icons.favorite, size: 18),
                        label: Text('+5 points · $_favoriteFoodCost 🪙'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _FriendshipActivityCard(
                  pigeon: pigeon,
                  collectionController: controller,
                  activityController: activityController,
                  gameController: gameController,
                  isFrench: isFrench,
                  onActivityChanged: onActivityChanged,
                  dailyChallengeController: dailyChallengeController,
                  onProgressChanged: onProgressChanged,
                ),
                const SizedBox(height: 12),
                _DetailCard(
                  child: Text(
                    controller.hasClaimedFriendshipMilestone(pigeon.id, 2)
                        ? pigeon.description(isFrench)
                        : (isFrench
                              ? 'Une anecdote sur ${pigeon.name} se débloque au niveau 2.'
                              : 'A fun fact about ${pigeon.name} unlocks at level 2.'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 12),
                _DetailCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isFrench ? 'Visites' : 'Visits'),
                      Text(
                        '${progress.visits}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isFrench
                      ? 'Chaque visite donne 1 point. Une friandise en donne 2 et l’aliment préféré 5.'
                      : 'Each visit gives 1 point. A treat gives 2 and favourite food gives 5.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Food get _favoriteFood => foodById(pigeon.foodIds.firstOrNull) ?? foods.first;

  PigeonKeepsake? get _equippedAccessory => pigeonKeepsakes
      .where((item) => item.id == controller.equippedAccessoryId(pigeon.id))
      .firstOrNull;

  PigeonKeepsake? get _equippedCompanion => pigeonKeepsakes
      .where((item) => item.id == controller.equippedCompanionId(pigeon.id))
      .firstOrNull;

  int get _favoriteFoodCost => (_favoriteFood.price ~/ 4).clamp(25, 250);

  Future<void> _giveFood(
    BuildContext context, {
    required int points,
    required int cost,
  }) async {
    final spent = await gameController.spendCrumbs(cost);
    if (!spent) return;
    final given = await controller.giveFood(pigeon.id, points: points);
    if (!given) {
      await gameController.addReward(crumbs: cost);
      return;
    }
    await onProgressChanged();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFrench ? '+$points points d’amitié' : '+$points friendship points',
        ),
      ),
    );
  }
}

class _KeepsakeCard extends StatelessWidget {
  const _KeepsakeCard({
    required this.pigeon,
    required this.controller,
    required this.isFrench,
  });

  final Pigeon pigeon;
  final PigeonCollectionController controller;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    final progress = controller.progressFor(pigeon.id);
    final keepsake = keepsakeForPigeon(pigeon.id);
    final owned = controller.ownsKeepsake(keepsake.id);
    final equipped =
        controller.equippedAccessoryId(pigeon.id) == keepsake.id ||
        controller.equippedCompanionId(pigeon.id) == keepsake.id;
    return _DetailCard(
      child: Column(
        children: [
          Text(
            isFrench ? 'Objet personnel' : 'Personal keepsake',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Icon(
            progress.isMaxFriendship
                ? (owned ? keepsake.icon : Icons.help_outline)
                : Icons.lock_outline,
            size: 38,
            color: owned ? AppColors.selected : const Color(0xFF948C7C),
          ),
          const SizedBox(height: 5),
          Text(
            !progress.isMaxFriendship
                ? (isFrench
                      ? 'Disponible au niveau d’amitié 10'
                      : 'Available at friendship level 10')
                : owned
                ? keepsake.name(isFrench)
                : (isFrench ? 'Objet encore inconnu' : 'Unknown keepsake'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            progress.isMaxFriendship
                ? (isFrench
                      ? 'Peut être rapporté après une visite · chance de base ${_chanceLabel(pigeon)}'
                      : 'May be brought back after a visit · base chance ${_chanceLabel(pigeon)}')
                : (isFrench
                      ? 'Deviens son meilleur ami pour commencer la recherche.'
                      : 'Become best friends to begin the search.'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (owned && keepsake.kind != KeepsakeKind.souvenir) ...[
            const SizedBox(height: 9),
            FilledButton.icon(
              key: ValueKey('equip-keepsake-${keepsake.id}'),
              onPressed: () => controller.toggleKeepsake(keepsake),
              icon: Icon(equipped ? Icons.check : Icons.checkroom),
              label: Text(
                equipped
                    ? (isFrench ? 'Équipé' : 'Equipped')
                    : (isFrench ? 'Équiper' : 'Equip'),
              ),
            ),
          ] else if (owned) ...[
            const SizedBox(height: 7),
            Text(
              isFrench ? 'Souvenir collectionné ✓' : 'Keepsake collected ✓',
              style: const TextStyle(color: Color(0xFF4F9D58)),
            ),
          ],
        ],
      ),
    );
  }

  String _chanceLabel(Pigeon pigeon) {
    final percent = keepsakeBaseChance(pigeon) * 100;
    return percent >= 1
        ? '${percent.toStringAsFixed(0)} %'
        : '${percent.toStringAsFixed(percent == 0.1 ? 1 : 2)} %';
  }
}

class _FriendshipMilestonesCard extends StatelessWidget {
  const _FriendshipMilestonesCard({
    required this.pigeon,
    required this.collectionController,
    required this.gameController,
    required this.isFrench,
    required this.onProgressChanged,
  });

  final Pigeon pigeon;
  final PigeonCollectionController collectionController;
  final GameController gameController;
  final bool isFrench;
  final Future<void> Function({
    String? foodId,
    bool flockWelcomed,
    bool missionDayCompleted,
  })
  onProgressChanged;

  @override
  Widget build(BuildContext context) {
    final progress = collectionController.progressFor(pigeon.id);
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isFrench ? 'Récompenses d’amitié' : 'Friendship rewards',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          for (final level
              in PigeonCollectionController.friendshipMilestoneLevels)
            _MilestoneRow(
              level: level,
              label: _rewardLabel(level),
              unlocked: progress.affection >= level,
              claimed: collectionController.hasClaimedFriendshipMilestone(
                pigeon.id,
                level,
              ),
              isFrench: isFrench,
              onClaim: () => _claim(context, level),
            ),
        ],
      ),
    );
  }

  String _rewardLabel(int level) {
    switch (level) {
      case 2:
        return isFrench ? 'Anecdote + 100 miettes' : 'Fun fact + 100 crumbs';
      case 4:
        return isFrench
            ? 'Interaction favorite révélée'
            : 'Favourite interaction revealed';
      case 6:
        final treasure = treasureForPigeon(pigeon.id);
        final treasureName =
            treasure?.name(isFrench) ??
            (isFrench ? 'Trésor à venir' : 'Treasure coming soon');
        return '$treasureName + 5 ✨';
      case 10:
        return isFrench
            ? 'Badge Meilleur ami + 300 miettes + 10 ✨'
            : 'Best Friend badge + 300 crumbs + 10 ✨';
      default:
        return '';
    }
  }

  Future<void> _claim(BuildContext context, int level) async {
    final claimed = await collectionController.claimFriendshipMilestone(
      pigeon.id,
      level,
    );
    if (!claimed) return;
    switch (level) {
      case 2:
        await gameController.addReward(crumbs: 100);
      case 6:
        await gameController.addReward(crumbs: 0, feathers: 5);
      case 10:
        await gameController.addReward(crumbs: 300, feathers: 10);
    }
    await onProgressChanged();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFrench
              ? 'Récompense du niveau $level récupérée !'
              : 'Level $level reward claimed!',
        ),
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({
    required this.level,
    required this.label,
    required this.unlocked,
    required this.claimed,
    required this.isFrench,
    required this.onClaim,
  });

  final int level;
  final String label;
  final bool unlocked;
  final bool claimed;
  final bool isFrench;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: unlocked
                ? const Color(0xFFFFE5A3)
                : const Color(0xFFE5DCC8),
            child: Text(
              '$level',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          if (claimed)
            const Icon(Icons.check_circle, color: Color(0xFF5E9F59))
          else if (unlocked)
            FilledButton(
              key: ValueKey('claim-friendship-milestone-$level'),
              onPressed: onClaim,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                visualDensity: VisualDensity.compact,
              ),
              child: Text(isFrench ? 'Prendre' : 'Claim'),
            )
          else
            const Icon(Icons.lock_outline, color: Color(0xFF948C7C)),
        ],
      ),
    );
  }
}

class _FriendshipActivityCard extends StatefulWidget {
  const _FriendshipActivityCard({
    required this.pigeon,
    required this.collectionController,
    required this.activityController,
    required this.gameController,
    required this.isFrench,
    required this.onActivityChanged,
    required this.dailyChallengeController,
    required this.onProgressChanged,
  });

  final Pigeon pigeon;
  final PigeonCollectionController collectionController;
  final FriendshipActivityController activityController;
  final GameController gameController;
  final bool isFrench;
  final Future<void> Function() onActivityChanged;
  final DailyChallengeController dailyChallengeController;
  final Future<void> Function({
    String? foodId,
    bool flockWelcomed,
    bool missionDayCompleted,
  })
  onProgressChanged;

  @override
  State<_FriendshipActivityCard> createState() =>
      _FriendshipActivityCardState();
}

class _FriendshipActivityCardState extends State<_FriendshipActivityCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && widget.activityController.hasActiveActivity) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.activityController;
    final activeForThisPigeon = controller.activePigeonId == widget.pigeon.id;
    final favoriteRevealed =
        controller.completedInteractionsFor(widget.pigeon.id) >= 3 ||
        widget.collectionController.hasClaimedFriendshipMilestone(
          widget.pigeon.id,
          4,
        );
    final favorite = controller.favoriteActivityFor(widget.pigeon.id);
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.isFrench ? 'Interaction quotidienne' : 'Daily interaction',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            favoriteRevealed
                ? (widget.isFrench
                      ? 'Préférence : ${favorite.label(true)} 💛'
                      : 'Favourite: ${favorite.label(false)} 💛')
                : (widget.isFrench
                      ? 'Préférence à découvrir (${controller.completedInteractionsFor(widget.pigeon.id)}/3)'
                      : 'Favourite to discover (${controller.completedInteractionsFor(widget.pigeon.id)}/3)'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          if (activeForThisPigeon) ...[
            Text(
              controller.activeActivity!.label(widget.isFrench),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (!controller.isComplete)
              Text(
                _formatDuration(controller.remaining),
                key: const ValueKey('friendship-activity-countdown'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              )
            else
              FilledButton(
                key: const ValueKey('claim-friendship-activity'),
                onPressed: _claim,
                child: Text(
                  widget.isFrench
                      ? 'Récupérer +${_activeReward(controller)}'
                      : 'Claim +${_activeReward(controller)}',
                ),
              ),
          ] else if (controller.hasActiveActivity) ...[
            Text(
              widget.isFrench
                  ? 'Une interaction est déjà en cours avec ${_activePigeonName(controller)}.'
                  : 'An interaction is already in progress with ${_activePigeonName(controller)}.',
              textAlign: TextAlign.center,
            ),
          ] else if (!controller.canInteractWith(widget.pigeon.id)) ...[
            Text(
              widget.isFrench
                  ? 'Interaction déjà effectuée aujourd’hui.'
                  : 'Interaction already completed today.',
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final activity in FriendshipActivity.values)
                  OutlinedButton(
                    key: ValueKey('activity-${activity.name}'),
                    onPressed: () async {
                      final started = await controller.start(
                        widget.pigeon.id,
                        activity,
                      );
                      if (started) await widget.onActivityChanged();
                    },
                    child: Text(
                      '${activity.label(widget.isFrench)} · +${activity.points}'
                      '${favoriteRevealed && activity == favorite ? ' 💛' : ''}',
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _activePigeonName(FriendshipActivityController controller) => pigeons
      .firstWhere((pigeon) => pigeon.id == controller.activePigeonId)
      .name;

  Future<void> _claim() async {
    final wasFavorite = widget.activityController.isFavoriteActivity(
      widget.pigeon.id,
      widget.activityController.activeActivity!,
    );
    final points = await widget.activityController.claim(
      widget.collectionController,
    );
    if (points != null) {
      final duplicateFeathers =
          widget.activityController.lastKeepsakeDrop?.featherReward ?? 0;
      if (duplicateFeathers > 0) {
        await widget.gameController.addReward(
          crumbs: 0,
          feathers: duplicateFeathers,
        );
      }
      await widget.dailyChallengeController.recordFriendshipInteraction();
      await widget.onProgressChanged();
    }
    if (points != null) await widget.onActivityChanged();
    if (points == null || !mounted) return;
    final drop = widget.activityController.lastKeepsakeDrop;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          drop != null
              ? (drop.isDuplicate
                    ? (widget.isFrench
                          ? '${drop.keepsake.name(true)} était déjà dans ta collection · +${drop.featherReward} plumes'
                          : '${drop.keepsake.name(false)} was already collected · +${drop.featherReward} feathers')
                    : (widget.isFrench
                          ? '${widget.pigeon.name} a rapporté ${drop.keepsake.name(true)} ! « ${drop.keepsake.discoveryLine(true)} »'
                          : '${widget.pigeon.name} brought back ${drop.keepsake.name(false)}! “${drop.keepsake.discoveryLine(false)}”'))
              : widget.isFrench
              ? (wasFavorite
                    ? '${widget.pigeon.name} a adoré ! +$points points d’amitié'
                    : '${widget.pigeon.name} a apprécié ! +$points points d’amitié')
              : (wasFavorite
                    ? '${widget.pigeon.name} loved it! +$points friendship points'
                    : '${widget.pigeon.name} enjoyed it! +$points friendship points'),
        ),
      ),
    );
  }

  int _activeReward(FriendshipActivityController controller) {
    final activity = controller.activeActivity!;
    return activity.points +
        (controller.isFavoriteActivity(widget.pigeon.id, activity) ? 2 : 0);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inHours > 0 ? '${duration.inHours}:' : ''}$minutes:$seconds';
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navigationBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8C9AA)),
      ),
      child: child,
    );
  }
}
