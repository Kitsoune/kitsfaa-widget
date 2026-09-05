# Spécifications Techniques — Automatisation de Sélène (Fish an Anime RNG)

Ce document récapitule toutes les données, analyses et captures d'écran nécessaires pour la future automatisation complète de Sélène.

---

## 1. Mécaniques de Spawn (Données Wiki)
- **Fréquence du tirage serveur** : Toutes les **20 secondes**.
- **Probabilité par tirage** : **2.0 %** de chance d'apparition.
- **Espérance mathématique (moyenne)** : 1 chance sur 50 ➔ 50 × 20s = 1000s (environ **16 minutes et 40 secondes** d'attente moyenne).
- **Médiane statistique** : 50 % de chances cumulées d'être déjà apparue au bout de 34 tirages ➔ **~11 minutes et 20 secondes** (en pratique en jeu, elle apparaît donc très fréquemment en moins de 10 à 12 minutes).
- **Durée de présence** : Reste sur l'île pendant **4 minutes** (confirmé par le décompte in-game `Disappears in: 03:49` vu sur les captures).
- **Réglage indicatif du widget** : Cycle réglé à **10:00** d'absence (`AWAY · 10:00`) et **04:00** de présence (`ACTIVE 04:00`).
- **Annonce serveur** : Un message est envoyé à l'ensemble du serveur dans le chat à chaque arrivée.

---

## 2. Détection du Message Chat
- **Texte exact** : [Server] Selene has Arrived!
- **Couleurs dans le chat Roblox** :
  - Tag [Server] : Vert fluo (#00FF00)
  - Texte de l'événement : Violet / Mauve clair (#B266FF / #A371F7)
- **Zone de scan** : Coin supérieur gauche de la fenêtre Roblox (zone du chat de texte).
- **Méthode recommandée** : Scan régulier de couleur (PixelSearch) ou OCR Windows natif (Windows.Media.Ocr).
- **Contrainte Mode Nuit** : Pour que la détection fonctionne pendant que le joueur dort sans alerte sonore, le client Roblox doit rester actif et visible sur son bureau (Bureau 3 ou Bureau principal), l'écran pouvant être éteint physiquement sans mettre Windows en veille.

---

## 3. Déplacement vers le PNJ (Trajet & Recalibrage)
- **Position de Sélène** : Au pied d'un arbre à côté de la zone de pêche.
- **Prompt d'interaction** : [E] Selene's Store - Talk
- **Trajet Aller** :
  1. Maintenir Z pendant ~3 secondes (marche en avant).
  2. Maintenir D pendant ~1 seconde (décalage vers la droite).
  3. Appuyer sur E pour ouvrir le shop.
- **Points de vigilance & Risques** :
  - Présence d'eau et de vide à proximité immédiate (risque de chute/noyade).
  - Dérive d'orientation de la caméra au fil des heures (drift).
- **Solution de recalibrage recommandée** :
  - Sur le trajet retour (1s Q + 3s S), utiliser un mur ou une barrière derrière le spot de pêche comme butée mécanique afin d'annuler tout cumul d'erreur avant de relancer la ligne dans l'eau.

---

## 4. Structure du Shop de Sélène
- **En-tête** : Selene's Store!, décompte Disappears in: MM:SS, bouton fermer rouge [X] en haut à droite.
- **Organisation des articles (4 rangées)** :
  - Items en **Gemmes** (ex: *Valora [Gold]* à 75 gemmes, *Luck Potion Lvl. 3* à 25 000 gemmes).
  - Items en **Cash** (ex: *Luck Potion Lvl. 2* à 2.5 Qa, *Meteorite Potion* à 11M, *Food Potion* à 50 Qa, *Honey Potion*, *Sinister Potion*).
  - Items d'habilités spéciales (ex: *Astral Thoughts*, *Emptiness*, *Hell Beast* avec boutons dédiés rouges).
- **Sécurité Robux** : Les boutons d'achat Robux verts fluo sont situés immédiatement à côté des boutons d'achat normaux. Les clics de la macro devront cibler exclusivement les boutons de gauche (Cash/Gemmes) avec des marges strictes.

---

## 5. Architecture de la Boucle Full-Automatique
`
[Pêche active & radar chat]
          │
          ▼  (Message 'Selene has Arrived!' détecté)
1. Pause de la pêche (arrêt des clics d'eau)
2. Trajet aller : Z (3s) + D (1s)
3. Interaction touche E (ouverture shop)
4. Achat sélectif des potions autorisées (0 clic Robux)
5. Clic sur [X] pour fermer l'interface
6. Trajet retour contre la butée : Q (1s) + S (3.5s)
7. Clic de relance dans l'eau
8. Reprise de la boucle normale
`
