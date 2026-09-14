import 'package:flutter/material.dart';

import 'pigeon.dart';

enum KeepsakeKind { accessory, companion, souvenir }

class PigeonKeepsake {
  const PigeonKeepsake({
    required this.pigeonId,
    required this.nameFr,
    required this.nameEn,
    required this.kind,
    required this.icon,
  });

  String get id => '$pigeonId.${kind.name}';
  final String pigeonId;
  final String nameFr;
  final String nameEn;
  final KeepsakeKind kind;
  final IconData icon;

  String name(bool isFrench) => isFrench ? nameFr : nameEn;
  String discoveryLine(bool isFrench) => isFrench
      ? keepsakeDiscoveryLinesFr[pigeonId]!
      : keepsakeDiscoveryLinesEn[pigeonId]!;
}

const pigeonKeepsakes = <PigeonKeepsake>[
  PigeonKeepsake(
    pigeonId: 'gilbert',
    nameFr: 'Tasse à café',
    nameEn: 'Coffee cup',
    kind: KeepsakeKind.accessory,
    icon: Icons.coffee,
  ),
  PigeonKeepsake(
    pigeonId: 'michel',
    nameFr: 'Montre de goûter',
    nameEn: 'Snack-time watch',
    kind: KeepsakeKind.souvenir,
    icon: Icons.watch_later_outlined,
  ),
  PigeonKeepsake(
    pigeonId: 'chonky',
    nameFr: 'Mini escargot',
    nameEn: 'Tiny snail',
    kind: KeepsakeKind.companion,
    icon: Icons.pest_control_outlined,
  ),
  PigeonKeepsake(
    pigeonId: 'kevin',
    nameFr: 'Lunettes frites',
    nameEn: 'Fry glasses',
    kind: KeepsakeKind.accessory,
    icon: Icons.visibility_outlined,
  ),
  PigeonKeepsake(
    pigeonId: 'brenda',
    nameFr: 'Nœud de soie',
    nameEn: 'Silk bow',
    kind: KeepsakeKind.accessory,
    icon: Icons.brightness_5_outlined,
  ),
  PigeonKeepsake(
    pigeonId: 'jean_pigeon',
    nameFr: 'Carte de Paris',
    nameEn: 'Paris postcard',
    kind: KeepsakeKind.souvenir,
    icon: Icons.map_outlined,
  ),
  PigeonKeepsake(
    pigeonId: 'croissigeon',
    nameFr: 'Béret doré',
    nameEn: 'Golden beret',
    kind: KeepsakeKind.accessory,
    icon: Icons.emoji_objects_outlined,
  ),
  PigeonKeepsake(
    pigeonId: 'pigeoffrey',
    nameFr: 'Petite grenouille',
    nameEn: 'Little frog',
    kind: KeepsakeKind.companion,
    icon: Icons.cruelty_free_outlined,
  ),
  PigeonKeepsake(
    pigeonId: 'gothigeon',
    nameFr: 'Chauve-souris',
    nameEn: 'Bat companion',
    kind: KeepsakeKind.companion,
    icon: Icons.bathtub_outlined,
  ),
  PigeonKeepsake(
    pigeonId: 'disco_pigeon',
    nameFr: 'Lunettes disco',
    nameEn: 'Disco glasses',
    kind: KeepsakeKind.accessory,
    icon: Icons.visibility,
  ),
  PigeonKeepsake(
    pigeonId: 'pigeasso',
    nameFr: 'Pinceau fétiche',
    nameEn: 'Lucky paintbrush',
    kind: KeepsakeKind.souvenir,
    icon: Icons.brush,
  ),
  PigeonKeepsake(
    pigeonId: 'sherlock',
    nameFr: 'Casquette d’enquête',
    nameEn: 'Detective cap',
    kind: KeepsakeKind.accessory,
    icon: Icons.search,
  ),
  PigeonKeepsake(
    pigeonId: 'pigeonzilla',
    nameFr: 'Mini lézard',
    nameEn: 'Tiny lizard',
    kind: KeepsakeKind.companion,
    icon: Icons.pets,
  ),
  PigeonKeepsake(
    pigeonId: 'pigeon_potter',
    nameFr: 'Écharpe magique',
    nameEn: 'Magic scarf',
    kind: KeepsakeKind.accessory,
    icon: Icons.auto_fix_high,
  ),
  PigeonKeepsake(
    pigeonId: 'sir_pigeonton',
    nameFr: 'Monocle ancien',
    nameEn: 'Antique monocle',
    kind: KeepsakeKind.accessory,
    icon: Icons.remove_red_eye_outlined,
  ),
  PigeonKeepsake(
    pigeonId: 'don_pigeone',
    nameFr: 'Rose de la famille',
    nameEn: 'Family rose',
    kind: KeepsakeKind.accessory,
    icon: Icons.local_florist,
  ),
  PigeonKeepsake(
    pigeonId: 'pigeoin',
    nameFr: 'Pièce porte-bonheur',
    nameEn: 'Lucky coin',
    kind: KeepsakeKind.souvenir,
    icon: Icons.monetization_on,
  ),
  PigeonKeepsake(
    pigeonId: 'napoleon',
    nameFr: 'Bicorne impérial',
    nameEn: 'Imperial bicorne',
    kind: KeepsakeKind.accessory,
    icon: Icons.change_history,
  ),
  PigeonKeepsake(
    pigeonId: 'pigeon_exe',
    nameFr: 'Pixel apprivoisé',
    nameEn: 'Tame pixel',
    kind: KeepsakeKind.companion,
    icon: Icons.memory,
  ),
  PigeonKeepsake(
    pigeonId: 'king_pigeon',
    nameFr: 'Couronne du parc',
    nameEn: 'Park crown',
    kind: KeepsakeKind.accessory,
    icon: Icons.workspace_premium,
  ),
  PigeonKeepsake(
    pigeonId: 'miette',
    nameFr: 'Papillon bleu',
    nameEn: 'Blue butterfly',
    kind: KeepsakeKind.companion,
    icon: Icons.flutter_dash,
  ),
  PigeonKeepsake(
    pigeonId: 'roger',
    nameFr: 'Journal plié',
    nameEn: 'Folded newspaper',
    kind: KeepsakeKind.souvenir,
    icon: Icons.newspaper,
  ),
  PigeonKeepsake(
    pigeonId: 'baguettine',
    nameFr: 'Petit foulard',
    nameEn: 'Little neckerchief',
    kind: KeepsakeKind.accessory,
    icon: Icons.air,
  ),
  PigeonKeepsake(
    pigeonId: 'professeur_plume',
    nameFr: 'Mini hibou',
    nameEn: 'Tiny owl',
    kind: KeepsakeKind.companion,
    icon: Icons.school,
  ),
  PigeonKeepsake(
    pigeonId: 'fleur',
    nameFr: 'Couronne de fleurs',
    nameEn: 'Flower crown',
    kind: KeepsakeKind.accessory,
    icon: Icons.local_florist,
  ),
  PigeonKeepsake(
    pigeonId: 'radio_piaf',
    nameFr: 'Micro vintage',
    nameEn: 'Vintage microphone',
    kind: KeepsakeKind.souvenir,
    icon: Icons.mic,
  ),
  PigeonKeepsake(
    pigeonId: 'monsieur_propre',
    nameFr: 'Petit balai',
    nameEn: 'Little broom',
    kind: KeepsakeKind.souvenir,
    icon: Icons.cleaning_services,
  ),
  PigeonKeepsake(
    pigeonId: 'minuit',
    nameFr: 'Luciolle',
    nameEn: 'Firefly',
    kind: KeepsakeKind.companion,
    icon: Icons.light_mode_outlined,
  ),
  PigeonKeepsake(
    pigeonId: 'capitaine_plume',
    nameFr: 'Perroquet miniature',
    nameEn: 'Miniature parrot',
    kind: KeepsakeKind.companion,
    icon: Icons.pets,
  ),
  PigeonKeepsake(
    pigeonId: 'celeste',
    nameFr: 'Étoile filante',
    nameEn: 'Shooting star',
    kind: KeepsakeKind.accessory,
    icon: Icons.auto_awesome,
  ),
];

