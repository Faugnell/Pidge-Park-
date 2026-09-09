import 'package:flutter/material.dart';

class Food {
  const Food({
    required this.id,
    required this.nameFr,
    required this.nameEn,
    required this.descriptionFr,
    required this.descriptionEn,
    required this.price,
    required this.duration,
    required this.debugDuration,
    required this.icon,
    required this.color,
    required this.visitorIds,
  });

  final String id;
  final String nameFr;
  final String nameEn;
  final String descriptionFr;
  final String descriptionEn;
  final int price;
  final Duration duration;
  final Duration debugDuration;
  final IconData icon;
  final Color color;
  final List<String> visitorIds;

  String name(bool isFrench) => isFrench ? nameFr : nameEn;
  String description(bool isFrench) => isFrench ? descriptionFr : descriptionEn;
}

const foods = <Food>[
  Food(
    id: 'seeds',
    nameFr: 'Graines',
    nameEn: 'Seeds',
    descriptionFr: 'Attire des pigeons communs.',
    descriptionEn: 'Attracts common pigeons.',
    price: 0,
    duration: Duration(minutes: 15),
    debugDuration: Duration(seconds: 8),
    icon: Icons.grass,
    color: Color(0xFFD6A64F),
    visitorIds: ['gilbert', 'michel', 'chonky'],
  ),
  Food(
    id: 'bread',
    nameFr: 'Pain',
    nameEn: 'Bread',
    descriptionFr: 'Classique et efficace.',
    descriptionEn: 'Classic and effective.',
    price: 50,
    duration: Duration(minutes: 30),
    debugDuration: Duration(seconds: 10),
    icon: Icons.bakery_dining,
    color: Color(0xFFD9914B),
    visitorIds: ['michel', 'jean_pigeon', 'gilbert'],
  ),
  Food(
    id: 'fries',
    nameFr: 'Frites',
    nameEn: 'Fries',
    descriptionFr: 'Très populaires.',
    descriptionEn: 'Very popular.',
    price: 150,
    duration: Duration(hours: 1),
    debugDuration: Duration(seconds: 12),
    icon: Icons.fastfood,
    color: Color(0xFFE4B743),
    visitorIds: ['kevin', 'chonky', 'brenda'],
  ),
  Food(
    id: 'croissant',
    nameFr: 'Croissant',
    nameEn: 'Croissant',
    descriptionFr: 'Irrésistible le matin.',
    descriptionEn: 'Irresistible in the morning.',
    price: 300,
    duration: Duration(hours: 2),
    debugDuration: Duration(seconds: 14),
    icon: Icons.breakfast_dining,
    color: Color(0xFFC9823C),
    visitorIds: ['brenda', 'jean_pigeon', 'kevin'],
  ),
  Food(
    id: 'pizza',
    nameFr: 'Pizza',
    nameEn: 'Pizza',
    descriptionFr: 'Son parfum porte loin.',
    descriptionEn: 'Its scent travels far.',
    price: 600,
    duration: Duration(hours: 4),
    debugDuration: Duration(seconds: 16),
    icon: Icons.local_pizza,
    color: Color(0xFFD76845),
    visitorIds: ['sir_pigeonton', 'kevin', 'chonky'],
  ),
  Food(
    id: 'premium_seeds',
    nameFr: 'Graines premium',
    nameEn: 'Premium seeds',
    descriptionFr: 'Le meilleur choix du parc.',
    descriptionEn: 'The finest choice in the park.',
    price: 1000,
    duration: Duration(hours: 6),
    debugDuration: Duration(seconds: 18),
    icon: Icons.inventory_2,
    color: Color(0xFF8E7043),
    visitorIds: ['sir_pigeonton', 'capitaine_plume', 'celeste'],
  ),
];

Food? foodById(String? id) {
  if (id == null) return null;
  for (final food in foods) {
    if (food.id == id) return food;
  }
  return null;
}
