import 'package:flutter/material.dart';

class ParkDecoration {
  const ParkDecoration({
    required this.id,
    required this.nameFr,
    required this.nameEn,
    required this.price,
    required this.icon,
  });

  final String id;
  final String nameFr;
  final String nameEn;
  final int price;
  final IconData icon;

  String name(bool isFrench) => isFrench ? nameFr : nameEn;
}

const decorations = <ParkDecoration>[
  ParkDecoration(
    id: 'bench',
    nameFr: 'Banc',
    nameEn: 'Bench',
    price: 0,
    icon: Icons.chair_alt,
  ),
  ParkDecoration(
    id: 'fountain',
    nameFr: 'Fontaine',
    nameEn: 'Fountain',
    price: 250,
    icon: Icons.water_drop_outlined,
  ),
  ParkDecoration(
    id: 'trash',
    nameFr: 'Poubelle',
    nameEn: 'Bin',
    price: 150,
    icon: Icons.delete_outline,
  ),
  ParkDecoration(
    id: 'lamp',
    nameFr: 'Lampadaire',
    nameEn: 'Lamp post',
    price: 300,
    icon: Icons.light_outlined,
  ),
  ParkDecoration(
    id: 'radio',
    nameFr: 'Radio',
    nameEn: 'Radio',
    price: 450,
    icon: Icons.radio_outlined,
  ),
  ParkDecoration(
    id: 'statue',
    nameFr: 'Statue',
    nameEn: 'Statue',
    price: 700,
    icon: Icons.account_balance,
  ),
  ParkDecoration(
    id: 'easel',
    nameFr: 'Chevalet',
    nameEn: 'Easel',
    price: 500,
    icon: Icons.brush_outlined,
  ),
  ParkDecoration(
    id: 'books',
    nameFr: 'Livres',
    nameEn: 'Books',
    price: 400,
    icon: Icons.auto_stories_outlined,
  ),
  ParkDecoration(
    id: 'flowers',
    nameFr: 'Fleurs',
    nameEn: 'Flowers',
    price: 350,
    icon: Icons.local_florist_outlined,
  ),
  ParkDecoration(
    id: 'baguette_stand',
    nameFr: 'Stand à baguettes',
    nameEn: 'Baguette stand',
    price: 850,
    icon: Icons.bakery_dining,
  ),
];
