# ✦ Fish an Anime RNG - Release v3.0 (English Edition)

Welcome to **Fish an Anime RNG (FAA) Macro v3.0**, powered by AutoHotkey v2 with the signature **Nakano Nino Liquid Glass HUD**!

---

## 📦 Download Assets

* **[FAA-Macro-v3.0-Desktop.zip](FAA-Macro-v3.0-Desktop.zip)** - For standard desktop monitors (3-tick wheel scroll, Virtual Desktop B1 <-> B3 switching).
* **[FAA-Macro-v3.0-Laptop.zip](FAA-Macro-v3.0-Laptop.zip)** - For compact laptops running 24/7 dedicated to Roblox (2-tick stepped scroll, adaptive vertical ratios, foreground mode).

---

## 🌟 What's New in v3.0

### 🎃 Multi-Pass Adaptive OCR & Visual Detection for Hallows Eve
* Scans the event banner using native WinRT OCR with multi-pass adaptive scaling (1.0x standard, grayscale contrast filter, and 1.4x subtitle pass) plus optional image template matching.
* Identifies both the Hallows Eve title banner and its unique game mechanics without false positives from other weather or mutation events.
* **Auto Character Toggle:** Equips the clean character (Slot `2`) whenever Hallows Eve is detected, continuing fishing seamlessly while holding the character.
* **Fail-Safe Restoration:** Re-toggles Slot `2` outside the event to make the character disappear, without ever touching the fishing rod (Slot `1`).
* **Live Drag-and-Drop Calibration:** Press **`F7`** to draw a translucent purple selection rectangle over the event banner. Test anytime by clicking the HUD label.

### 🌙 Fixed 30-Minute Selene Timer
* Synchronized on the fixed 30-minute global cycle (`:00` and `:30`).
* Live HUD countdown: displays `ACTIVE 05:00` during presence, then counts down `AWAY 25:00`.

### ⚡ Rod Ability Auto-Trigger (Key V)
* Automatically activates rod ability upon launch and on every cooldown expiry (configurable, default `481s` = 8m 01s).
* Real-time HUD countdown under `ABILITY` with instant click-to-trigger support.

### 🏬 Shop Mode Selector
* Interactive HUD button allows one-click toggling between `[ MODE : BOOST SHOP ]` and `[ MODE : SELENE SHOP ]`.

### 🌐 100% English Localization & Codebase Cleanup
* All UI strings, popups, and documentation are standardized in English.
* Clean code with minimal essential comments reserved for user-configurable settings.

---

## ⌨️ Hotkeys Reference

| Key | Action |
| :--- | :--- |
| **`F1`** | Start / Pause macro execution |
| **`F2`** | Exit macro and close HUD |
| **`F3`** | Adjust shop restock clock offset |
| **`F4`** | Sync `NEXT EVENT` timer to `05:00` |
| **`F5`** | Test complete shop auto-buy sequence |
| **`F6`** | Test OCR text recognition in event box |
| **`F7`** | Calibrate event detection box (2 clicks) |
| **`F8`** | Calibrate water target coordinates (1 click) |

---

## 🚀 Quick Setup
1. Download either `FAA-Macro-v3.0-Desktop.zip` or `FAA-Macro-v3.0-Laptop.zip`.
2. Extract the archive into any folder.
3. Launch `START_MACRO.bat`.
4. Focus Roblox and press **`F1`** or click **`▶ START`** on the HUD!
