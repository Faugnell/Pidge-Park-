import 'package:flutter/material.dart';

class ArtworkImage extends StatelessWidget {
  const ArtworkImage({
    required this.assetPath,
    required this.fallback,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    super.key,
  });

  final String assetPath;
  final Widget fallback;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: fit,
      alignment: alignment,
      gaplessPlayback: true,
      excludeFromSemantics: true,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
