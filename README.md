# Fish an Anime RNG (FAA) - Macro & HUD Widget (Nino Edition v3.0)

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

## 🌟 Key Features

* **🎃 Hallows Eve OCR Detection (Native `Windows.Media.Ocr`):**
  * Automatic banner text detection without heavy external dependencies.
  * Auto-equips event character (Slot `2`) during Hallows Eve.
  * Automatically switches back to normal character (Slot `1`) outside event.
  * Calibrate event bounding box in 2 clicks with **`F7`**; test with **`F6`**.
* **🌙 Fixed 30-Minute Selene Timer:**
  * Synchronized with the fixed 30-minute cycle (`:00` and `:30`).
  * Live status countdown: `ACTIVE 05:00` / `AWAY 25:00`.
* **⚡ Rod Ability Auto-Trigger:**
  * Auto-triggers rod ability (Key **`V`**) on startup and after cooldown (default `481s` = 8m 01s).
  * Real-time countdown on HUD with click-to-trigger support.
* **🛡️ 24/7 Fishing Watchdog:**
  * Periodically re-equips fishing rod (Slot `1`) and clicks water to prevent AFK stops and network desync.
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
| **`F4`** | **Sync Event** | Reset `NEXT EVENT` timer to `05:00`. |
| **`F5`** | **Test Shop** | Run the complete shop purchasing routine. |
| **`F6`** | **Test OCR** | Display current text recognized by OCR in event box. |
| **`F7`** | **Calibrate Event Box** | **2 clicks** (top-left, bottom-right) to set event bounding box. |
| **`F8`** | **Calibrate Water** | **1 click** on water spot to set fishing target coordinates. |

---

## 🚀 How to Run

1. Open your machine folder:
   * **Desktop:** run `Desktop\START_MACRO.bat`
   * **Laptop:** run `Laptop\START_MACRO.bat`
2. Roblox will be focused, the HUD widget appears in top-right corner, and farming begins!
