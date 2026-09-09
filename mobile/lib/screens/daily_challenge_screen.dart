import 'package:flutter/material.dart';

import '../game/daily_challenge_controller.dart';
import '../game/daily_gift_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/pigeon_avatar.dart';

class DailyChallengeScreen extends StatelessWidget {
  const DailyChallengeScreen({
    required this.controller,
    required this.isFrench,
    required this.giftController,
    super.key,
  });

  final DailyChallengeController controller;
  final bool isFrench;
  final DailyGiftController giftController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
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
