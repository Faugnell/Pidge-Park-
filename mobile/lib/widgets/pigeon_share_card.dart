import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../collection/pigeon_collection_controller.dart';
import '../models/pigeon.dart';
import '../theme/app_theme.dart';
import 'pigeon_avatar.dart';

Future<void> showPigeonShareCard(
  BuildContext context, {
  required Pigeon pigeon,
  required PigeonProgress progress,
  required bool isFrench,
  bool isNew = false,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _PigeonShareDialog(
      pigeon: pigeon,
      progress: progress,
      isFrench: isFrench,
      isNew: isNew,
    ),
  );
}

class _PigeonShareDialog extends StatefulWidget {
  const _PigeonShareDialog({
    required this.pigeon,
    required this.progress,
    required this.isFrench,
    required this.isNew,
  });

  final Pigeon pigeon;
  final PigeonProgress progress;
  final bool isFrench;
  final bool isNew;

  @override
  State<_PigeonShareDialog> createState() => _PigeonShareDialogState();
}

class _PigeonShareDialogState extends State<_PigeonShareDialog> {
  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: ValueKey('share-dialog-${widget.pigeon.id}'),
      backgroundColor: AppColors.splashBackground,
      contentPadding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      content: SingleChildScrollView(
        child: RepaintBoundary(
          key: _cardKey,
          child: _ShareCard(
            pigeon: widget.pigeon,
            progress: widget.progress,
            isFrench: widget.isFrench,
            isNew: widget.isNew,
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: _sharing ? null : () => Navigator.pop(context),
          child: Text(widget.isFrench ? 'Fermer' : 'Close'),
        ),
        Builder(
          builder: (buttonContext) => FilledButton.icon(
            key: ValueKey('share-pigeon-${widget.pigeon.id}'),
            onPressed: _sharing ? null : () => _share(buttonContext),
            icon: _sharing
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share),
            label: Text(widget.isFrench ? 'Partager' : 'Share'),
          ),
        ),
      ],
    );
  }

  Future<void> _share(BuildContext buttonContext) async {
    final box = buttonContext.findRenderObject() as RenderBox?;
    setState(() => _sharing = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _cardKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('Unable to render share card');
      await SharePlus.instance.share(
        ShareParams(
          title: 'Pidge Park! — ${widget.pigeon.name}',
          subject: widget.isFrench
              ? 'Mon pigeon dans Pidge Park!'
              : 'My pigeon in Pidge Park!',
          text: widget.isFrench
              ? 'J’ai rencontré ${widget.pigeon.name} dans Pidge Park! #PidgePark'
              : 'I met ${widget.pigeon.name} in Pidge Park! #PidgePark',
          files: [
            XFile.fromData(data.buffer.asUint8List(), mimeType: 'image/png'),
          ],
          fileNameOverrides: ['pidge-park-${widget.pigeon.id}.png'],
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isFrench
                  ? 'Impossible de préparer le partage.'
                  : 'Unable to prepare sharing.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({
    required this.pigeon,
    required this.progress,
    required this.isFrench,
    required this.isNew,
  });

  final Pigeon pigeon;
  final PigeonProgress progress;
  final bool isFrench;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      height: 410,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF8E8), Color(0xFFFFE8B8)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFCDBE9D), width: 2),
      ),
      child: Column(
        children: [
          Text(
            isNew
                ? (isFrench ? 'NOUVEAU PIGEON !' : 'NEW PIGEON!')
                : 'PIDGE PARK!',
            style: const TextStyle(
              color: Color(0xFFE35F55),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              PigeonAvatar(pigeon: pigeon, size: 170),
              const Positioned(
                left: -16,
                top: 12,
                child: Icon(Icons.auto_awesome, color: Color(0xFFE8AE32)),
              ),
              const Positioned(
                right: -12,
                bottom: 18,
                child: Icon(Icons.auto_awesome, color: Color(0xFFE8AE32)),
              ),
            ],
          ),
          const Spacer(),
          Text(
            pigeon.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: pigeon.rarity.color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              pigeon.rarity.label(isFrench).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 13),
          Text(
            '${isFrench ? 'AMITIÉ' : 'FRIENDSHIP'}  ${progress.affection}/10',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          const Text(
            '#PidgePark · a cosy game',
            style: TextStyle(color: Color(0xFF6F755F), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
