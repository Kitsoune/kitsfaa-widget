# Fish an Anime RNG - Macro & HUD Widget (Laptop Edition v3.2)

Automation suite for the Roblox game **Fish an Anime RNG**, built with AutoHotkey v2 and featuring a *Liquid Glass* HUD inspired by Nakano Nino.
Optimized for **Laptops / Compact Screens** (2-tick stepped scroll, calibrated vertical Y-ratios, dedicated 24/7 foreground farming).

---

## 📋 Prerequisites & Requirements

- **Windows 10 / 11** (64-bit recommended)
- **AutoHotkey v2** (v2.0 or newer):
  - **Quick Install:** Simply double-click `START_MACRO.bat` - if AutoHotkey v2 is not detected, an interactive assistant will offer to install it automatically via `winget` or open the official download page.
  - **Manual Install:** Run in PowerShell/CMD:
    ```cmd
    winget install AutoHotkey.AutoHotkey
    ```
    Or download directly from [AutoHotkey Official Website](https://www.autohotkey.com/v2/).
- **Roblox Client** (Windowed or Fullscreen)

---

## 🚀 Laptop & 24/7 Farming Optimizations

- **✨ 100% Robux-Safe Auto-Rebirth:**
  - Automated hourly rebirth routine (`RebirthIntervalMinutes = 60`) or on-demand via **`F9`**.
  - Opens sidebar Rebirth menu, strictly clicks the **green Cash button**, and **never** clicks any Robux button.
  - Closes the modal cleanly and resumes fishing immediately.

- **🌙 Selene's Store Selective Auto-Buy:**
  - When Selene is active and shop mode is set to Selene, automatically purchases **only** the 4 essential potions:
    - `Luck Potion Lvl. 3` (Gems)
    - `Heaven's Collide Potion` (Gems)
    - `Luck Potion Lvl. 2` (Cash)
    - `Food Potion Lvl. 1` (Cash)
  - Clicks 3 times per potion, completely ignores ability cards, and strictly avoids any Robux buttons.

- **🎣 Emergency Auto Fish Fallback & Recovery:**
  - **Pixel State Check:** Monitors the in-game `Auto Fish` button. Clicks it **only** if it turns grey (inactive), and never touches it while green (active).
  - **Waiting for Catch Recovery:** Inspects catch status; if fishing is stopped, automatically re-arms rod (Slot `1`) and casts water.

- **💻 Compact Screen Calibration:**
  - Stepped shop scrolling (2 wheel ticks) to prevent buttons from clipping off the screen edge.
  - Dedicated 4-step buy sequence with calibrated button Y-ratios.
  - Virtual desktop switching disabled by default (`AutoSwitchDesktop = 0`), as Roblox runs full-screen 24/7 on the dedicated laptop.

- **🎃 Automatic Hallows Eve OCR Detection:**
  - Native OCR scanning via `Windows.Media.Ocr`.
  - Multi-pass high-contrast binarization and automatic top margin expansion (+35%) to capture stylized event titles.
  - Automatically equips the event character (Slot `2`) whenever Hallows Eve is active.
  - Immediately restores normal character state once Hallows Eve ends.
  - Interactive calibration with **`F7`** (click & drag) and OCR testing with **`F6`**.

- **🌙 Fixed 30-Minute Selene Timer:**
  - Synchronized with the fixed 30-minute spawn cycle (`:00` and `:30`).
  - Displays `ACTIVE 05:00` while Selene is present, then counts down `AWAY 25:00`.

- **⚡ Rod Ability Auto-Trigger:**
  - Automatically triggers rod ability via Key **`V`**.
  - **Configurable Cooldown:** Default set to **8m 01s** (`481` seconds in `config.ini`).
  - **Real-Time HUD Countdown:** Displays remaining time under `ABILITY`.
  - Manual instant trigger available anytime by clicking the timer directly.

- **🛡️ 24/7 Overnight Fishing Watchdog:**
  - Continuously re-equips fishing rod (Slot `1`) and clicks water every 20 seconds to guarantee uninterrupted overnight farming.

- **🏬 Shop Mode Selector:**
  - Interactive widget button: toggle between `[ MODE : BOOST SHOP ]` and `[ MODE : SELENE SHOP ]`.

---

## ⌨️ Keyboard Hotkeys

| Hotkey | Action | Description |
| :--- | :--- | :--- |
| **`F1`** | **Start / Pause** | Toggle macro execution (or click `▶ START`). |
| **`F2`** | **Exit** | Immediately closes the script and widget. |
| **`F3`** | **Shop Offset** | Adjust clock offset in seconds for Boost Shop restock. |
| **`F5`** | **Test Shop** | Execute the complete auto-buy routine immediately. |
| **`F6`** | **Test OCR** | Display text currently recognized in the event box. |
| **`F7`** | **Calibrate Event Box** | Click & drag rectangle to set event bounding box. |
| **`F8`** | **Calibrate Water** | **1 click** on water spot to save casting coordinates in `config.ini`. |
| **`F9`** | **Auto-Rebirth** | Trigger 100% Robux-safe Rebirth sequence manually. |

---

## 🛠️ Configuration (`config.ini`)

- `[Auto_Rebirth]`: Enable/disable hourly rebirth (`EnableAutoRebirth = 1`, `RebirthIntervalMinutes = 60`).
- `[Selene_Potions]`: Individual toggles for Luck 3, Heaven's Collide, Luck 2, and Food 1.
- `[Fishing_Watchdog]`: Emergency Auto Fish click (`AutoFishFallback = 1`) and catch recovery.
- `[Hallows_Eve]`: Enable/disable OCR, character slots (Event = `2`, Normal = `1`, Rod = `1`).
- `[Rod_Ability]`: Enable/disable, ability key (`v`), cooldown (`481s`).
- `[Selene_Settings]`: 30-minute cycle and duration settings.
- `[Shop_Settings]`: Shop mode (`Boosts` or `Selene`), delays, and scroll ticks (`ScrollWheelTicks = 2`).
- `[Virtual_Desktop]`: Keep `0` for dedicated laptop 24/7 foreground.

