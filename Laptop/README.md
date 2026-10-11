# Fish an Anime RNG - Macro & HUD Widget (Laptop Edition v3.1)

Automation suite for the Roblox game **Fish an Anime RNG**, built with AutoHotkey v2 and featuring a *Liquid Glass* HUD inspired by Nakano Nino.
Optimized for **Laptops / Compact Screens** (2-tick stepped scroll, calibrated vertical Y-ratios, dedicated 24/7 foreground farming).

---

## 🚀 Laptop & 24/7 Farming Optimizations

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

---

## 🛠️ Configuration (`config.ini`)

- `[Hallows_Eve]`: Enable/disable OCR, character slots (Event = `2`, Normal = `1`, Rod = `1`).
- `[Rod_Ability]`: Enable/disable, ability key (`v`), cooldown (`481s`).
- `[Selene_Settings]`: 30-minute cycle and duration settings.
- `[Fishing_Watchdog]`: Re-arm interval (20s) and safety check.
- `[Shop_Settings]`: Shop mode (`Boosts` or `Selene`), delays, and scroll ticks (`ScrollWheelTicks = 2`).
- `[Virtual_Desktop]`: Keep `0` for dedicated laptop 24/7 foreground.
