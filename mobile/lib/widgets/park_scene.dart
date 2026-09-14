import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../art/art_asset_paths.dart';
import '../game/decoration_controller.dart';
import '../game/game_controller.dart';
import '../game/park_ambience.dart';
import '../models/decoration.dart';
import '../models/pigeon.dart';
import '../theme/app_theme.dart';
import 'pigeon_avatar.dart';
import 'artwork_image.dart';

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
  'pigeondex_banner': (
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
    alignment: Alignment(0.70, 0.12),
    size: 42,
    layer: ParkVisualLayer.foreground,
  ),
  'books': (
    alignment: Alignment(0.70, 0.12),
    size: 42,
    layer: ParkVisualLayer.foreground,
  ),
  'flowers': (
    alignment: Alignment(0.70, 0.12),
    size: 48,
    layer: ParkVisualLayer.foreground,
  ),
};

class ParkScene extends StatelessWidget {
  const ParkScene({
    required this.gameController,
    required this.decorationController,
    required this.pigeons,
    required this.knownPigeonIds,
    this.conditionMatchPigeonIds = const {},
    required this.onPigeonTap,
    required this.ambience,
    this.accessoryIcons = const {},
    this.companionIcons = const {},
    this.accessoryIds = const {},
    this.companionIds = const {},
    super.key,
  });

  final GameController gameController;
  final DecorationController decorationController;
  final List<Pigeon> pigeons;
  final Set<String> knownPigeonIds;
  final Set<String> conditionMatchPigeonIds;
  final ValueChanged<Pigeon> onPigeonTap;
  final ParkAmbience ambience;
  final Map<String, IconData> accessoryIcons;
  final Map<String, IconData> companionIcons;
  final Map<String, String> accessoryIds;
  final Map<String, String> companionIds;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _ParkGround(ambience: ambience),
          _WeatherLayer(ambience: ambience),
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
          for (var index = 0; index < pigeons.length; index++)
            Align(
              alignment: _pigeonPositions[index % _pigeonPositions.length],
              child: _DriftingPigeon(
                key: ValueKey('park-pigeon-${pigeons[index].id}-$index'),
                pigeon: pigeons[index],
                size: index.isEven ? 68 : 61,
                index: index,
                isKnown: knownPigeonIds.contains(pigeons[index].id),
                matchesClue: conditionMatchPigeonIds.contains(
                  pigeons[index].id,
                ),
                accessoryIcon: accessoryIcons[pigeons[index].id],
                companionIcon: companionIcons[pigeons[index].id],
                accessoryId: accessoryIds[pigeons[index].id],
                companionId: companionIds[pigeons[index].id],
                onTap: () => onPigeonTap(pigeons[index]),
              ),
            ),
          IgnorePointer(child: ColoredBox(color: ambience.overlay)),
        ],
      ),
    );
  }
}

const _pigeonPositions = <Alignment>[
  Alignment(-0.58, 0.55),
  Alignment(-0.08, 0.72),
  Alignment(0.38, 0.48),
  Alignment(0.72, 0.78),
];

class _DriftingPigeon extends StatefulWidget {
  const _DriftingPigeon({
    required this.pigeon,
    required this.size,
    required this.index,
    required this.isKnown,
    required this.matchesClue,
    required this.accessoryIcon,
    required this.companionIcon,
    required this.accessoryId,
    required this.companionId,
    required this.onTap,
    super.key,
  });

  final Pigeon pigeon;
  final double size;
  final int index;
  final bool isKnown;
  final bool matchesClue;
  final IconData? accessoryIcon;
  final IconData? companionIcon;
  final String? accessoryId;
  final String? companionId;
  final VoidCallback onTap;

  @override
  State<_DriftingPigeon> createState() => _DriftingPigeonState();
}

