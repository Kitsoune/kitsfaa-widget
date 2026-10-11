# ✦ Fish an Anime RNG - Release v3.2 (English Edition)

Welcome to **Fish an Anime RNG (FAA) Macro v3.2**, powered by AutoHotkey v2 with the signature **Nakano Nino Liquid Glass HUD**!

---

## 📦 Download Assets

* **[FAA-Macro-v3.2-Desktop.zip](FAA-Macro-v3.2-Desktop.zip)** - For standard desktop monitors (3-tick wheel scroll, Virtual Desktop B1 <-> B3 switching).
* **[FAA-Macro-v3.2-Laptop.zip](FAA-Macro-v3.2-Laptop.zip)** - For compact laptops running 24/7 dedicated to Roblox (2-tick stepped scroll, adaptive vertical ratios, foreground mode).

---

## 📋 Prerequisites & Requirements

Before running the macro, ensure you have:
1. **Operating System:** Windows 10 or 11 (64-bit).
2. **AutoHotkey v2:** Version 2.0 or newer.
   * **Direct Download:** [autohotkey.com](https://www.autohotkey.com/) (Download v2)
   * **Or via Terminal/PowerShell:** `winget install AutoHotkey.AutoHotkey`
*(Note: If AutoHotkey is missing, `START_MACRO.bat` will automatically offer to install it for you!)*

---

## 🌟 What's New in v3.2

### 🔄 100% Robux-Safe Auto-Rebirth
* **Automated Periodic Execution:** Automatically executes the Rebirth routine every hour (configurable `RebirthIntervalMinutes = 60` in `config.ini`).
* **Zero-Robux Physical Safety:** Clicks strictly on the green Cash `Rebirth!` button on the left (`X=0.356, Y=0.725`). The 2999 R$ button on the right is completely blocked from mouse movement.
* **Instant Manual Test:** Press **`F9`** anytime to test the full Rebirth opening, cash click, and modal closure.

### 🌙 Selective Selene's Store Auto-Buy
* **Exact Item Targeting:** Purchases **ONLY** the 4 essential potions from Selene's Store:
  1. `Luck Potion Lvl. 3` (Row 1, Col 1 - Gems)
  2. `Heaven's Collide Potion` (Row 1, Col 2 - Gems, scrolled)
  3. `Luck Potion Lvl. 2` (Row 1, Col 3 - Cash, scrolled)
  4. `Food Potion Lvl. 1` (Row 2, Col 2 - Cash, scrolled)
* **Zero Accidental Buys:** Completely skips ability cards (Astral Thoughts, Emptiness, Hell Beast) and other potions. Never clicks on Robux buttons.

### 🛠️ Interactive Launcher & One-Click Setup
* **Smart `START_MACRO.bat` Assistant:** If AutoHotkey v2 is not installed, the launcher now offers an interactive menu to install automatically via `winget` or open the official download page in one keypress.

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
| **`F9`** | Test Auto-Rebirth sequence immediately |

---

## 🚀 Quick Setup
1. Download either `FAA-Macro-v3.2-Desktop.zip` or `FAA-Macro-v3.2-Laptop.zip`.
2. Extract the archive into any folder.
3. Launch `START_MACRO.bat`.
4. Focus Roblox and press **`F1`** or click **`▶ START`** on the HUD!