const keepsakeDiscoveryLinesFr = <String, String>{
  'gilbert': 'Elle est un peu ébréchée, mais le café n’a jamais protesté.',
  'michel': 'Comme ça, personne ne pourra dire que le goûter est en retard.',
  'chonky': 'Il est petit, lent et il ne juge jamais mes portions.',
  'kevin': 'Elles ne se mangent pas. J’ai vérifié deux fois.',
  'brenda': 'Une touche de soie améliore absolument toutes les journées.',
  'jean_pigeon': 'Je l’ai gardée pour ne jamais oublier le chemin du retour.',
  'croissigeon': 'Il penche un peu, c’est ce qui fait tout son charme.',
  'pigeoffrey': 'Nous méditons ensemble. Enfin, surtout moi.',
  'gothigeon': 'Elle comprend mes silences. Et mes poèmes les plus sombres.',
  'disco_pigeon':
      'Attention, elles transforment chaque trottoir en piste de danse.',
  'pigeasso': 'Mon meilleur pinceau. Il refuse les œuvres sans miettes.',
  'sherlock': 'Élémentaire : cette casquette appartenait forcément à un génie.',
  'pigeonzilla': 'Il n’a peur de rien. Sauf peut-être de moi.',
  'pigeon_potter': 'Je suis presque certain qu’elle a bougé toute seule.',
  'sir_pigeonton':
      'Une pièce familiale. Veuillez la manipuler avec distinction.',
  'don_pigeone': 'Une rose pour ceux qui prennent soin de la famille.',
  'pigeoin': 'Sa valeur sentimentale connaît une croissance remarquable.',
  'napoleon': 'Enfin un couvre-chef à la mesure de mes ambitions.',
  'pigeon_exe': 'Compagnon détecté. Compatibilité : étonnamment acceptable.',
  'king_pigeon': 'Une couronne ne fait pas le roi, mais elle aide beaucoup.',
  'miette': 'Il s’est posé près de moi et a décidé de rester.',
  'roger': 'Les nouvelles sont anciennes, comme je les aime.',
  'baguettine': 'Un petit foulard pour les grands courants d’air.',
  'professeur_plume':
      'Un excellent assistant, malgré ses références incomplètes.',
  'fleur': 'Je l’ai composée pétale par pétale. Pas de pattes boueuses.',
  'radio_piaf': 'Il grésille un peu, mais il connaît tous mes refrains.',
  'monsieur_propre':
      'Pour les miettes récalcitrantes et les urgences du dimanche.',
  'minuit': 'Une petite lumière qui ne pose jamais de questions.',
  'capitaine_plume': 'Il a survécu à sept tempêtes. D’après lui.',
  'celeste': 'Elle brillait déjà avant que je la ramasse.',
};