class _DriftingPigeonState extends State<_DriftingPigeon> {
  final Random _random = Random();
  Timer? _entryTimer;
  Timer? _movementTimer;
  bool? _animationsDisabled;
  bool _entered = false;
  Offset _targetOffset = Offset.zero;
  double _targetTilt = 0;
  Duration _movementDuration = const Duration(milliseconds: 1600);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animationsDisabled = MediaQuery.disableAnimationsOf(context);
    if (_animationsDisabled == animationsDisabled) return;
    _animationsDisabled = animationsDisabled;
    _entryTimer?.cancel();
    _movementTimer?.cancel();
    _entryTimer = null;
    _movementTimer = null;
    if (animationsDisabled) {
      _entered = true;
      _targetOffset = Offset.zero;
      _targetTilt = 0;
    } else {
      _entered = false;
      _entryTimer = Timer(Duration(milliseconds: 180 * widget.index), () {
        if (!mounted || _animationsDisabled == true) return;
        setState(() {
          _entered = true;
          _movementDuration = const Duration(milliseconds: 700);
        });
        _scheduleNextMovement(
          delay: Duration(milliseconds: 900 + _random.nextInt(900)),
        );
      });
    }
  }

  void _scheduleNextMovement({Duration? delay}) {
    final pause = delay ?? Duration(milliseconds: 700 + _random.nextInt(2100));
    _movementTimer = Timer(pause, () {
      if (!mounted || _animationsDisabled == true) return;
      final duration = Duration(milliseconds: 1100 + _random.nextInt(1500));
      setState(() {
        _movementDuration = duration;
        _targetOffset = Offset(
          -0.14 + _random.nextDouble() * 0.28,
          -0.025 + _random.nextDouble() * 0.05,
        );
        _targetTilt = -0.008 + _random.nextDouble() * 0.016;
      });
      _scheduleNextMovement(
        delay: duration + Duration(milliseconds: 700 + _random.nextInt(2100)),
      );
    });
  }

  @override
  void dispose() {
    _entryTimer?.cancel();
    _movementTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entranceOffset = Offset(widget.index.isEven ? -2.2 : 2.2, 0.08);
    return Semantics(
      button: true,
      label: widget.pigeon.name,
      child: GestureDetector(
        onTap: _entered ? widget.onTap : null,
        child: AnimatedOpacity(
          opacity: _entered ? 1 : 0,
          duration: const Duration(milliseconds: 500),
          child: AnimatedSlide(
            offset: _animationsDisabled == true
                ? Offset.zero
                : (_entered ? _targetOffset : entranceOffset),
            duration: _movementDuration,
            curve: Curves.easeOutCubic,
            child: AnimatedRotation(
              turns: _animationsDisabled == true ? 0 : _targetTilt,
              duration: _movementDuration,
              curve: Curves.easeInOut,
              child: _PigeonSceneAvatar(
                pigeon: widget.pigeon,
                size: widget.size,
                isKnown: widget.isKnown,
                matchesClue: widget.matchesClue,
                accessoryIcon: widget.accessoryIcon,
                companionIcon: widget.companionIcon,
                accessoryId: widget.accessoryId,
                companionId: widget.companionId,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PigeonSceneAvatar extends StatelessWidget {
  const _PigeonSceneAvatar({
    required this.pigeon,
    required this.size,
    required this.isKnown,
    required this.matchesClue,
    required this.accessoryIcon,
    required this.companionIcon,
    required this.accessoryId,
    required this.companionId,
  });

  final Pigeon pigeon;
  final double size;
  final bool isKnown;
  final bool matchesClue;
  final IconData? accessoryIcon;
  final IconData? companionIcon;
  final String? accessoryId;
  final String? companionId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          PigeonAvatar(
            pigeon: pigeon,
            size: size,
            accessoryIcon: accessoryIcon,
            companionIcon: companionIcon,
            accessoryId: accessoryId,
            companionId: companionId,
          ),
          if (!isKnown)
            Positioned(
              top: -12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCC5C),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF8B6729)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 10),
                    const SizedBox(width: 2),
                    Text(
                      matchesClue
                          ? (Localizations.localeOf(context).languageCode ==
                                    'fr'
                                ? 'Indice trouvé !'
                                : 'Clue found!')
                          : (Localizations.localeOf(context).languageCode ==
                                    'fr'
                                ? 'Nouveau !'
                                : 'New!'),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ParkGround extends StatelessWidget {
  const _ParkGround({required this.ambience});

  final ParkAmbience ambience;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ...ambience.skyColors,
            const Color(0xFFCFE0C6),
            const Color(0xFFA9C99D),
          ],
          stops: const [0, 0.32, 0.48, 1],
        ),
      ),
      child: CustomPaint(painter: _PathPainter()),
    );
  }
}

class _WeatherLayer extends StatelessWidget {
  const _WeatherLayer({required this.ambience});
  final ParkAmbience ambience;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          if (ambience.weather != ParkWeather.sunny)
            const Positioned(
              top: 24,
              left: 34,
              child: Icon(Icons.cloud, size: 54, color: Color(0xBDE9ECE8)),
            ),
          if (ambience.weather == ParkWeather.cloudy)
            const Positioned(
              top: 52,
              right: 46,
              child: Icon(Icons.cloud, size: 68, color: Color(0xA8DDE2DF)),
            ),
          if (ambience.weather == ParkWeather.sunny)
            const Positioned(
              top: 24,
              left: 34,
              child: Icon(Icons.wb_sunny, size: 48, color: Color(0xFFFFD166)),
            ),
          if (ambience.weather == ParkWeather.rainy)
            Positioned.fill(child: CustomPaint(painter: _RainPainter())),
          if (ambience.period == ParkDayPeriod.night) ...[
            const Positioned(
              top: 24,
              right: 42,
              child: Icon(
                Icons.nightlight_round,
                size: 42,
                color: Color(0xFFFFE7A6),
              ),
            ),
            const Positioned(
              top: 70,
              left: 105,
              child: Icon(Icons.star, size: 10, color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }
}

class _RainPainter extends CustomPainter {
  const _RainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x6680AFC8)
      ..strokeWidth = 1.4;
    for (var index = 0; index < 24; index++) {
      final x = ((index * 47) % 101) / 101 * size.width;
      final y = ((index * 83) % 97) / 97 * size.height;
      canvas.drawLine(Offset(x, y), Offset(x - 5, y + 15), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    return SizedBox(
      key: ValueKey('park-decoration-${decoration.id}'),
      width: size,
      height: size,
      child: ArtworkImage(
        assetPath: ArtAssetPaths.decoration(decoration.id),
        fallback: Container(
          decoration: BoxDecoration(
            color: AppColors.navigationBackground.withValues(alpha: 0.82),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF6F805F)),
          ),
          child: Icon(
            decoration.icon,
            size: size * .58,
            color: AppColors.selected,
          ),
        ),
      ),
    );
  }
}
