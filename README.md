# Fish an Anime RNG (FAA) - Macro & HUD Widget (Nino Edition v3.2)

This repository contains two optimized editions of the AutoHotkey v2 macro for the Roblox game **Fish an Anime RNG**:

---

## 📁 Available Releases

### 1. **[Desktop/](Desktop/)**
* Tailored for high-resolution wide desktop screens.
* 3-tick wheel scroll for standard full-height shop interface.
* Automatic Windows Virtual Desktop switching (Desktop 1 <-> Desktop 3).

### 2. **[Laptop/](Laptop/)**
* Tailored for compact laptop screens running **24/7 dedicated to Roblox**.
* 2-tick stepped wheel scroll to prevent button clipping.
* Adaptive vertical Y-ratios for Cash, Gems, and Special potions.
* Virtual desktop switching disabled by default (`AutoSwitchDesktop = 0`, Roblox foreground 24/7).

---

## 📋 Prerequisites & Requirements

- **Windows 10 / 11** (64-bit recommended)
- **AutoHotkey v2** (v2.0 or newer):
  - **Automated setup:** Double-clicking `START_MACRO.bat` detects whether AutoHotkey v2 is installed. If not, it launches an assisted installer via `winget` or directs you to the official download page.
  - **Manual command:** Run in PowerShell or CMD:
    ```cmd
    winget install AutoHotkey.AutoHotkey
    ```
- **Roblox Client** (Windowed or Fullscreen)

---

## 🌟 Key Features

* **✨ 100% Robux-Safe Auto-Rebirth:**
  * Fully automated rebirth routine triggered periodically (default: every 60 min) or manually via **`F9`**.
  * Opens the rebirth modal, strictly targets the **green Cash button**, and **never** clicks any Robux button.
  * Closes the window cleanly and resumes fishing immediately.
* **🌙 Selene's Store Selective Auto-Buy:**
  * When Selene arrives (spawn every 30 mins) and shop mode is set to Selene, automatically buys **only** the 4 selected items:
    * `Luck Potion Lvl. 3` (Gems)
    * `Heaven's Collide Potion` (Gems)
    * `Luck Potion Lvl. 2` (Cash)
    * `Food Potion Lvl. 1` (Cash)
* **🎃 Hallows Eve OCR Detection (Native `Windows.Media.Ocr`):**
  * Automatic banner text detection without heavy external dependencies.
  * Multi-pass high-contrast binarization and automatic top margin expansion (+35%) to capture stylized event titles.
  * Auto-equips event character (Slot `2`) during Hallows Eve.
  * Automatically switches back to normal character state outside event.
  * Calibrate event bounding box with sleek click & drag using **`F7`**; test with **`F6`**.
* **🌙 Fixed 30-Minute Selene Timer:**
  * Synchronized with the fixed 30-minute cycle (`:00` and `:30`).
  * Live status countdown: `ACTIVE 05:00` / `AWAY 25:00`.
* **⚡ Rod Ability Auto-Trigger:**
  * Auto-triggers rod ability (Key **`V`**) on startup and after cooldown (default `481s` = 8m 01s).
  * Real-time countdown on HUD with click-to-trigger support.
* **🏬 Shop Mode Switcher:**
  * Toggle between `[ MODE : BOOST SHOP ]` and `[ MODE : SELENE SHOP ]` directly on the widget.
* **🦋 Nakano Nino Liquid Glass HUD:**
  * Draggable transparent overlay with butterfly pins, real-time counters, and controls.

---

## ⌨️ Global Hotkeys

| Hotkey | Action | Description |
| :--- | :--- | :--- |
| **`F1`** | **Start / Pause** | Toggle macro execution (or click `▶ START`). |
| **`F2`** | **Exit** | Immediately closes macro and widget. |
| **`F3`** | **Server Offset** | Adjust shop clock offset in seconds. |
| **`F5`** | **Test Shop** | Run the complete shop purchasing routine. |
| **`F6`** | **Test OCR** | Display current text recognized by OCR in event box. |
| **`F7`** | **Calibrate Event Box** | Click & drag rectangle to set event bounding box. |
| **`F8`** | **Calibrate Water** | **1 click** on water spot to set fishing target coordinates. |
| **`F9`** | **Auto-Rebirth** | Trigger 100% Robux-safe Rebirth sequence manually. |

---

## 🚀 How to Run

1. Open your machine folder:
   * **Desktop:** run `Desktop\START_MACRO.bat`
   * **Laptop:** run `Laptop\START_MACRO.bat`
2. Roblox will be focused, the HUD widget appears in top-right corner, and farming begins!


---

## 📜 Credits & License

* **Developer:** **Kitsoune** (Roblox: `Kitsouwune`)
* **Organization:** **KITS Progress Inc.**
* **License:** This project is licensed under the [MIT License](LICENSE). Feel free to use, modify, and distribute with proper attribution.

