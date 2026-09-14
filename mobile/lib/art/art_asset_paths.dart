abstract final class ArtAssetPaths {
  static const root = 'assets/art';

  static String pigeon(String pigeonId) => '$root/pigeons/$pigeonId.png';

  static String accessory(String itemId) =>
      '$root/cosmetics/accessories/$itemId.png';

  static String companion(String itemId) =>
      '$root/cosmetics/companions/$itemId.png';

  static String decoration(String decorationId) =>
      '$root/decorations/$decorationId.png';

  static String themeBackground(String themeId) => '$root/themes/$themeId.png';
}
