# ✦ Fish an Anime RNG · Release v4.5

## 🧛 Hallows Eve: the event character is really put away
* New setup step **⚙ SETUP → 🧛 Event character slot**: take the event character out, aim at its hotbar slot and press ENTER. The macro learns how the slot looks when the character is held or away.
* Once recorded, the macro looks at the hotbar before and after each key press. If a press was lost (Roblox not in front, lag), it presses again, up to 3 times. It keeps checking for 1 minute after the event ends, so the character can no longer stay out.
* Without this step, the macro now makes sure Roblox is in front before pressing, and writes it to `macro.log` when it is not.

## 🔧 Options window
* **⚙ SETUP → 🔧 Options & potions to buy**: turn auto rebirth, Hallows Eve, the rod ability, the fishing watchdog, the update check and sound beeps on or off with one click.
* Pick which Boost and Selene potions to buy in the same window. No need to edit `config.ini` anymore.

## ⚠️ Disclaimer
* On first launch, the macro asks you to accept that you use it at your own risk. Read it again any time with the **ⓘ** button on the widget.

## 📦 Download

**[FAA-Macro-v4.5.zip](FAA-Macro-v4.5.zip)**: unzip anywhere, then double-click `START_MACRO.bat` (it installs AutoHotkey v2 if needed). If you already have v4.4, the macro offers to update itself on launch.
