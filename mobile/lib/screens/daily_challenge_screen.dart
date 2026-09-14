import 'package:flutter/material.dart';

import '../game/daily_challenge_controller.dart';
import '../game/daily_gift_controller.dart';
import '../game/game_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/pigeon_avatar.dart';

class DailyChallengeScreen extends StatelessWidget {
  const DailyChallengeScreen({
    required this.controller,
    required this.isFrench,
    required this.giftController,
    required this.gameController,
    required this.onMissionDayCompleted,
    super.key,
  });

  final DailyChallengeController controller;
  final bool isFrench;
  final DailyGiftController giftController;
  final GameController gameController;
  final Future<void> Function() onMissionDayCompleted;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, gameController]),
      builder: (context, _) {
        final target = controller.target;
        return Scaffold(
          backgroundColor: AppColors.splashBackground,
          appBar: AppBar(backgroundColor: Colors.transparent),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
              children: [
                Text(
                  isFrench ? 'MISSIONS DU JOUR' : 'DAILY MISSIONS',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                for (final mission in dailyMissions) ...[
                  _DailyMissionCard(
                    mission: mission,
                    controller: controller,
                    gameController: gameController,
                    isFrench: isFrench,
                  ),
                  const SizedBox(height: 9),
                ],
                _MissionChest(
                  controller: controller,
                  gameController: gameController,
                  isFrench: isFrench,
                  onCompleted: onMissionDayCompleted,
                ),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFF76506C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isFrench ? 'PIGEON DU JOUR' : 'PIGEON OF THE DAY',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  target.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 14),
                Center(child: PigeonAvatar(pigeon: target, size: 170)),
                const SizedBox(height: 18),
                Text(
                  '« ${target.hint(isFrench)} »',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                _InfoCard(
                  child: Column(
                    children: [
                      Text(
                        controller.completed
                            ? (isFrench
                                  ? 'Défi terminé !'
                                  : 'Challenge complete!')
                            : (isFrench
                                  ? 'Trouve ${target.name} avant minuit !'
                                  : 'Find ${target.name} before midnight!'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        controller.completed ? '✓' : 'Récompense : 250 🪙',
                        style: TextStyle(
                          color: controller.completed
                              ? AppColors.selected
                              : AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.card_giftcard,
                        color: AppColors.selected,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isFrench ? 'Cadeau quotidien' : 'Daily gift',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              giftController.isAvailable
                                  ? (isFrench
                                        ? '100 miettes disponibles'
                                        : '100 crumbs available')
                                  : '${isFrench ? 'Prochain reset dans' : 'Next reset in'} ${_formatDuration(giftController.timeUntilReset)}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  child: Column(
                    children: [
                      Text(
                        '${isFrench ? 'Série actuelle' : 'Current streak'} : ${controller.streak} 🔥',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          final active = index < controller.streak % 7;
                          return CircleAvatar(
                            radius: 15,
                            backgroundColor: active
                                ? AppColors.selected
                                : const Color(0xFFE0D8C7),
                            child: index == 6
                                ? const Icon(Icons.auto_awesome, size: 15)
                                : Icon(
                                    active
                                        ? Icons.check
                                        : Icons.circle_outlined,
                                    size: 15,
                                    color: active
                                        ? Colors.white
                                        : AppColors.text,
                                  ),
                          );
                        }),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isFrench
                            ? '7 jours : +5 plumes dorées'
                            : '7 days: +5 golden feathers',
                        style: Theme.of(context).textTheme.bodySmall,
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
}

String _formatDuration(Duration duration) {
  final safe = duration.isNegative ? Duration.zero : duration;
  final hours = safe.inHours;
  final minutes = safe.inMinutes.remainder(60);
  return '${hours}h ${minutes.toString().padLeft(2, '0')}';
}

class _DailyMissionCard extends StatelessWidget {
  const _DailyMissionCard({
    required this.mission,
    required this.controller,
    required this.gameController,
    required this.isFrench,
  });

  final DailyMission mission;
  final DailyChallengeController controller;
  final GameController gameController;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    final progress = controller.missionProgress(mission);
    final complete = controller.isMissionComplete(mission);
    final claimed = controller.isMissionClaimed(mission);
    return _InfoCard(
      child: Row(
        children: [
          Icon(_icon, size: 30, color: AppColors.selected),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: progress / mission.target,
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: const Color(0xFFE5DCC8),
                ),
                const SizedBox(height: 4),
                Text('$progress / ${mission.target} · ${_rewardLabel()}'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (claimed)
            const Icon(Icons.check_circle, color: Color(0xFF5E9F59))
          else
            FilledButton(
              key: ValueKey('claim-daily-mission-${mission.type.name}'),
              onPressed: complete
                  ? () => controller.claimMission(mission, gameController)
                  : null,
              child: Text(isFrench ? 'Prendre' : 'Claim'),
            ),
        ],
      ),
    );
  }

  IconData get _icon => switch (mission.type) {
    DailyMissionType.feedPark => Icons.restaurant,
    DailyMissionType.friendshipInteraction => Icons.favorite_outline,
    DailyMissionType.welcomePigeons => Icons.flutter_dash,
  };

  String get _label => switch (mission.type) {
    DailyMissionType.feedPark =>
      isFrench ? 'Nourrir le parc une fois' : 'Feed the park once',
    DailyMissionType.friendshipInteraction =>
      isFrench ? 'Terminer une interaction' : 'Complete an interaction',
    DailyMissionType.welcomePigeons =>
      isFrench ? 'Accueillir trois pigeons' : 'Welcome three pigeons',
  };

  String _rewardLabel() {
    final rewards = <String>[
      if (mission.crumbReward > 0) '${mission.crumbReward} 🪙',
      if (mission.featherReward > 0) '${mission.featherReward} ✨',
    ];
    return rewards.join(' + ');
  }
}

class _MissionChest extends StatelessWidget {
  const _MissionChest({
    required this.controller,
    required this.gameController,
    required this.isFrench,
    required this.onCompleted,
  });

  final DailyChallengeController controller;
  final GameController gameController;
  final bool isFrench;
  final Future<void> Function() onCompleted;

  @override
  Widget build(BuildContext context) {
    final claimedCount = dailyMissions
        .where(controller.isMissionClaimed)
        .length;
    return _InfoCard(
      child: Row(
        children: [
          const Icon(Icons.redeem, size: 34, color: Color(0xFFD49A35)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFrench ? 'Coffre quotidien' : 'Daily chest',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text('$claimedCount / 3 · 150 🪙 + 5 ✨'),
              ],
            ),
          ),
          if (controller.missionChestClaimed)
            const Icon(Icons.check_circle, color: Color(0xFF5E9F59))
          else
            FilledButton(
              key: const ValueKey('claim-daily-mission-chest'),
              onPressed: controller.canClaimMissionChest
                  ? () async {
                      final claimed = await controller.claimMissionChest(
                        gameController,
                      );
                      if (claimed) await onCompleted();
                    }
                  : null,
              child: Text(isFrench ? 'Ouvrir' : 'Open'),
            ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.navigationBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8C9AA)),
      ),
      child: child,
    );
  }
}
