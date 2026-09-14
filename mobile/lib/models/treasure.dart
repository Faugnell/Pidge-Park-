import 'package:flutter/material.dart';

class PigeonTreasure {
  const PigeonTreasure({
    required this.id,
    required this.pigeonId,
    required this.nameFr,
    required this.nameEn,
    required this.descriptionFr,
    required this.descriptionEn,
    required this.icon,
    this.requiredAffection = 6,
  });

  final String id;
  final String pigeonId;
  final String nameFr;
  final String nameEn;
  final String descriptionFr;
  final String descriptionEn;
  final IconData icon;
  final int requiredAffection;

  String name(bool isFrench) => isFrench ? nameFr : nameEn;
  String description(bool isFrench) => isFrench ? descriptionFr : descriptionEn;
}

const treasures = <PigeonTreasure>[
  PigeonTreasure(
    id: 'dirty_spoon',
    pigeonId: 'gilbert',
    nameFr: 'Cuillère sale',
    nameEn: 'Dirty spoon',
    descriptionFr: 'Gilbert affirme qu’elle a appartenu à un maire.',
    descriptionEn: 'Gilbert claims it once belonged to a mayor.',
    icon: Icons.soup_kitchen_outlined,
  ),
  PigeonTreasure(
    id: 'old_sock',
    pigeonId: 'michel',
    nameFr: 'Chaussette',
    nameEn: 'Old sock',
    descriptionFr: 'Une chaussette solitaire au parfum inexplicable.',
    descriptionEn: 'A lonely sock with an inexplicable scent.',
    icon: Icons.checkroom,
  ),
  PigeonTreasure(
    id: 'rusty_screw',
    pigeonId: 'chonky',
    nameFr: 'Vis rouillée',
    nameEn: 'Rusty screw',
    descriptionFr: 'Chonky la gardait pour les grandes occasions.',
    descriptionEn: 'Chonky saved it for special occasions.',
    icon: Icons.hardware,
  ),
  PigeonTreasure(
    id: 'bus_ticket',
    pigeonId: 'kevin',
    nameFr: 'Ticket de bus',
    nameEn: 'Bus ticket',
    descriptionFr: 'Kevin n’a manifestement jamais validé ce ticket.',
    descriptionEn: 'Kevin clearly never validated this ticket.',
    icon: Icons.confirmation_number_outlined,
  ),
  PigeonTreasure(
    id: 'two_cents',
    pigeonId: 'brenda',
    nameFr: 'Pièce de 2 centimes',
    nameEn: 'Two-cent coin',
    descriptionFr: 'Brenda la présente comme un investissement.',
    descriptionEn: 'Brenda calls it an investment.',
    icon: Icons.paid_outlined,
  ),
  PigeonTreasure(
    id: 'mysterious_key',
    pigeonId: 'jean_pigeon',
    nameFr: 'Clé mystérieuse',
    nameEn: 'Mysterious key',
    descriptionFr: 'Elle ouvre sûrement quelque chose. Probablement.',
    descriptionEn: 'It surely opens something. Probably.',
    icon: Icons.key_outlined,
  ),
  PigeonTreasure(
    id: 'golden_button',
    pigeonId: 'croissigeon',
    nameFr: 'Bouton doré',
    nameEn: 'Golden button',
    descriptionFr: 'Encore tiède, sans raison apparente.',
    descriptionEn: 'Still warm, for no apparent reason.',
    icon: Icons.circle_outlined,
  ),
  PigeonTreasure(
    id: 'bottle_cap',
    pigeonId: 'pigeoffrey',
    nameFr: 'Capsule brillante',
    nameEn: 'Shiny bottle cap',
    descriptionFr: 'Elle brille davantage près d’une fontaine.',
    descriptionEn: 'It shines brighter near a fountain.',
    icon: Icons.local_drink_outlined,
  ),
  PigeonTreasure(
    id: 'black_ribbon',
    pigeonId: 'gothigeon',
    nameFr: 'Ruban noir',
    nameEn: 'Black ribbon',
    descriptionFr: 'Contient trois strophes très tristes.',
    descriptionEn: 'Contains three extremely sad verses.',
    icon: Icons.bookmark_border,
  ),
  PigeonTreasure(
    id: 'disco_token',
    pigeonId: 'disco_pigeon',
    nameFr: 'Jeton disco',
    nameEn: 'Disco token',
    descriptionFr: 'Valable dans une discothèque disparue en 1987.',
    descriptionEn: 'Valid at a nightclub that vanished in 1987.',
    icon: Icons.album_outlined,
  ),
];

PigeonTreasure? treasureForPigeon(String pigeonId) {
  for (final treasure in treasures) {
    if (treasure.pigeonId == pigeonId) return treasure;
  }
  return null;
}
