import 'package:flutter/material.dart';

import '../models/pigeon.dart';

class PigeonAvatar extends StatelessWidget {
  const PigeonAvatar({
    required this.pigeon,
    this.locked = false,
    this.size = 80,
    super.key,
  });

  final Pigeon pigeon;
  final bool locked;
  final double size;

  @override
  Widget build(BuildContext context) {
    final birdColor = locked ? const Color(0xFF817B6E) : pigeon.color;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: locked
                  ? const Color(0xFFE1DAC9)
                  : pigeon.color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
          ),
          Icon(
            Icons.flutter_dash,
            size: size * 0.72,
            color: birdColor,
            shadows: const [Shadow(color: Color(0x55000000), blurRadius: 1)],
          ),
          if (!locked && pigeon.accessory != null)
            Positioned(
              top: 1,
              right: 1,
              child: Container(
                padding: EdgeInsets.all(size * 0.06),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE5A4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  pigeon.accessory,
                  size: size * 0.22,
                  color: const Color(0xFF6C5132),
                ),
              ),
            ),
          if (locked)
            Positioned(
              right: 2,
              bottom: 2,
              child: Icon(
                Icons.lock,
                size: size * 0.25,
                color: const Color(0xFF665F52),
              ),
            ),
        ],
      ),
    );
  }
}