const keepsakeDiscoveryLinesEn = <String, String>{
  'gilbert': 'It is slightly chipped, but the coffee never complained.',
  'michel': 'Now nobody can claim snack time is running late.',
  'chonky': 'He is small, slow, and never judges my portions.',
  'kevin': 'They are not edible. I checked twice.',
  'brenda': 'A touch of silk improves absolutely every day.',
  'jean_pigeon': 'I kept it so I would never forget the way home.',
  'croissigeon': 'It tilts a little. That is what gives it charm.',
  'pigeoffrey': 'We meditate together. Well, mostly me.',
  'gothigeon': 'She understands my silences. And my darkest poems.',
  'disco_pigeon': 'Careful, they turn every pavement into a dance floor.',
  'pigeasso': 'My finest brush. It refuses crumb-free artwork.',
  'sherlock': 'Elementary: this cap clearly belonged to a genius.',
  'pigeonzilla': 'He fears nothing. Except perhaps me.',
  'pigeon_potter': 'I am almost certain it moved on its own.',
  'sir_pigeonton': 'A family piece. Kindly handle it with distinction.',
  'don_pigeone': 'A rose for those who look after the family.',
  'pigeoin': 'Its sentimental value is showing remarkable growth.',
  'napoleon': 'At last, headwear worthy of my ambitions.',
  'pigeon_exe': 'Companion detected. Compatibility: surprisingly acceptable.',
  'king_pigeon': 'A crown does not make a king, but it helps enormously.',
  'miette': 'It landed beside me and decided to stay.',
  'roger': 'Old news, just the way I like it.',
  'baguettine': 'A little scarf for very large draughts.',
  'professeur_plume': 'An excellent assistant, despite incomplete references.',
  'fleur': 'I arranged it petal by petal. No muddy feet.',
  'radio_piaf': 'It crackles a little, but it knows all my tunes.',
  'monsieur_propre': 'For stubborn crumbs and Sunday emergencies.',
  'minuit': 'A little light that never asks questions.',
  'capitaine_plume': 'He survived seven storms. According to him.',
  'celeste': 'It was already shining before I picked it up.',
};

PigeonKeepsake keepsakeForPigeon(String pigeonId) =>
    pigeonKeepsakes.firstWhere((item) => item.pigeonId == pigeonId);

PigeonKeepsake? keepsakeById(String? id) =>
    pigeonKeepsakes.where((item) => item.id == id).firstOrNull;

double keepsakeBaseChance(Pigeon pigeon) => switch (pigeon.rarity) {
  PigeonRarity.common => 0.05,
  PigeonRarity.rare => 0.01,
  PigeonRarity.epic => 0.0025,
  PigeonRarity.legendary => 0.001,
};
