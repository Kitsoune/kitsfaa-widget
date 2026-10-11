# Fish an Anime RNG - Macro & HUD Widget (Desktop Edition v3.1)

Automation suite for the Roblox game **Fish an Anime RNG**, built with AutoHotkey v2 and featuring a *Liquid Glass* HUD inspired by Nakano Nino.
Optimized for **Desktop / Wide Screens** (standard 3-tick wheel scroll, Virtual Desktop switching).

---

## 🚀 Features & Capabilities

- **🎃 Automatic Hallows Eve OCR Detection:**
  - Uses native Windows 10/11 UWP API (`Windows.Media.Ocr`). Zero third-party tools required.
  - Multi-pass high-contrast binarization and automatic top margin expansion (+35%) to capture stylized event titles.
  - Continuously monitors the event banner on top of the screen.
  - **Auto Character Swap:** Equips the event character (Slot `2`) whenever Hallows Eve is active to maximize mutations and luck.
  - **Fail-Safe Protection:** Automatically switches back to normal character state outside events.
  - Interactive calibration with **`F7`** (click & drag) and real-time OCR testing with **`F6`**.

- **🌙 Fixed 30-Minute Selene Timer:**
  - Synchronized with the fixed 30-minute spawn cycle (`:00` and `:30`).
  - Displays `ACTIVE 05:00` while Selene is present, then counts down `AWAY 25:00`.

- **⚡ Rod Ability Auto-Trigger:**
  - Automatically triggers rod ability via Key **`V`**.
  - **Configurable Cooldown:** Default set to **8m 01s** (`481` seconds in `config.ini`).
  - **Real-Time HUD Countdown:** Displays remaining time under `ABILITY`.
  - Manual instant trigger available anytime by clicking the timer directly.

- **🛡️ 24/7 Fishing Watchdog:**
  - Continuous monitoring: re-equips fishing rod (Slot `1`) and clicks water if interrupted or delayed by server lag.

- **🏬 Shop Mode Selector:**
  - Interactive widget button: toggle between `[ MODE : BOOST SHOP ]` and `[ MODE : SELENE SHOP ]`.

- **🖥️ Windows Virtual Desktop Switching:**
  - Seamlessly switches to Roblox desktop (Desktop 1 -> Desktop 3) to execute buy sequences, then returns to your work desktop.

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
- `[Fishing_Watchdog]`: Re-arm interval and safety check.
- `[Shop_Settings]`: Shop mode (`Boosts` or `Selene`), delays, and scroll ticks (`ScrollWheelTicks = 3`).
- `[Virtual_Desktop]`: Automatic desktop transitions (B1 -> B3).
