const translations = {
  en: {
    "nav.home": "Home",
    "nav.about": "About",
    "nav.features": "Features",
    "nav.pigeons": "Pigeons",
    "nav.screenshots": "Screenshots",
    "nav.faq": "FAQ",
    "nav.download": "Download on Mobile",
    "hero.tagline": "A tiny park. A very big flock.",
    "hero.description": "Collect cute pigeons, feed them, decorate and upgrade your park, complete daily missions and grow your collection.",
    "hero.download": "Download on Mobile",
    "mockup.hero": "Hero illustration placeholder",
    "strip.collect": "Collect unique pigeons",
    "strip.feed": "Feed and befriend",
    "strip.decorate": "Decorate and upgrade",
    "strip.missions": "Daily missions",
    "strip.collection": "Grow your collection",
    "features.title": "Make a park worth cooing about.",
    "features.intro": "Turn a quiet corner into a cosy home for pigeons and people alike.",
    "cards.collect.title": "Collect & Care",
    "cards.collect.description": "Discover rare pigeons, feed them their favourite snacks and build lasting friendships.",
    "cards.collect.button": "Collect Pigeons",
    "cards.decorate.title": "Decorate & Upgrade",
    "cards.decorate.description": "Add benches, fountains, flowers and more. Make the park uniquely yours.",
    "cards.decorate.button": "Decorate Your Park",
    "cards.missions.title": "Daily Missions",
    "cards.missions.description": "Take on fun daily tasks, earn rewards and keep your flock happy.",
    "cards.missions.button": "View Missions",
    "pigeons.title": "Meet the locals",
    "pigeons.intro": "Every pigeon has a story. Here are a few friendly faces you might meet in the park!",
    "pigeons.pebble.description": "A curious little explorer who always finds the best snacks.",
    "pigeons.pebble.tag": "Curious",
    "pigeons.maple.description": "A warm and gentle soul who loves sunny spots and making friends.",
    "pigeons.maple.tag": "Friendly",
    "pigeons.nimbus.description": "A calm daydreamer who always seems to find the cloudiest seat.",
    "pigeons.nimbus.tag": "Dreamer",
    "follow.title": "Follow the flock",
    "follow.description": "Get the latest updates, behind the scenes art, new pigeons and more!",
    "follow.button": "Follow Along",
    "faq.title": "Frequently asked questions",
    "faq.description": "More information about Pidge Park is coming soon.",
    "footer.tagline": "A cosier world, one pigeon at a time.",
    "footer.privacy": "Privacy",
    "footer.terms": "Terms",
    "footer.contact": "Contact",
    "footer.press": "Press"
  },
  fr: {
    "nav.home": "Accueil",
    "nav.about": "À propos",
    "nav.features": "Fonctionnalités",
    "nav.pigeons": "Pigeons",
    "nav.screenshots": "Captures",
    "nav.faq": "FAQ",
    "nav.download": "Télécharger sur mobile",
    "hero.tagline": "Un tout petit parc. Une très grande volée.",
    "hero.description": "Collectionnez d'adorables pigeons, nourrissez-les, décorez et améliorez votre parc, accomplissez des missions quotidiennes et agrandissez votre collection.",
    "hero.download": "Télécharger sur mobile",
    "mockup.hero": "Emplacement de l’illustration principale",
    "strip.collect": "Collectionnez des pigeons uniques",
    "strip.feed": "Nourrissez-les et apprivoisez-les",
    "strip.decorate": "Décorez et améliorez",
    "strip.missions": "Missions quotidiennes",
    "strip.collection": "Agrandissez votre collection",
    "features.title": "Créez un parc qui mérite qu’on roucoule.",
    "features.intro": "Transformez un coin tranquille en un foyer chaleureux pour les pigeons comme pour les promeneurs.",
    "cards.collect.title": "Collectionnez et prenez soin",
    "cards.collect.description": "Découvrez des pigeons rares, offrez-leur leurs friandises préférées et nouez des amitiés durables.",
    "cards.collect.button": "Collectionner des pigeons",
    "cards.decorate.title": "Décorez et améliorez",
    "cards.decorate.description": "Ajoutez des bancs, des fontaines, des fleurs et bien plus. Créez un parc qui vous ressemble.",
    "cards.decorate.button": "Décorer votre parc",
    "cards.missions.title": "Missions quotidiennes",
    "cards.missions.description": "Relevez des défis amusants, gagnez des récompenses et rendez votre volée heureuse.",
    "cards.missions.button": "Voir les missions",
    "pigeons.title": "Rencontrez les habitants",
    "pigeons.intro": "Chaque pigeon a son histoire. Voici quelques compagnons que vous pourriez rencontrer dans le parc !",
    "pigeons.pebble.description": "Un petit explorateur curieux qui trouve toujours les meilleures friandises.",
    "pigeons.pebble.tag": "Curieux",
    "pigeons.maple.description": "Une âme douce et chaleureuse qui adore le soleil et se faire des amis.",
    "pigeons.maple.tag": "Amical",
    "pigeons.nimbus.description": "Un rêveur paisible qui semble toujours choisir la place la plus nuageuse.",
    "pigeons.nimbus.tag": "Rêveur",
    "follow.title": "Suivez la volée",
    "follow.description": "Découvrez les dernières nouvelles, les coulisses, de nouveaux pigeons et bien plus !",
    "follow.button": "Nous suivre",
    "faq.title": "Questions fréquentes",
    "faq.description": "Plus d’informations sur Pidge Park seront bientôt disponibles.",
    "footer.tagline": "Un monde plus douillet, un pigeon à la fois.",
    "footer.privacy": "Confidentialité",
    "footer.terms": "Conditions",
    "footer.contact": "Contact",
    "footer.press": "Presse"
  }
};

