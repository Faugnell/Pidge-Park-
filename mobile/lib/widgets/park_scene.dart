import 'package:flutter/material.dart';

import '../game/decoration_controller.dart';
import '../game/game_controller.dart';
import '../models/decoration.dart';
import '../theme/app_theme.dart';

enum ParkVisualLayer { background, middle, foreground }

typedef _ParkSlot = ({Alignment alignment, double size, ParkVisualLayer layer});

const _slots = <String, _ParkSlot>{
  // Grands éléments, derrière le mobilier et les pigeons.
  'lamp': (
    alignment: Alignment(-0.83, -0.58),
    size: 66,
    layer: ParkVisualLayer.background,
  ),
  'statue': (
    alignment: Alignment(0.55, -0.48),
    size: 72,
    layer: ParkVisualLayer.background,
  ),
  // Mobilier situé sur le côté gauche et au milieu du parc.
  'bench': (
    alignment: Alignment(-0.48, 0.02),
    size: 72,
    layer: ParkVisualLayer.middle,
  ),
  'fountain': (
    alignment: Alignment(-0.75, -0.05),
    size: 62,
    layer: ParkVisualLayer.middle,
  ),
  'trash': (
    alignment: Alignment(-0.12, 0.12),
    size: 55,
    layer: ParkVisualLayer.middle,
  ),
  'easel': (
    alignment: Alignment(0.34, 0.04),
    size: 57,
    layer: ParkVisualLayer.middle,
  ),
  'baguette_stand': (
    alignment: Alignment(-0.68, 0.22),
    size: 72,
    layer: ParkVisualLayer.middle,
  ),
  // Petits accessoires au premier plan.
  'radio': (
    alignment: Alignment(0.68, 0.73),
    size: 42,
    layer: ParkVisualLayer.foreground,
  ),
  'books': (
    alignment: Alignment(0.68, 0.73),
    size: 42,
    layer: ParkVisualLayer.foreground,
  ),
  'flowers': (
    alignment: Alignment(0.68, 0.70),
    size: 48,
    layer: ParkVisualLayer.foreground,
  ),
};

class ParkScene extends StatelessWidget {
  const ParkScene({
    required this.gameController,
    required this.decorationController,
    super.key,
  });

  final GameController gameController;
  final DecorationController decorationController;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _ParkGround(),
          _DecorationLayer(
            layer: ParkVisualLayer.background,
            equippedIds: decorationController.equippedIds,
          ),
          // Cet arbre fait partie du décor de base. Il sera remplacé par
          // l'illustration d'arrière-plan produite par l'artiste.
          const Align(
            alignment: Alignment(0.82, -0.72),
            child: Icon(Icons.park, size: 92, color: Color(0xFF547B49)),
          ),
          _DecorationLayer(
            layer: ParkVisualLayer.middle,
            equippedIds: decorationController.equippedIds,
          ),
          _DecorationLayer(
            layer: ParkVisualLayer.foreground,
            equippedIds: decorationController.equippedIds,
          ),
          if (gameController.hasActiveFood)
            Align(
              alignment: const Alignment(0.12, 0.43),
              child: Icon(
                gameController.activeFood!.icon,
                key: const ValueKey('park-food'),
                size: 38,
                color: const Color(0xFF8B6729),
              ),
            ),
          // La couche pigeons reste toujours la dernière afin qu'ils passent
          // devant tous les éléments du décor.
          if (gameController.visitorReady)
            const Align(
              alignment: Alignment(0.38, 0.63),
              child: _PigeonPlaceholder(),
            ),
        ],
      ),
    );
  }
}

class _ParkGround extends StatelessWidget {
  const _ParkGround();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFCFE0C6), Color(0xFFA9C99D)],
        ),
      ),
      child: CustomPaint(painter: _PathPainter()),
    );
  }
}

class _PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFD8C49C);
    final path = Path()
      ..moveTo(size.width * .38, size.height)
      ..quadraticBezierTo(
        size.width * .32,
        size.height * .55,
        size.width * .53,
        0,
      )
      ..lineTo(size.width * .72, 0)
      ..quadraticBezierTo(
        size.width * .56,
        size.height * .56,
        size.width * .78,
        size.height,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DecorationLayer extends StatelessWidget {
  const _DecorationLayer({required this.layer, required this.equippedIds});

  final ParkVisualLayer layer;
  final List<String> equippedIds;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final id in equippedIds)
          if (_slots[id]?.layer == layer)
            Align(
              alignment: _slots[id]!.alignment,
              child: _DecorationPlaceholder(
                decoration: decorations.firstWhere((item) => item.id == id),
                size: _slots[id]!.size,
              ),
            ),
      ],
    );
  }
}

class _DecorationPlaceholder extends StatelessWidget {
  const _DecorationPlaceholder({required this.decoration, required this.size});

  final ParkDecoration decoration;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('park-decoration-${decoration.id}'),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.navigationBackground.withValues(alpha: 0.82),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF6F805F)),
      ),
      child: Icon(decoration.icon, size: size * .58, color: AppColors.selected),
    );
  }
}

class _PigeonPlaceholder extends StatelessWidget {
  const _PigeonPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('park-pigeon-placeholder'),
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E4DA),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF555B57), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(Icons.flutter_dash, size: 52, color: Color(0xFF59635F)),
    );
  }
}
