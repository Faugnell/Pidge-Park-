import 'package:flutter/material.dart';

import '../collection/pigeon_collection_controller.dart';
import '../models/pigeon.dart';
import '../theme/app_theme.dart';
import '../widgets/pigeon_avatar.dart';

class PigeondexScreen extends StatefulWidget {
  const PigeondexScreen({
    required this.controller,
    required this.isFrench,
    super.key,
  });

  final PigeonCollectionController controller;
  final bool isFrench;

  @override
  State<PigeondexScreen> createState() => _PigeondexScreenState();
}

class _PigeondexScreenState extends State<PigeondexScreen> {
  PigeonRarity? _selectedRarity;

  @override
  Widget build(BuildContext context) {
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
                    onTap: () {
                      if (!progress.discovered) {
                        _showHint(context, pigeon);
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PigeonDetailScreen(
                            pigeon: pigeon,
                            controller: widget.controller,
                            isFrench: widget.isFrench,
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
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.splashBackground,
        icon: const Icon(Icons.help_outline, size: 38),
        title: Text('#${pigeon.number.toString().padLeft(3, '0')} — ???'),
        content: Text(
          '« ${pigeon.hint(widget.isFrench)} »',
          textAlign: TextAlign.center,
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
  });

  final Pigeon pigeon;
  final PigeonProgress progress;
  final bool isFrench;
  final VoidCallback? onTap;

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
              Text(
                pigeon.number.toString().padLeft(3, '0'),
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: const Color(0xFF958A76)),
              ),
              const Spacer(),
              PigeonAvatar(
                pigeon: pigeon,
                locked: !progress.discovered,
                size: 64,
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
    required this.isFrench,
    super.key,
  });

  final Pigeon pigeon;
  final PigeonCollectionController controller;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final progress = controller.progressFor(pigeon.id);
        return Scaffold(
          backgroundColor: AppColors.splashBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(pigeon.name),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              children: [
                const SizedBox(height: 12),
                Center(child: PigeonAvatar(pigeon: pigeon, size: 190)),
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
                        onPressed: progress.affection >= 10
                            ? null
                            : () => controller.giveGift(pigeon.id),
                        icon: const Icon(Icons.card_giftcard, size: 19),
                        label: Text(isFrench ? 'Cadeau' : 'Gift'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _DetailCard(
                  child: Text(
                    pigeon.description(isFrench),
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
              ],
            ),
          ),
        );
      },
    );
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
