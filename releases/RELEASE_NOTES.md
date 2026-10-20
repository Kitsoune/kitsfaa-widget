# ✦ Fish an Anime RNG · Release v4.4

## 🎨 v4.4: Themes, update check, safer shop opening
* **Widget themes**: Nino Nakano (default), **Celestia Ludenberg** (jet-black twin drills, white ribbons, lace headdress, card suits) and **Tokyo Ghoul · Kaneki** (his white hair, eyepatch and kakugan faded into the header, red kagune, spider lilies growing from the bottom, checkerboard floor). Pick one in **⚙ SETUP → 🎨 Widget theme**, the widget restarts with it.
* **Update check**: on launch, the macro checks GitHub for a newer release. It offers to download and install it, keeps your `config.ini` and restarts.
* **Shop opening**: the macro no longer clicks inside the shop after opening it (that click could land on a card and open a Robux purchase window, mostly on Luck Potion Lvl 3). It only hovers the shop to scroll it.

## 🌙 v4.3: Selene after midnight
* Selene's shop is opened again automatically after midnight. Before, the macro skipped every Selene visit after 00:00 until it was restarted (F5 still worked).

## 🌙 v4.2: Safer Selene shop
* Before every Selene purchase, the macro reads the card under the button. A character, an ability or an **OUT OF STOCK** card is never clicked.
* When Selene adds a character in the first slot, every potion position is shifted by one slot automatically.
* `macro.log` lists what was clicked, the stock before → after, warnings, and a summary per Selene visit.
* Hallows Eve: no more false detection during Slime Rain (the Dracula description is checked first, other event names block a fuzzy "hallow" match). **Lucky River** added to the other events.

## 🎃 v4.1: Hallows Eve fixes
* The event timer ("Event Duration") is read by OCR: the event character is never put away before it runs out, even if the banner is briefly unreadable. The widget shows the time left.
* The macro remembers whether the event character is out and only presses é when needed (no more character left out after the event, or put away when pressing START mid-event).
* Every out / away move is written to `macro.log`.

## 📦 Download

**[FAA-Macro-v4.4.zip](FAA-Macro-v4.4.zip)**: unzip anywhere, then double-click `START_MACRO.bat` (it installs AutoHotkey v2 if needed).

## 🌟 New in v4.0

One single version for every screen. The separate Desktop and Laptop editions are gone.

### 🎯 Record your own routine (works on any screen)
* A **Setup** window opens on first launch (and any time with **⚙ SETUP** / **F4**).
* Aim at each button and press **ENTER**: nothing is clicked while you aim. **↓ / ↑** scroll the shop exactly like the macro does when farming.
* Covers the water spot, Click to Fish, Auto Fish, the rod ability button, the Boost shop, Selene's shop and Rebirth. Each part can be redone on its own.

### 🎣 Fishing watchdog
* If the character stops fishing (God / Omniscient catch…), the macro clicks **Click to Fish!**, only when its recorded green colour is really there (the grey **Fishing.** button at the same spot is never clicked).
* If **Auto Fish** turns grey, it is turned back on.
* Nothing is clicked after a shop or a rebirth: fishing keeps going while a shop is open.

### 🛒 More reliable shops
* The macro waits until the shop is really open before scrolling (no more camera zoom when the shop is slow to open).
* Restock purchases no longer get skipped when a timer tick is missed.
* Selene: two passes per visit (+30 s and +2:30, configurable with `BuyAtSeconds`).
* The widget becomes click-through while the macro clicks, so it never hides a game button.

### ⚡ Rod ability
* Real-time cooldown that keeps running during shops and pauses, like in game.
* Optional ready-colour check of the ability button: V is pressed as soon as it turns green.
* Cooldown editable from the Setup window.

### 🎃 Hallows Eve OCR
* Tolerates common OCR misreads (`HA1LOWS`, `DRAC ULA`…); the Dracula description wins over the exclusion list.

### 🦋 New Nino HUD
* Redrawn widget: coral-pink tones and Nino's black and teal butterfly hairpins. Its position is remembered.
* **F1** works again as an emergency stop during a shop or a rebirth.
* `macro.log` records every shop, purchase and watchdog action.

## ⌨️ Hotkeys

**F1** Start / Pause / Stop · **F2** Quit · **F3** Shop offset · **F4** Setup · **F5** Shop now · **F6** Test OCR · **F7** Event zone · **F8** Water spot · **F9** Rebirth now
