# ✦ Fish an Anime RNG - Release v3.1 (English Edition)

Welcome to **Fish an Anime RNG (FAA) Macro v3.1**, powered by AutoHotkey v2 with the signature **Nakano Nino Liquid Glass HUD**!

---

## 📦 Download Assets

* **[FAA-Macro-v3.1-Desktop.zip](FAA-Macro-v3.1-Desktop.zip)** - For standard desktop monitors (3-tick wheel scroll, Virtual Desktop B1 <-> B3 switching).
* **[FAA-Macro-v3.1-Laptop.zip](FAA-Macro-v3.1-Laptop.zip)** - For compact laptops running 24/7 dedicated to Roblox (2-tick stepped scroll, adaptive vertical ratios, foreground mode).

---

## 🌟 What's New in v3.1

### 🎃 High-Contrast Multi-Pass OCR & Smart Floating Title Capture
* **Smart Auto-Expansion (+35% Top Margin):** When calibrating the event box with **`F7`**, the macro automatically expands upward to capture stylized floating event titles (e.g. Lunar, Sweet Dreams, Hallows Eve) even if you only dragged across the colored banner.
* **Multi-Filter Recognition Passes:** Combines standard scaling (1.0x, 1.4x), high-contrast binarization (`monochrome: 150`), and color inversion (`invertcolors: 1`) to accurately decode bubble fonts on gradient backdrops.
* **Dual Event Validation:** Matches both stylized event title headers and the unique Hallows Eve mechanic descriptions (*"DRACULA"* / *"DEMONIC"* standalone mutations), guaranteeing 100% detection with zero false triggers.
* **Fail-Safe Character Management:** Automatically equips the clean character (Slot `2`) during Hallows Eve and restores normal state outside events, without interrupting the fishing rod.

### 🧹 Streamlined HUD & Hotkey Cleanup
* **Removed "NEXT EVENT":** In-game event spawns are irregularly timed, making fixed interval countdowns obsolete. The line and **`F4`** hotkey have been cleanly removed, giving the HUD balanced vertical spacing for Boost Shop, Selene, Rod Ability, and Hallows Eve.
* **Distraction-Free F7 Calibration:** Removed the intrusive text tooltip overlay during drag-and-drop bounding box selection. Only the sleek translucent purple selection frame is displayed.

### 🌙 Fixed 30-Minute Selene Timer & Rod Ability (Key V)
* Selene is synchronized with the fixed 30-minute global cycle (`:00` and `:30`).
* Automatic rod ability trigger with configurable cooldown (default `481s` = 8m 01s).

---

## ⌨️ Hotkeys Reference

| Key | Action |
| :--- | :--- |
| **`F1`** | Start / Pause macro execution |
| **`F2`** | Exit macro and close HUD |
| **`F3`** | Adjust shop restock clock offset |
| **`F5`** | Test complete shop auto-buy sequence |
| **`F6`** | Test OCR text recognition in event box |
| **`F7`** | Calibrate event detection box (click & drag) |
| **`F8`** | Calibrate water target coordinates (1 click) |

---

## 🚀 Quick Setup
1. Download either `FAA-Macro-v3.1-Desktop.zip` or `FAA-Macro-v3.1-Laptop.zip`.
2. Extract the archive into any folder.
3. Launch `START_MACRO.bat`.
4. Focus Roblox and press **`F1`** or click **`▶ START`** on the HUD!
