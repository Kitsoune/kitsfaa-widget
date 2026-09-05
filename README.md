# Fish an Anime RNG — Macro & Widget HUD (Nino Vers.)

Suite d'automatisation pour le jeu Roblox **Fish an Anime RNG**, développée sous AutoHotkey v2 avec une interface HUD *Liquid Glass* inspirée de Nakano Nino.

Le projet combine la surveillance des événements et restocks du jeu avec une routine d'auto-fish native, la gestion des bureaux virtuels Windows et une séquence d'achat sécurisée en boutique (Cash & Gemmes uniquement, sans risque de clic Robux).

---

## Fonctionnalités

- **HUD Widget Always-On-Top :**
  - **Boost Shop :** Horloge synchronisée sur les tranches de 5 minutes du serveur (`:00`, `:05`, `:10`, etc.) avec offset configurable.
  - **Next Event :** Compte à rebours dynamique de 5 minutes pour les événements serveur, synchronisable instantanément en 1 clic ou via `F4`.
  - **Sélène :** Suivi indicatif du cycle d'apparition probabiliste (médiane statistique à 10 min et durée active de 4 min).
  - Design transparent déplaçable au clic, boutons épurés et rubans papillons latéraux.
- **Achat automatique en boutique (Boost Shop) :**
  - Navigation sur 2 écrans avec défilement molette contrôlé (3 crans).
  - Focus préalable sur l'interface pour empêcher la molette de zoomer la caméra Roblox.
  - Déplacement de curseur physique fluide (`SendMode Event`) et pause d'ancrage pour forcer le rafraîchissement des événements `MouseEnter`/`MouseLeave` de Roblox (élimine les clics fantômes sur les boutons précédents).
  - Coordonnées relatives adaptatives calculées par ratio (`cw * ratio`, `ch * ratio`) : compatible avec toutes les résolutions 16:9 sans pixels fixes.
  - Sécurisation stricte : clics limités à la moitié gauche des cartes (Zéro Robux).
- **Pêche continue & Anti-AFK :**
  - Déclenchement de l'auto-fish natif via un simple clic dans l'eau sans manipulation d'inventaire (la canne reste équipée).
  - Saut anti-déconnexion régulier (toutes les 3 minutes par défaut).
  - Calibrage du point d'eau à la volée via la touche `F8`.
- **Compatibilité Bureaux Virtuels Windows :**
  - Permet de travailler sur le Bureau 1 pendant que Roblox tourne sur le Bureau 3.
  - Basculement automatique lors des achats du restock, puis retour immédiat sur votre bureau de travail.
  - Désactivable via `config.ini` pour le farm nocturne ou l'usage sur PC portable.

---

## Raccourcis Clavier

| Raccourci | Action | Description |
| :--- | :--- | :--- |
| **`F1`** | **Démarrer / Pause** | Active ou suspend la macro (identique au clic sur `▶ DÉMARRER`). |
| **`F2`** | **Quitter** | Ferme immédiatement le script et le widget. |
| **`F3`** | **Offset Shop** | Ajuste le décalage en secondes du Boost Shop par rapport à la minute pile. |
| **`F4`** | **Sync Event** | Réinitialise le timer `NEXT EVENT` à `05:00` (ou clic direct sur le timer). |
| **`F5`** | **Test Shop** | Exécute la routine complète d'achat du Boost Shop pour tester les coordonnées. |
| **`F8`** | **Calibrer Eau** | Cliquez dans l'eau pour enregistrer vos coordonnées de pêche dans `config.ini`. |

---

## Installation & Lancement

### Prérequis
- Windows 10 ou 11
- [AutoHotkey v2](https://www.autohotkey.com/) (version 2.0+)

### Démarrage
1. Clonez ou téléchargez le dépôt :
   ```bash
   git clone https://github.com/Kitsoune/kitsfaa-widget.git
   ```
2. Double-cliquez sur **`LANCER_MACRO.bat`** (ou lancez `FAA_Macro.ahk`).
3. Placez votre personnage dans l'eau devant le comptoir du **Boosts Store** et équipez votre canne à pêche.
4. Appuyez sur **`F1`** (ou cliquez sur **`▶ DÉMARRER`**) pour lancer la session.

---

## Configuration (`config.ini`)

Tous les paramètres sont modifiables directement dans le fichier `config.ini` sans toucher au code source :

```ini
[Potions_Ligne1]
; Potions Cash (Écran 1) : 1 = Acheter, 0 = Ignorer
Buy_Cash_Lvl1 = 1
Buy_Cash_Lvl2 = 1
Buy_Cash_Lvl3 = 1

[Potions_Ligne2]
; Potions Gems (Écran 2 - Ligne 1)
Buy_Gems_Lvl1 = 1
Buy_Gems_Lvl2 = 1
Buy_Gems_Lvl3 = 1

[Potions_Ligne3]
; Potions Spéciales (Écran 2 - Ligne 2)
Buy_Mutation_Lvl1 = 1
Buy_FastCatch_Lvl1 = 1
Buy_Luck_Lvl1 = 1

[Shop_Settings]
; Décalage en secondes après la minute fixe (:00, :05...)
ServerClockOffsetSeconds = 7
; Temps d'attente pour affichage complet du shop (en ms)
ShopOpenDelayMs = 4000
; Nombre de clics par bouton et intervalle entre chaque clic
ClicksPerButton = 3
ClickIntervalMs = 700
; Crans de molette pour descendre à l'écran 2
ScrollWheelTicks = 3

[Virtual_Desktop]
; 1 = Basculer vers le Bureau 3 pour acheter, 0 = Désactivé (mode nuit / PC portable)
AutoSwitchDesktop = 1
DesktopStepsRight = 2
DesktopSwitchDelayMs = 350

[Fishing_Settings]
; Ratios de position du clic dans l'eau (recalibrable avec F8)
WaterRatioX = 0.324
WaterRatioY = 0.556
AntiAfkIntervalSeconds = 180

[Sound_Settings]
; Bips sonores lors des actions (1 = Activé, 0 = Muet)
EnableSoundBeep = 0

[Event_Settings]
; Décalage éventuel pour les événements serveur (en secondes)
EventClockOffsetSeconds = 0
```

---

## Structure du Projet

```
kitsfaa/
├── assets/
│   ├── widget_full.bmp        # Texture de fond du widget HUD (TransColor)
│   └── widget_full_preview.png # Aperçu visuel du HUD
├── config.ini                 # Fichier de configuration utilisateur
├── FAA_Macro.ahk              # Script principal AutoHotkey v2
├── generate_assets.py         # Générateur procédural des assets graphiques
├── LANCER_MACRO.bat           # Lanceur Windows automatique
├── SELENE_SPECS.md            # Spécifications techniques pour l'automatisation de Sélène
├── .gitignore                 # Exclusion des fichiers temporaires
└── README.md                  # Documentation
```

---

## Licence

Projet personnel développé pour la communauté *Fish an Anime RNG*. Libre d'utilisation et de modification.
