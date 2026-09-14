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
    final roll = seed % 20;
    return ParkAmbience(
      period: period,
      weather: roll < 4
          ? ParkWeather.rainy
          : roll < 11
          ? ParkWeather.cloudy
          : ParkWeather.sunny,
      slotKey: date.year * 100000 + date.month * 1000 + date.day * 10 + slot,
    );
  }

  PigeonWeather get pigeonWeather => switch (weather) {
    ParkWeather.sunny => PigeonWeather.sunny,
    ParkWeather.cloudy => PigeonWeather.cloudy,
    ParkWeather.rainy => PigeonWeather.rainy,
  };
  List<Color> get skyColors => switch (period) {
    ParkDayPeriod.morning => const [Color(0xFFFFD6A0), Color(0xFFB9DBE8)],
    ParkDayPeriod.day => const [Color(0xFF83C7E6), Color(0xFFD9EEF2)],
    ParkDayPeriod.sunset => const [Color(0xFFEE8A72), Color(0xFFF6CAA0)],
    ParkDayPeriod.night => const [Color(0xFF263550), Color(0xFF67768C)],
  };
  Color get overlay => switch (period) {
    ParkDayPeriod.morning => const Color(0x12FFD07A),
    ParkDayPeriod.day => Colors.transparent,
    ParkDayPeriod.sunset => const Color(0x24E5684C),
    ParkDayPeriod.night => const Color(0x55303A60),
  };
  IconData get icon => switch (weather) {
    ParkWeather.sunny => Icons.wb_sunny_outlined,
    ParkWeather.cloudy => Icons.cloud_outlined,
    ParkWeather.rainy => Icons.water_drop_outlined,
  };
  String periodLabel(bool fr) => switch (period) {
    ParkDayPeriod.morning => fr ? 'Matin' : 'Morning',
    ParkDayPeriod.day => fr ? 'Journée' : 'Daytime',
    ParkDayPeriod.sunset => fr ? 'Coucher de soleil' : 'Sunset',
    ParkDayPeriod.night => fr ? 'Nuit' : 'Night',
  };
  String weatherLabel(bool fr) => switch (weather) {
    ParkWeather.sunny => fr ? 'Ensoleillé' : 'Sunny',
    ParkWeather.cloudy => fr ? 'Nuageux' : 'Cloudy',
    ParkWeather.rainy => fr ? 'Petite pluie' : 'Light rain',
  };
}