const languageSelect = document.querySelector("#language-select");
const supportedLanguages = Object.keys(translations);
const storageKey = "pidge-park-language";

function getSavedLanguage() {
  try {
    return localStorage.getItem(storageKey);
  } catch {
    return null;
  }
}

function getBrowserLanguage() {
  const browserLanguages = navigator.languages ?? [navigator.language];
  const preferredLanguage = browserLanguages.find((language) =>
    supportedLanguages.some((supportedLanguage) =>
      language.toLowerCase().startsWith(supportedLanguage)
    )
  );

  return preferredLanguage?.toLowerCase().startsWith("fr") ? "fr" : "en";
}

function applyLanguage(language) {
  const activeLanguage = supportedLanguages.includes(language) ? language : "en";

  document.documentElement.lang = activeLanguage;
  languageSelect.value = activeLanguage;

  document.querySelectorAll("[data-i18n]").forEach((element) => {
    const key = element.dataset.i18n;
    const translatedText = translations[activeLanguage][key];

    if (translatedText) {
      element.textContent = translatedText;
    }
  });

  const pageDescription = activeLanguage === "fr"
    ? "Pidge Park! est un jeu cosy où vous collectionnez des pigeons et prenez soin d’eux."
    : "Pidge Park! is a cosy game about collecting pigeons and giving them your love.";

  document.title = activeLanguage === "fr" ? "Pidge Park! — Jeu cosy" : "Pidge Park! — Cosy game";
  document.querySelector('meta[name="description"]').content = pageDescription;
}

const savedLanguage = getSavedLanguage();
const initialLanguage = supportedLanguages.includes(savedLanguage)
  ? savedLanguage
  : getBrowserLanguage();

applyLanguage(initialLanguage);

languageSelect.addEventListener("change", (event) => {
  const selectedLanguage = event.target.value;

  try {
    localStorage.setItem(storageKey, selectedLanguage);
  } catch {
    // La traduction fonctionne même si le stockage local est désactivé.
  }

  applyLanguage(selectedLanguage);
});
