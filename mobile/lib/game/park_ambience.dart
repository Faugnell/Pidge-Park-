import 'package:flutter/material.dart';

import '../models/pigeon.dart';

enum ParkDayPeriod { morning, day, sunset, night }

enum ParkWeather { sunny, cloudy, rainy }

class ParkAmbience {
  const ParkAmbience({
    required this.period,
    required this.weather,
    required this.slotKey,
  });

  final ParkDayPeriod period;
  final ParkWeather weather;
  final int slotKey;

  factory ParkAmbience.forDate(DateTime date) {
    final period = switch (date.hour) {
      >= 5 && < 10 => ParkDayPeriod.morning,
      >= 10 && < 17 => ParkDayPeriod.day,
      >= 17 && < 21 => ParkDayPeriod.sunset,
      _ => ParkDayPeriod.night,
    };
    final slot = date.hour ~/ 3;
    final seed = date.year * 10000 + date.month * 100 + date.day + slot * 7919;
    final weatherRoll = seed % 20;
    final weather = weatherRoll < 4
        ? ParkWeather.rainy
        : weatherRoll < 11
        ? ParkWeather.cloudy
        : ParkWeather.sunny;
    return ParkAmbience(
      period: period,
      weather: weather,
      slotKey: date.year * 100000 + date.month * 1000 + date.day * 10 + slot,
    );
  }

  PigeonWeather get pigeonWeather => switch (weather) {
    ParkWeather.sunny => PigeonWeather.sunny,
    ParkWeather.cloudy => PigeonWeather.cloudy,
    ParkWeather.rainy => PigeonWeather.rainy,
  };

  List<Color> get skyColors => switch (period) {
    ParkDayPeriod.morning => const [Color(0xFFFFD8A8), Color(0xFFBBDDEA)],
    ParkDayPeriod.day => const [Color(0xFF8CCBE8), Color(0xFFD9EEF2)],
    ParkDayPeriod.sunset => const [Color(0xFFF29B78), Color(0xFFF6D0A0)],
    ParkDayPeriod.night => const [Color(0xFF273653), Color(0xFF66758A)],
  };

  Color get lightOverlay => switch (period) {
    ParkDayPeriod.morning => const Color(0x14FFD28A),
    ParkDayPeriod.day => Colors.transparent,
    ParkDayPeriod.sunset => const Color(0x25E8754F),
    ParkDayPeriod.night => const Color(0x55303B61),
  };

  String periodLabel(bool isFrench) => switch (period) {
    ParkDayPeriod.morning => isFrench ? 'Matin' : 'Morning',
    ParkDayPeriod.day => isFrench ? 'Journée' : 'Daytime',
    ParkDayPeriod.sunset => isFrench ? 'Coucher de soleil' : 'Sunset',
    ParkDayPeriod.night => isFrench ? 'Nuit' : 'Night',
  };

  String weatherLabel(bool isFrench) => switch (weather) {
    ParkWeather.sunny => isFrench ? 'Ensoleillé' : 'Sunny',
    ParkWeather.cloudy => isFrench ? 'Nuageux' : 'Cloudy',
    ParkWeather.rainy => isFrench ? 'Petite pluie' : 'Light rain',
  };

  IconData get weatherIcon => switch (weather) {
    ParkWeather.sunny => Icons.wb_sunny_outlined,
    ParkWeather.cloudy => Icons.cloud_outlined,
    ParkWeather.rainy => Icons.water_drop_outlined,
  };
}
