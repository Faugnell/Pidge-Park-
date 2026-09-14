import 'package:flutter/material.dart';

import '../game/visit_journal_controller.dart';
import '../models/food.dart';
import '../models/pigeon.dart';
import '../models/treasure.dart';
import '../theme/app_theme.dart';
import '../widgets/pigeon_avatar.dart';

class VisitJournalScreen extends StatelessWidget {
  const VisitJournalScreen({
    required this.controller,
    required this.isFrench,
    required this.onOpenPigeon,
    super.key,
  });

  final VisitJournalController controller;
  final bool isFrench;
  final ValueChanged<Pigeon> onOpenPigeon;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.placeholderBackground,
    appBar: AppBar(
      title: Text(isFrench ? 'Journal des visites' : 'Visit journal'),
      backgroundColor: Colors.transparent,
    ),
    body: AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.entries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book_outlined, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    isFrench
                        ? 'Tes prochaines visites seront notées ici.'
                        : 'Your next visits will appear here.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: controller.entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) => _VisitCard(
            entry: controller.entries[index],
            isFrench: isFrench,
            onOpenPigeon: onOpenPigeon,
          ),
        );
      },
    ),
  );
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({
    required this.entry,
    required this.isFrench,
    required this.onOpenPigeon,
  });
  final VisitJournalEntry entry;
  final bool isFrench;
  final ValueChanged<Pigeon> onOpenPigeon;

  @override
  Widget build(BuildContext context) {
    final food = foodById(entry.foodId);
    final visitors = entry.pigeonIds
        .map((id) => pigeons.where((item) => item.id == id).firstOrNull)
        .whereType<Pigeon>()
        .toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, size: 18),
                const SizedBox(width: 6),
                Text(_dateLabel(entry.visitedAt)),
                const Spacer(),
                Text('+${entry.crumbReward} 🪙'),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              '${food?.name(isFrench) ?? entry.foodId} · ${visitors.length} ${isFrench ? 'visiteurs' : 'visitors'}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                for (final pigeon in visitors)
                  InkWell(
                    key: ValueKey('journal-pigeon-${pigeon.id}'),
                    onTap: () => onOpenPigeon(pigeon),
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PigeonAvatar(pigeon: pigeon, size: 48),
                        Text(pigeon.name, style: const TextStyle(fontSize: 11)),
                        if (entry.newPigeonIds.contains(pigeon.id))
                          Text(
                            isFrench ? 'Nouveau !' : 'New!',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.selected,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            if (entry.treasureIds.isNotEmpty) ...[
              const Divider(height: 22),
              Text(
                '${isFrench ? 'Trésor trouvé' : 'Treasure found'} : ${entry.treasureIds.map(_treasureName).join(', ')}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final sameDay =
        now.year == date.year && now.month == date.month && now.day == date.day;
    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    if (sameDay) return '${isFrench ? 'Aujourd’hui' : 'Today'} · $time';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} · $time';
  }

  String _treasureName(String id) =>
      treasures
          .where((item) => item.id == id)
          .map((item) => item.name(isFrench))
          .firstOrNull ??
      id;
}
