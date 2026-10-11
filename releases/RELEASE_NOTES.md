# ✦ Fish an Anime RNG - Release v3.3 (English Edition)

Welcome to **Fish an Anime RNG (FAA) Macro v3.3**, powered by AutoHotkey v2 with the signature **Nakano Nino Liquid Glass HUD**!

---

## 📦 Download Assets

* **[FAA-Macro-v3.3-Desktop.zip](FAA-Macro-v3.3-Desktop.zip)** - For standard desktop monitors (3-tick wheel scroll, Virtual Desktop B1 <-> B3 switching).
* **[FAA-Macro-v3.3-Laptop.zip](FAA-Macro-v3.3-Laptop.zip)** - For compact laptops running 24/7 dedicated to Roblox (2-tick stepped scroll, adaptive vertical ratios, foreground mode).

---

## 📋 Prerequisites & Requirements

Before running the macro, ensure you have:
1. **Operating System:** Windows 10 or 11 (64-bit).
2. **AutoHotkey v2:** Version 2.0 or newer.
   * **Direct Download:** [autohotkey.com](https://www.autohotkey.com/) (Download v2)
   * **Or via Terminal/PowerShell:** `winget install AutoHotkey.AutoHotkey`
*(Note: If AutoHotkey is missing, `START_MACRO.bat` will automatically offer to install it for you!)*

---

## 🌟 What's New in v3.3

### 🎃 Hallows Eve OCR Engine v2 & Wiki Exclusion Matrix
* **Zero False Positives:** Multiple Roblox events (e.g. *Heaven's Collide*, *Solar*, *Blizzard*) share the *"turn Held Characters"* mechanic. The OCR engine now strictly excludes all 22 other official game events (from the Fish an Anime RNG wiki) to ensure it only activates during a genuine Hallows Eve.
* **Strict Title & Dracula Mutation Matching:** The macro never matches generic words like `eve` alone (preventing conflicts with `Event Duration`), and requires either the explicit `HALLOWS` title or the unique `DRACULA` mutation.
* **Seamless Hotbar Key `é` (Slot 2):** Equips the event character immediately using the native hotbar key `é` without interfering with ongoing fishing casts.

### 🌙 Selene Secret Shop Pixel-Perfect Calibration
* **Exact Button Center Coordinates:** Recalibrated click targets to match the exact center of buy buttons:
  1. `Luck Potion Lvl. 3` (`X=0.274, Y=0.470` - Gems, before scroll)
  2. `Heaven's Collide Potion` (`X=0.450, Y=0.448` - Gems, after scroll)
  3. `Luck Potion Lvl. 2` (`X=0.635, Y=0.448` - Cash, after scroll)
  4. `Food Potion Lvl. 1` (`X=0.450, Y=0.680` - Cash, after scroll)
* **Accurate Modal Close:** Clicks the red `[X]` exit button at `X=0.788, Y=0.190`.
* **Zero Accidental Buys:** Completely skips ability cards (Astral Thoughts, Emptiness, Hell Beast) and other potions. Never clicks on Robux buttons.

### 🎣 Seamless Continuous Fishing
* **Watchdog Removed:** Completely removed safety watchdog timeouts that could previously cause the character to stop fishing after a few seconds.

### 🔄 100% Robux-Safe Auto-Rebirth
* **Automated Periodic Execution:** Automatically executes the Rebirth routine every hour (configurable `RebirthIntervalMinutes = 60` in `config.ini`).
* **Zero-Robux Physical Safety:** Clicks strictly on the green Cash `Rebirth!` button on the left (`X=0.356, Y=0.725`). The 2999 R$ button on the right is completely blocked from mouse movement.
* **Instant Manual Test:** Press **`F9`** anytime to test the full Rebirth opening, cash click, and modal closure.

### 🛠️ Interactive Launcher & One-Click Setup
* **Smart `START_MACRO.bat` Assistant:** Fixed batch script syntax to prevent terminal exit crashes. Offers an interactive menu to install AutoHotkey v2 automatically via `winget` or open the official download page in one keypress.

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
1. Download either `FAA-Macro-v3.3-Desktop.zip` or `FAA-Macro-v3.3-Laptop.zip`.
2. Extract the archive into any folder.
3. Launch `START_MACRO.bat`.
4. Focus Roblox and press **`F1`** or click **`▶ START`** on the HUD!
