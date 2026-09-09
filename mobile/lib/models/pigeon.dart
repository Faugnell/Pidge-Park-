import 'package:flutter/material.dart';

enum PigeonRarity {
  common('Commun', 'Common', Color(0xFF8A8A78)),
  rare('Rare', 'Rare', Color(0xFF4D8BB8)),
  epic('Épique', 'Epic', Color(0xFF9A68AD)),
  legendary('Légendaire', 'Legendary', Color(0xFFD49A35));

  const PigeonRarity(this.frenchLabel, this.englishLabel, this.color);

  final String frenchLabel;
  final String englishLabel;
  final Color color;

  String label(bool isFrench) => isFrench ? frenchLabel : englishLabel;
}

class Pigeon {
  const Pigeon({
    required this.id,
    required this.number,
    required this.name,
    required this.rarity,
    required this.descriptionFr,
    required this.descriptionEn,
    required this.color,
    this.accessory,
  });

  final String id;
  final int number;
  final String name;
  final PigeonRarity rarity;
  final String descriptionFr;
  final String descriptionEn;
  final Color color;
  final IconData? accessory;

  String description(bool isFrench) => isFrench ? descriptionFr : descriptionEn;
}

const pigeons = <Pigeon>[
  Pigeon(
    id: 'gilbert',
    number: 1,
    name: 'Gilbert',
    rarity: PigeonRarity.common,
    descriptionFr: 'Il adore les graines et les commérages. Toujours le premier à tout savoir.',
    descriptionEn:
        'He loves seeds and gossip. Always the first to know everything.',
    color: Color(0xFF87939A),
  ),
  Pigeon(
    id: 'michel',
    number: 2,
    name: 'Michel',
    rarity: PigeonRarity.common,
    descriptionFr: 'Un habitué du parc qui ne rate jamais l’heure du goûter.',
    descriptionEn: 'A park regular who never misses snack time.',
    color: Color(0xFFA3AAA7),
  ),
  Pigeon(
    id: 'chunky',
    number: 3,
    name: 'Chunky',
    rarity: PigeonRarity.common,
    descriptionFr: 'Petit par la taille, immense par l’appétit.',
    descriptionEn: 'Small in size, enormous in appetite.',
    color: Color(0xFF6F7474),
  ),
  Pigeon(
    id: 'kevin',
    number: 4,
    name: 'Kevin',
    rarity: PigeonRarity.rare,
    descriptionFr: 'On le reconnaît au bruit de ses frites qui disparaissent.',
    descriptionEn: 'You can recognize him by the sound of disappearing fries.',
    color: Color(0xFF8A9AA0),
    accessory: Icons.fastfood_outlined,
  ),
  Pigeon(
    id: 'brenda',
    number: 5,
    name: 'Brenda',
    rarity: PigeonRarity.rare,
    descriptionFr: 'Élégante, mystérieuse et toujours parfaitement coiffée.',
    descriptionEn: 'Elegant, mysterious, and always perfectly groomed.',
    color: Color(0xFF547488),
  ),
  Pigeon(
    id: 'jean_pigeon',
    number: 6,
    name: 'Jean-Pigeon',
    rarity: PigeonRarity.epic,
    descriptionFr:
        'Un grand voyageur qui prétend avoir vu toutes les fontaines du monde.',
    descriptionEn: 'A great traveller who claims to have seen every fountain in the world.',
    color: Color(0xFFF1EEE1),
  ),
  Pigeon(
    id: 'sir_pigeonton',
    number: 7,
    name: 'Sir Pigeonton',
    rarity: PigeonRarity.epic,
    descriptionFr: 'Il possède probablement davantage d’immobilier que toi.',
    descriptionEn: 'He probably owns more real estate than you do.',
    color: Color(0xFF555A5B),
    accessory: Icons.workspace_premium,
  ),
  Pigeon(
    id: 'capitaine_plume',
    number: 8,
    name: 'Capitaine Plume',
    rarity: PigeonRarity.legendary,
    descriptionFr: 'La légende raconte qu’il connaît une île faite de miettes.',
    descriptionEn: 'Legend says he knows an island made entirely of crumbs.',
    color: Color(0xFF765747),
    accessory: Icons.sailing,
  ),
  Pigeon(
    id: 'celeste',
    number: 9,
    name: 'Céleste',
    rarity: PigeonRarity.legendary,
    descriptionFr: 'Elle n’apparaît que lorsque le ciel et le parc sont parfaitement calmes.',
    descriptionEn:
        'She only appears when the sky and the park are perfectly still.',
    color: Color(0xFF9E92B8),
    accessory: Icons.auto_awesome,
  ),
];
