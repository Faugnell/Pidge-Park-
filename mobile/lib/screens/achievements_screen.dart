import 'package:flutter/material.dart';

import '../collection/pigeon_collection_controller.dart';
import '../game/achievement_controller.dart';
import '../game/decoration_controller.dart';
import '../theme/app_theme.dart';

enum _AchievementSort { normal, unlockedFirst, lockedFirst }

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({
    required this.controller,
    required this.collection,
    required this.decorations,
    required this.isFrench,
    super.key,
  });
  final AchievementController controller;
  final PigeonCollectionController collection;
  final DecorationController decorations;
  final bool isFrench;

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();

  String title(AchievementType type) => switch (type) {
    AchievementType.firstFlock =>
      isFrench ? 'Premier rendez-vous' : 'First date',
    AchievementType.discoverFive =>
      isFrench ? 'Bande de copains' : 'A flock of friends',
    AchievementType.discoverFifteen =>
      isFrench ? 'Ornithologue du dimanche' : 'Weekend birdwatcher',
    AchievementType.bestFriend => isFrench ? 'Inséparables' : 'Inseparable',
    AchievementType.decorator =>
      isFrench ? 'Décorateur en herbe' : 'Budding decorator',
    AchievementType.foodExplorer =>
      isFrench ? 'Fin gourmet' : 'Food connoisseur',
    AchievementType.parkRegular =>
      isFrench ? 'Habitué du parc' : 'Park regular',
    AchievementType.treasureHunter =>
      isFrench ? 'Chasseur de trésors' : 'Treasure hunter',
  };

  String description(AchievementType type) => switch (type) {
    AchievementType.firstFlock =>
      isFrench ? 'Accueille ton premier groupe.' : 'Welcome your first flock.',
    AchievementType.discoverFive =>
      isFrench ? 'Découvre 5 pigeons.' : 'Discover 5 pigeons.',
    AchievementType.discoverFifteen =>
      isFrench ? 'Découvre 15 pigeons.' : 'Discover 15 pigeons.',
    AchievementType.bestFriend =>
      isFrench
          ? 'Atteins le niveau 10 avec un pigeon.'
          : 'Reach level 10 with a pigeon.',
    AchievementType.decorator =>
      isFrench ? 'Équipe 3 décorations.' : 'Equip 3 decorations.',
    AchievementType.foodExplorer =>
      isFrench ? 'Essaie 5 aliments différents.' : 'Try 5 different foods.',
    AchievementType.parkRegular =>
      isFrench
          ? 'Termine 7 journées de missions.'
          : 'Complete 7 days of missions.',
    AchievementType.treasureHunter =>
      isFrench ? 'Récupère 5 trésors.' : 'Collect 5 treasures.',
  };
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  _AchievementSort _sort = _AchievementSort.normal;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.placeholderBackground,
    appBar: AppBar(
      title: Text(widget.isFrench ? 'Succès' : 'Achievements'),
      backgroundColor: Colors.transparent,
    ),
    body: AnimatedBuilder(
      animation: Listenable.merge([
        widget.controller,
        widget.collection,
        widget.decorations,
      ]),
      builder: (context, _) {
        final sortedAchievements = _sortedAchievements();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  key: const ValueKey('achievement-sort-button'),
                  onPressed: _cycleSort,
                  icon: Icon(_sortIcon),
                  label: Text(_sortLabel),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                itemCount: sortedAchievements.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = sortedAchievements[index];
                  final progress = widget.controller
                      .progressFor(item, widget.collection, widget.decorations)
                      .clamp(0, item.target);
                  final unlocked = widget.controller.isUnlocked(item);
                  return Card(
                    key: ValueKey('achievement-${item.type.name}'),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: unlocked
                            ? const Color(0xFFFFE5A3)
                            : const Color(0xFFE5DCC8),
                        child: Icon(
                          unlocked
                              ? _unlockedIcon(item.type)
                              : Icons.lock_outline,
                          color: AppColors.selected,
                        ),
                      ),
                      title: Text(
                        widget.title(item.type),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.description(item.type)),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: progress / item.target,
                          ),
                          Text(
                            '$progress / ${item.target} · ${item.feathers} ✨',
                          ),
                        ],
                      ),
                      trailing: unlocked
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFF5E9F59),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
  );

  List<Achievement> _sortedAchievements() {
    final result = List<Achievement>.of(achievements);
    if (_sort == _AchievementSort.normal) return result;
    result.sort((a, b) {
      final aUnlocked = widget.controller.isUnlocked(a);
      final bUnlocked = widget.controller.isUnlocked(b);
      if (aUnlocked == bUnlocked) {
        if (!aUnlocked) {
          final aRatio =
              widget.controller.progressFor(
                a,
                widget.collection,
                widget.decorations,
              ) /
              a.target;
          final bRatio =
              widget.controller.progressFor(
                b,
                widget.collection,
                widget.decorations,
              ) /
              b.target;
          final progressOrder = bRatio.compareTo(aRatio);
          if (progressOrder != 0) return progressOrder;
        }
        return achievements.indexOf(a).compareTo(achievements.indexOf(b));
      }
      final unlockedFirst = _sort == _AchievementSort.unlockedFirst;
      return aUnlocked == unlockedFirst ? -1 : 1;
    });
    return result;
  }

  void _cycleSort() {
    setState(() {
      _sort = switch (_sort) {
        _AchievementSort.normal => _AchievementSort.unlockedFirst,
        _AchievementSort.unlockedFirst => _AchievementSort.lockedFirst,
        _AchievementSort.lockedFirst => _AchievementSort.normal,
      };
    });
  }

  String get _sortLabel => switch (_sort) {
    _AchievementSort.normal =>
      widget.isFrench ? 'Tous les succès' : 'All achievements',
    _AchievementSort.unlockedFirst =>
      widget.isFrench ? 'Terminés d’abord' : 'Completed first',
    _AchievementSort.lockedFirst =>
      widget.isFrench ? 'À terminer d’abord' : 'In progress first',
  };

  IconData get _sortIcon => switch (_sort) {
    _AchievementSort.normal => Icons.sort,
    _AchievementSort.unlockedFirst => Icons.emoji_events_outlined,
    _AchievementSort.lockedFirst => Icons.lock_outline,
  };

  IconData _unlockedIcon(AchievementType type) => switch (type) {
    AchievementType.firstFlock => Icons.flutter_dash,
    AchievementType.discoverFive => Icons.groups_2_outlined,
    AchievementType.discoverFifteen => Icons.menu_book_outlined,
    AchievementType.bestFriend => Icons.favorite,
    AchievementType.decorator => Icons.chair_alt_outlined,
    AchievementType.foodExplorer => Icons.restaurant_menu,
    AchievementType.parkRegular => Icons.calendar_month_outlined,
    AchievementType.treasureHunter => Icons.diamond_outlined,
  };
}
