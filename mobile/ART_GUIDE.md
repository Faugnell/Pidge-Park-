# Pidge Park — guide de livraison graphique

Ce dossier permet de remplacer progressivement les mockups Flutter par les
illustrations finales, sans modifier le code. Tant qu'un fichier est absent,
l'application affiche automatiquement son icône temporaire.

## Règles d'export

- Format : PNG avec transparence alpha.
- Espace colorimétrique : sRGB.
- Aucun espace, accent ou majuscule dans les noms de fichiers.
- Conserver une marge transparente autour des sujets ; ne pas recadrer chaque
  variante différemment.
- Exporter les fichiers à leur taille native. Flutter se charge de la réduction.
- Ne jamais intégrer d'ombre portée coupée par les limites du canevas.

## Pigeons

Chemin : `assets/art/pigeons/<pigeon_id>.png`

- Canevas : 1024 × 1024 px transparent.
- Le pigeon entier doit rester dans la zone centrale de 820 × 820 px.
- Position et échelle identiques pour tous les pigeons autant que possible.
- Orientation par défaut : profil tourné vers la gauche.
- Les vêtements, accessoires et familiers ne doivent pas être fusionnés au
  pigeon de base.

Exemple : `assets/art/pigeons/gilbert.png`.

## Accessoires universels

Chemin : `assets/art/cosmetics/accessories/<item_id>.png`

- Canevas : 1024 × 1024 px transparent, identique à celui du pigeon.
- L'accessoire doit être dessiné directement à sa position finale.
- Points d'ancrage de référence : tête `(0.50, 0.20)`, visage `(0.50, 0.34)`,
  cou `(0.50, 0.48)`.
- Un accessoire doit pouvoir être superposé à tous les pigeons.
- Si une morphologie exige une correction, utiliser plus tard une variante
  `<item_id>--<pigeon_id>.png`. Le fichier universel reste obligatoire.

Exemple :
`assets/art/cosmetics/accessories/halloween_jack_o_lantern.png`.

## Familiers

Chemin : `assets/art/cosmetics/companions/<item_id>.png`

- Canevas : 1024 × 1024 px transparent.
- Position de référence : bas-droite, ancrage `(0.82, 0.78)`.
- Le familier ne doit pas masquer le visage du pigeon.

## Décorations

Chemin : `assets/art/decorations/<decoration_id>.png`

- PNG transparent, sRGB.
- Grand élément : 1536 × 1536 px maximum.
- Élément moyen : 1024 × 1024 px maximum.
- Petit élément : 768 × 768 px maximum.
- L'objet doit toucher visuellement le bas du canevas pour faciliter son
  placement sur le sol.

## Thèmes

Chemin : `assets/art/themes/<theme_id>.png`

- Fond vertical : 1440 × 2560 px minimum.
- Garder libres les zones de monnaies en haut et d'action en bas.
- Les décorations interactives restent des calques séparés.

## Identifiants

Les identifiants des pigeons, objets et décorations sont ceux présents dans :

- `lib/models/pigeon.dart`
- `lib/models/pigeon_keepsake.dart`
- `lib/models/decoration.dart`

Ils ne doivent pas être traduits dans les noms de fichiers. Les textes français
et anglais restent gérés par l'application.

## Validation d'une livraison

1. Placer les PNG dans les dossiers prévus.
2. Lancer `flutter pub get` si de nouveaux dossiers ont été ajoutés.
3. Lancer `flutter run` et contrôler le parc, le Pigeondex, l'inventaire et la
   fiche de partage.
4. Tester au minimum un petit et un grand écran Android, puis un iPhone.
5. Vérifier qu'aucun accessoire ne masque les yeux ou ne sort du canevas.

Le fichier `assets/art/manifest.json` contient les dimensions et ancrages sous
une forme lisible par de futurs outils d'import ou de validation.
