import 'package:flutter/material.dart';

import '../game/decoration_controller.dart';
import '../game/game_controller.dart';
import '../models/decoration.dart';
import '../theme/app_theme.dart';

class DecorationsScreen extends StatelessWidget {
  const DecorationsScreen({
    required this.controller,
    required this.gameController,
    required this.isFrench,
    super.key,
  });

  final DecorationController controller;
  final GameController gameController;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, gameController]),
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.placeholderBackground,
        appBar: AppBar(
          backgroundColor: AppColors.placeholderBackground,
          title: Text(isFrench ? 'Décorations' : 'Decorations'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '🪙 ${gameController.crumbs}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                child: Row(
                  children: List.generate(3, (index) {
                    final id = index < controller.equippedIds.length
                        ? controller.equippedIds[index]
                        : null;
                    final decoration = id == null
                        ? null
                        : decorations.firstWhere((item) => item.id == id);
                    return Expanded(
                      child: Container(
                        height: 86,
                        margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                        decoration: BoxDecoration(
                          color: AppColors.navigationBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFD8C9AA)),
                        ),
                        child: decoration == null
                            ? const Icon(Icons.add, color: Color(0xFF9B927F))
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    decoration.icon,
                                    color: AppColors.selected,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    decoration.name(isFrench),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                      ),
                    );
                  }),
                ),
              ),
              Text(
                '${controller.equippedIds.length}/3 ${isFrench ? 'équipées' : 'equipped'}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: decorations.length,
                  itemBuilder: (context, index) {
                    final decoration = decorations[index];
                    final owned = controller.isOwned(decoration);
                    final equipped = controller.isEquipped(decoration);
                    return Material(
                      color: equipped
                          ? const Color(0xFFDDE9D6)
                          : AppColors.navigationBackground,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: equipped
                              ? AppColors.selected
                              : const Color(0xFFD8C9AA),
                        ),
                      ),
                      child: InkWell(
                        key: ValueKey('decoration-${decoration.id}'),
                        onTap: () => _select(context, decoration),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                decoration.icon,
                                size: 42,
                                color: AppColors.selected,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                decoration.name(isFrench),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                equipped
                                    ? (isFrench ? 'ÉQUIPÉ' : 'EQUIPPED')
                                    : owned
                                    ? (isFrench ? 'Possédé' : 'Owned')
                                    : '🪙 ${decoration.price}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Future<void> _select(BuildContext context, ParkDecoration decoration) async {
    if (!controller.isOwned(decoration)) {
      final bought = await controller.buy(decoration, gameController);
      if (!bought && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFrench ? 'Pas assez de miettes.' : 'Not enough crumbs.',
            ),
          ),
        );
      }
      return;
    }
    if (!controller.isEquipped(decoration) &&
        controller.equippedIds.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFrench
                ? 'Retire d’abord une décoration.'
                : 'Remove a decoration first.',
          ),
        ),
      );
      return;
    }
    await controller.toggleEquipped(decoration);
  }
}
