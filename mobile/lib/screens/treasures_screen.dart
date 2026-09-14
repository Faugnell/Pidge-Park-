import 'package:flutter/material.dart';

import '../collection/pigeon_collection_controller.dart';
import '../models/pigeon.dart';
import '../models/pigeon_keepsake.dart';
import '../models/treasure.dart';
import '../theme/app_theme.dart';
import '../widgets/pigeon_avatar.dart';

class TreasuresScreen extends StatefulWidget {
  const TreasuresScreen({
    required this.collectionController,
    required this.isFrench,
    required this.onOpenPigeon,
    super.key,
  });

  final PigeonCollectionController collectionController;
  final bool isFrench;
  final ValueChanged<Pigeon> onOpenPigeon;

  @override
  State<TreasuresScreen> createState() => _TreasuresScreenState();
}

class _TreasuresScreenState extends State<TreasuresScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  KeepsakeKind _equipmentKind = KeepsakeKind.accessory;
  bool _tipScheduled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scheduleContextualTip();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleContextualTip();
    return AnimatedBuilder(
      animation: widget.collectionController,
      builder: (context, _) => ColoredBox(
        color: AppColors.placeholderBackground,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 18),
              Text(
                widget.isFrench ? 'TRÉSORS & OBJETS' : 'TREASURES & ITEMS',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.inventory_2_outlined),
                      text: widget.isFrench ? 'Souvenirs' : 'Keepsakes',
                    ),
                    Tab(
                      icon: const Icon(Icons.checkroom),
                      text: widget.isFrench ? 'Équipements' : 'Equipment',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildSouvenirs(), _buildEquipment()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) _scheduleContextualTip();
  }

  void _scheduleContextualTip() {
    if (_tipScheduled) return;
    _tipScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _tipScheduled = false;
      if (!mounted) return;
      if (_tabController.index == 0) {
        await _showSouvenirTipIfNeeded();
      } else {
        await _showEquipmentTipIfNeeded();
      }
    });
  }

  Future<void> _showSouvenirTipIfNeeded() async {
    final controller = widget.collectionController;
    final hasSouvenir =
        treasures.any(_isTreasureUnlocked) ||
        pigeonKeepsakes.any(
          (item) =>
              item.kind == KeepsakeKind.souvenir &&
              controller.ownsKeepsake(item.id),
        );
    if (!hasSouvenir || controller.souvenirTutorialSeen) return;
    await controller.markSouvenirTutorialSeen();
    if (!mounted) return;
    await _showTutorialDialog(
      key: 'souvenir-tutorial',
      icon: Icons.inventory_2_outlined,
      title: widget.isFrench ? 'Un petit souvenir !' : 'A little keepsake!',
      message: widget.isFrench
          ? 'Chaque objet raconte un bout de l’histoire d’un pigeon. Complète la collection pour découvrir tous leurs petits secrets.'
          : 'Every item tells part of a pigeon’s story. Complete the collection to uncover all their little secrets.',
    );
  }

  Future<void> _showEquipmentTipIfNeeded() async {
    final controller = widget.collectionController;
    final hasEquipment = pigeonKeepsakes.any(
      (item) =>
          item.kind != KeepsakeKind.souvenir &&
          controller.ownsKeepsake(item.id),
    );
    if (!hasEquipment || controller.equipmentTutorialSeen) return;
    await controller.markEquipmentTutorialSeen();
    if (!mounted) return;
    await _showTutorialDialog(
      key: 'equipment-tutorial',
      icon: Icons.checkroom,
      title: widget.isFrench
          ? 'À toi de les habiller !'
          : 'Time to dress them up!',
      message: widget.isFrench
          ? 'Les accessoires et les familiers permettent de personnaliser tous tes pigeons. Mélange les styles, équipe tes préférés… et essaie de tout débloquer !'
          : 'Accessories and companions let you personalize every pigeon. Mix styles, dress your favourites… and try to unlock them all!',
    );
  }

  Future<void> _showTutorialDialog({
    required String key,
    required IconData icon,
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        key: ValueKey(key),
        backgroundColor: AppColors.splashBackground,
        icon: Icon(icon, size: 52, color: AppColors.selected),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.isFrench ? 'J’ai compris !' : 'Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildSouvenirs() {
    final personalSouvenirs = pigeonKeepsakes
        .where((item) => item.kind == KeepsakeKind.souvenir)
        .toList();
    final friendshipUnlocked = treasures.where(_isTreasureUnlocked).length;
    final personalUnlocked = personalSouvenirs
        .where((item) => widget.collectionController.ownsKeepsake(item.id))
        .length;
    final total = treasures.length + personalSouvenirs.length;
    return Column(
      children: [
        Text(
          '${friendshipUnlocked + personalUnlocked} / $total',
          key: const ValueKey('souvenir-count'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView(
            key: const ValueKey('souvenir-grid'),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.78,
            ),
            children: [
              for (final treasure in treasures)
                _InventoryCard(
                  id: treasure.id,
                  icon: treasure.icon,
                  name: treasure.name(widget.isFrench),
                  pigeon: _pigeonFor(treasure.pigeonId),
                  unlocked: _isTreasureUnlocked(treasure),
                  isFrench: widget.isFrench,
                  onTap: () => _showTreasure(treasure),
                ),
              for (final keepsake in personalSouvenirs)
                _InventoryCard(
                  id: keepsake.id,
                  icon: keepsake.icon,
                  name: keepsake.name(widget.isFrench),
                  pigeon: _pigeonFor(keepsake.pigeonId),
                  unlocked: widget.collectionController.ownsKeepsake(
                    keepsake.id,
                  ),
                  isFrench: widget.isFrench,
                  onTap: () => _showPersonalSouvenir(keepsake),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEquipment() {
    final items = pigeonKeepsakes
        .where((item) => item.kind == _equipmentKind)
        .toList();
    final unlocked = items
        .where((item) => widget.collectionController.ownsKeepsake(item.id))
        .length;
    return Column(
      children: [
        SegmentedButton<KeepsakeKind>(
          segments: [
            ButtonSegment(
              value: KeepsakeKind.accessory,
              icon: const Icon(Icons.checkroom),
              label: Text(widget.isFrench ? 'Accessoires' : 'Accessories'),
            ),
            ButtonSegment(
              value: KeepsakeKind.companion,
              icon: const Icon(Icons.pets_outlined),
              label: Text(widget.isFrench ? 'Familiers' : 'Companions'),
            ),
          ],
          selected: {_equipmentKind},
          onSelectionChanged: (selection) {
            setState(() => _equipmentKind = selection.first);
          },
        ),
        const SizedBox(height: 8),
        Text(
          '$unlocked / ${items.length}',
          key: const ValueKey('equipment-count'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            key: const ValueKey('equipment-grid'),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => _EquipmentCard(
              keepsake: items[index],
              pigeon: _pigeonFor(items[index].pigeonId),
              controller: widget.collectionController,
              isFrench: widget.isFrench,
              onCustomize: () => _showEquipmentPicker(items[index]),
            ),
          ),
        ),
      ],
    );
  }

  void _showEquipmentPicker(PigeonKeepsake keepsake) {
    if (!widget.collectionController.ownsKeepsake(keepsake.id)) return;
    final discoveredPigeons = pigeons
        .where(
          (pigeon) =>
              widget.collectionController.progressFor(pigeon.id).discovered,
        )
        .toList();
    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          key: ValueKey('universal-equipment-${keepsake.id}'),
          backgroundColor: AppColors.splashBackground,
          title: Text(keepsake.name(widget.isFrench)),
          content: SizedBox(
            width: 390,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isFrench
                      ? 'Rapporté par ${_pigeonFor(keepsake.pigeonId).name} · utilisable sur tous les pigeons'
                      : 'Found by ${_pigeonFor(keepsake.pigeonId).name} · usable by every pigeon',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: discoveredPigeons.length,
                    itemBuilder: (context, index) {
                      final pigeon = discoveredPigeons[index];
                      final equippedId = keepsake.kind == KeepsakeKind.accessory
                          ? widget.collectionController.equippedAccessoryId(
                              pigeon.id,
                            )
                          : widget.collectionController.equippedCompanionId(
                              pigeon.id,
                            );
                      final equipped = equippedId == keepsake.id;
                      return ListTile(
                        key: ValueKey('equip-${keepsake.id}-on-${pigeon.id}'),
                        leading: PigeonAvatar(
                          pigeon: pigeon,
                          size: 48,
                          accessoryIcon: keepsake.kind == KeepsakeKind.accessory
                              ? keepsake.icon
                              : keepsakeById(
                                  widget.collectionController
                                      .equippedAccessoryId(pigeon.id),
                                )?.icon,
                          companionIcon: keepsake.kind == KeepsakeKind.companion
                              ? keepsake.icon
                              : keepsakeById(
                                  widget.collectionController
                                      .equippedCompanionId(pigeon.id),
                                )?.icon,
                          accessoryId: keepsake.kind == KeepsakeKind.accessory
                              ? keepsake.id
                              : widget.collectionController.equippedAccessoryId(
                                  pigeon.id,
                                ),
                          companionId: keepsake.kind == KeepsakeKind.companion
                              ? keepsake.id
                              : widget.collectionController.equippedCompanionId(
                                  pigeon.id,
                                ),
                        ),
                        title: Text(pigeon.name),
                        subtitle: Text(
                          equippedId == null
                              ? (widget.isFrench
                                    ? 'Emplacement libre'
                                    : 'Empty slot')
                              : equipped
                              ? (widget.isFrench
                                    ? 'Actuellement équipé'
                                    : 'Currently equipped')
                              : (widget.isFrench
                                    ? 'Remplacera ${keepsakeById(equippedId)?.name(true) ?? 'l’objet actuel'}'
                                    : 'Replaces ${keepsakeById(equippedId)?.name(false) ?? 'current item'}'),
                        ),
                        trailing: FilledButton(
                          onPressed: () async {
                            await widget.collectionController.toggleKeepsake(
                              keepsake,
                              forPigeonId: pigeon.id,
                            );
                            setDialogState(() {});
                          },
                          child: Text(
                            equipped
                                ? (widget.isFrench ? 'Retirer' : 'Remove')
                                : (widget.isFrench ? 'Équiper' : 'Equip'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(widget.isFrench ? 'Terminer' : 'Done'),
            ),
          ],
        ),
      ),
    );
  }

  Pigeon _pigeonFor(String id) => pigeons.firstWhere((item) => item.id == id);

  bool _isTreasureUnlocked(PigeonTreasure treasure) =>
      widget.collectionController.hasClaimedFriendshipMilestone(
        treasure.pigeonId,
        treasure.requiredAffection,
      );

  void _showTreasure(PigeonTreasure treasure) {
    final unlocked = _isTreasureUnlocked(treasure);
    final pigeon = _pigeonFor(treasure.pigeonId);
    _showItemDialog(
      icon: treasure.icon,
      name: treasure.name(widget.isFrench),
      description: treasure.description(widget.isFrench),
      pigeon: pigeon,
      unlocked: unlocked,
      lockedHint: widget.isFrench
          ? 'Atteins le niveau ${treasure.requiredAffection} avec ${pigeon.name}.'
          : 'Reach level ${treasure.requiredAffection} with ${pigeon.name}.',
    );
  }

  void _showPersonalSouvenir(PigeonKeepsake keepsake) {
    final pigeon = _pigeonFor(keepsake.pigeonId);
    final unlocked = widget.collectionController.ownsKeepsake(keepsake.id);
    _showItemDialog(
      icon: keepsake.icon,
      name: keepsake.name(widget.isFrench),
      description: widget.isFrench
          ? '${pigeon.name} a rapporté ce petit morceau de son histoire.'
          : '${pigeon.name} brought back this little piece of their story.',
      pigeon: pigeon,
      unlocked: unlocked,
      lockedHint: widget.isFrench
          ? 'Deviens le meilleur ami de ${pigeon.name}, puis attends une trouvaille.'
          : 'Become ${pigeon.name}’s best friend, then wait for a lucky find.',
    );
  }

  void _showItemDialog({
    required IconData icon,
    required String name,
    required String description,
    required Pigeon pigeon,
    required bool unlocked,
    required String lockedHint,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.splashBackground,
        icon: Icon(unlocked ? icon : Icons.lock_outline, size: 54),
        title: Text(unlocked ? name : '???'),
        content: Text(
          unlocked ? description : lockedHint,
          textAlign: TextAlign.center,
        ),
        actions: [
          if (unlocked)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onOpenPigeon(pigeon);
              },
              child: Text(widget.isFrench ? 'Voir le pigeon' : 'View pigeon'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.isFrench ? 'Fermer' : 'Close'),
          ),
        ],
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({
    required this.id,
    required this.icon,
    required this.name,
    required this.pigeon,
    required this.unlocked,
    required this.isFrench,
    required this.onTap,
  });

  final String id;
  final IconData icon;
  final String name;
  final Pigeon pigeon;
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
        key: ValueKey('inventory-item-$id'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Icon(
                  unlocked ? icon : Icons.question_mark,
                  size: 45,
                  color: unlocked
                      ? AppColors.selected
                      : const Color(0xFF948C7C),
                ),
              ),
              Text(
                unlocked ? name : '???',
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                unlocked
                    ? pigeon.name
                    : (isFrench ? 'Pigeon inconnu' : 'Unknown pigeon'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  const _EquipmentCard({
    required this.keepsake,
    required this.pigeon,
    required this.controller,
    required this.isFrench,
    required this.onCustomize,
  });

  final PigeonKeepsake keepsake;
  final Pigeon pigeon;
  final PigeonCollectionController controller;
  final bool isFrench;
  final VoidCallback onCustomize;

  @override
  Widget build(BuildContext context) {
    final owned = controller.ownsKeepsake(keepsake.id);
    final equippedCount = controller.pigeonsUsingKeepsake(keepsake.id).length;
    return Material(
      color: AppColors.navigationBackground,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: equippedCount > 0
              ? AppColors.selected
              : const Color(0xFFD8C9AA),
          width: equippedCount > 0 ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PigeonAvatar(
                    pigeon: pigeon,
                    locked: !owned,
                    size: 58,
                    accessoryIcon:
                        owned && keepsake.kind == KeepsakeKind.accessory
                        ? keepsake.icon
                        : null,
                    companionIcon:
                        owned && keepsake.kind == KeepsakeKind.companion
                        ? keepsake.icon
                        : null,
                    accessoryId:
                        owned && keepsake.kind == KeepsakeKind.accessory
                        ? keepsake.id
                        : null,
                    companionId:
                        owned && keepsake.kind == KeepsakeKind.companion
                        ? keepsake.id
                        : null,
                  ),
                  const SizedBox(width: 5),
                  Icon(owned ? keepsake.icon : Icons.question_mark, size: 29),
                ],
              ),
            ),
            Text(
              owned ? keepsake.name(isFrench) : '???',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              owned
                  ? (isFrench
                        ? 'Rapporté par ${pigeon.name}'
                        : 'Found by ${pigeon.name}')
                  : pigeon.name,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 5),
            FilledButton(
              key: ValueKey('equip-from-inventory-${keepsake.id}'),
              onPressed: owned ? onCustomize : null,
              child: Text(
                equippedCount == 0
                    ? (isFrench ? 'Choisir un pigeon' : 'Choose a pigeon')
                    : (isFrench
                          ? 'Équipé sur $equippedCount'
                          : 'Equipped on $equippedCount'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
