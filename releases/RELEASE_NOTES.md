# ✦ Fish an Anime RNG - Release v4.1

## 🎃 v4.1 - Hallows Eve fixes
* The event timer ("Event Duration") is read by OCR: the event character is never put away before it runs out, even if the banner is briefly unreadable. The widget shows the time left.
* The macro remembers whether the event character is out and only presses é when needed (no more character left out after the event, or put away when pressing START mid-event).
* Every out / away move is written to `macro.log`.

## 📦 Download

**[FAA-Macro-v4.1.zip](FAA-Macro-v4.1.zip)** - unzip anywhere, then double-click `START_MACRO.bat` (it installs AutoHotkey v2 if needed).

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
