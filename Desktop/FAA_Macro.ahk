#Requires AutoHotkey v2.0+
#SingleInstance Force

#include Lib\OCR.ahk

; --- User Configuration (Configurable via config.ini) ---
global IniPath := A_ScriptDir "\config.ini"
global IsRunning := false
global IsExecutingShop := false

global ShopMode := "Boosts"                ; "Boosts" or "Selene"
global ServerClockOffset := 7              ; Seconds after :00, :05 to trigger shop
global ShopCountdown := 0
global LastTriggeredMinute := -1

global EventCountdown := 300               ; 5-minute relative server event countdown
global EventClockOffset := 0

global SeleneCycleMinutes := 30            ; Fixed 30-minute Selene cycle (:00 and :30)
global SeleneDurationMinutes := 5
global SeleneClockOffsetSeconds := 0
global SeleneActive := false

; Potion purchases (1 = Buy, 0 = Skip)
global Buy_Cash1 := 1, Buy_Cash2 := 1, Buy_Cash3 := 1
global Buy_Gems1 := 1, Buy_Gems2 := 1, Buy_Gems3 := 1
global Buy_Mutation := 1, Buy_FastCatch := 1, Buy_Luck := 1

; Shop interaction settings
global ClicksPerButton := 3
global ClickIntervalMs := 700
global ShopOpenDelay := 4000
global ScrollTicks := 3                    ; 3 wheel ticks down on Desktop

; Virtual desktop switching (Desktop 1 <-> Desktop 3)
global AutoSwitchDesktop := 1
global DesktopStepsRight := 2
global DesktopSwitchDelayMs := 350

; Navigation
global WalkKey := "q"
global WalkDurationMs := 1600
global AdjustKey := "d"
global AdjustDurationMs := 350
global AutoRecoveryEnabled := 1

; Fishing & Anti-AFK
global WaterRatioX := 0.324
global WaterRatioY := 0.556
global FishClickIntervalMs := 1200
global AntiAfkInterval := 180
global LastAntiAfkTick := A_TickCount
global EnableSoundBeep := 0

; 24/7 Fishing Watchdog
global EnableWatchdog := 1
global WatchdogIntervalSeconds := 25
global RodSlotKey := 1
global LastWatchdogTick := A_TickCount

; Rod Ability (Key V)
global EnableRodAbility := 1
global RodAbilityKey := "v"
global RodAbilityCooldownSeconds := 481    ; Default: 8m 01s
global RodAbilityCountdown := 481

; Hallows Eve OCR & Character Swap
global EnableHallowsEve := 1
global EventCharSlot := 2                  ; Special event character slot
global NormalCharSlot := 1                 ; Standard character slot
global RodSlot := 1                        ; Fishing rod slot
global CheckIntervalSeconds := 4
global EventRatioX := 0.35
global EventRatioY := 0.04
global EventRatioW := 0.30
global EventRatioH := 0.12
global IsHallowsEveActive := false
global LastOcrCheckTick := 0

LoadConfig()

; --- Liquid Glass Widget HUD (Nakano Nino Theme) ---
global WidgetGui := Gui("-Caption +AlwaysOnTop +ToolWindow -DPIScale", "Fish an Anime RNG · KITS Progress Inc.")
WidgetGui.BackColor := "0x010101"

BgPath := A_ScriptDir "\assets\widget_full.bmp"
if FileExist(BgPath)
    WidgetGui.Add("Picture", "x0 y0 w390 h235", BgPath)

CX := 55

TitleCtrl := WidgetGui.Add("Text", "x" (CX+30) " y10 w220 h20 Center BackgroundTrans cE8B4E8", "✦ FISH AN ANIME RNG ✦")
TitleCtrl.SetFont("s10 bold", "Segoe UI")
VerCtrl := WidgetGui.Add("Text", "x" (CX+30) " y26 w220 h14 Center BackgroundTrans cB090BC", "KITS Progress Inc. · Desktop v3.0")
VerCtrl.SetFont("s7 bold", "Segoe UI")

CloseCtrl := WidgetGui.Add("Text", "x" (CX+252) " y10 w20 h20 Center BackgroundTrans cC490C4", "✕")
CloseCtrl.SetFont("s9 bold", "Segoe UI")
CloseCtrl.OnEvent("Click", (*) => ExitApp())

; Timers & HUD Elements
WidgetGui.Add("Text", "x" (CX+35) " y42 w85 h16 BackgroundTrans cB8A5C9", "BOOST SHOP")
global TxtShopTimer := WidgetGui.Add("Text", "x" (CX+130) " y40 w115 h18 Right BackgroundTrans c2EE5C0", "00:00")
TxtShopTimer.SetFont("s10 bold", "Consolas")

EventLabel := WidgetGui.Add("Text", "x" (CX+35) " y59 w85 h16 BackgroundTrans cB8A5C9", "NEXT EVENT")
EventLabel.OnEvent("Click", (*) => ResetEventTimer())
global TxtEventTimer := WidgetGui.Add("Text", "x" (CX+130) " y57 w115 h18 Right BackgroundTrans cFFD166", "05:00")
TxtEventTimer.SetFont("s10 bold", "Consolas")
TxtEventTimer.OnEvent("Click", (*) => ResetEventTimer())

WidgetGui.Add("Text", "x" (CX+35) " y76 w85 h16 BackgroundTrans cB8A5C9", "SELENE")
global TxtSeleneTimer := WidgetGui.Add("Text", "x" (CX+130) " y76 w115 h18 Right BackgroundTrans cC084FC", "AWAY · 30:00")
TxtSeleneTimer.SetFont("s9 bold", "Consolas")

WidgetGui.Add("Text", "x" (CX+35) " y93 w85 h16 BackgroundTrans cB8A5C9", "ABILITY")
global TxtRodAbilityTimer := WidgetGui.Add("Text", "x" (CX+130) " y93 w115 h18 Right BackgroundTrans c2EE5C0", "08:01")
TxtRodAbilityTimer.SetFont("s9 bold", "Consolas")
TxtRodAbilityTimer.OnEvent("Click", (*) => ManualTriggerRodAbility())

WidgetGui.Add("Text", "x" (CX+35) " y110 w85 h16 BackgroundTrans cB8A5C9", "HALLOWS EVE")
global TxtHallowsEveStatus := WidgetGui.Add("Text", "x" (CX+120) " y109 w125 h16 Right BackgroundTrans cB8A5C9", "● INACTIVE (Slot 1)")
TxtHallowsEveStatus.SetFont("s8 bold", "Segoe UI")
TxtHallowsEveStatus.OnEvent("Click", (*) => ManualOcrCheck())

global TxtStatus := WidgetGui.Add("Text", "x" (CX+30) " y127 w220 h17 Center BackgroundTrans cC490C4", "● PAUSED")
TxtStatus.SetFont("s9 bold", "Segoe UI")

global BtnToggle := WidgetGui.Add("Text", "x" (CX+30) " y146 w220 h28 Center 0x200 BackgroundTrans cFFFFFF", "▶  START")
BtnToggle.SetFont("s11 bold", "Segoe UI")
BtnToggle.OnEvent("Click", (*) => ToggleMacroState())

global BtnShopMode := WidgetGui.Add("Text", "x" (CX+30) " y176 w220 h17 Center BackgroundTrans c2EE5C0", "[ MODE : BOOST SHOP ]")
BtnShopMode.SetFont("s8 bold", "Segoe UI")
BtnShopMode.OnEvent("Click", (*) => ToggleShopMode())

FooterCtrl := WidgetGui.Add("Text", "x" (CX) " y198 w280 h16 Center BackgroundTrans c6A4E72", "F1 · Pause  |  F7 · Event Box  |  F8 · Water  |  F2 · Exit")
FooterCtrl.SetFont("s7", "Segoe UI")

OnMessage(0x0201, WM_LBUTTONDOWN)

WinWidth := 390
WinHeight := 235
PosX := A_ScreenWidth - WinWidth - 10
PosY := 30
WidgetGui.Show("x" PosX " y" PosY " w" WinWidth " h" WinHeight " NoActivate")

WinSetTransColor("010101", WidgetGui)
SetTimer(TimerSecondTick, 1000)

WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    if (hwnd = WidgetGui.Hwnd)
        PostMessage(0xA1, 2, 0, , "ahk_id " WidgetGui.Hwnd)
}

SwitchDesktopRight(steps := 2) {
    global DesktopSwitchDelayMs
    Loop steps {
        Send("^#{Right}")
        Sleep(DesktopSwitchDelayMs)
    }
}

SwitchDesktopLeft(steps := 2) {
    global DesktopSwitchDelayMs
    Loop steps {
        Send("^#{Left}")
        Sleep(DesktopSwitchDelayMs)
    }
}

PlayBeep(freq, dur) {
    global EnableSoundBeep
    if (EnableSoundBeep)
        SoundBeep(freq, dur)
}

; --- Periodic Timer Routine ---
TimerSecondTick() {
    global ShopCountdown, ServerClockOffset, LastTriggeredMinute
    global EventCountdown, TxtEventTimer
    global SeleneCycleMinutes, SeleneDurationMinutes, SeleneClockOffsetSeconds
    global SeleneActive, TxtSeleneTimer
    global IsRunning, IsExecutingShop, ShopMode
    global LastAntiAfkTick, AntiAfkInterval
    global LastWatchdogTick, WatchdogIntervalSeconds, EnableWatchdog
    global LastOcrCheckTick, CheckIntervalSeconds, EnableHallowsEve
    global EnableRodAbility, RodAbilityCountdown, RodAbilityCooldownSeconds, TxtRodAbilityTimer

    curMin := Integer(A_Min)
    curSec := Integer(A_Sec)

    ; Boost Shop cycle (:00, :05, :10...)
    minsPast := Mod(curMin, 5)
    rawRem := (4 - minsPast) * 60 + (60 - curSec)
    ShopCountdown := Mod(rawRem, 300)

    if (ShopMode == "Boosts" && minsPast == 0 && curSec == ServerClockOffset) {
        if (LastTriggeredMinute != curMin) {
            LastTriggeredMinute := curMin
            if (IsRunning && !IsExecutingShop)
                SetTimer(DoAutoBuySequence, -50)
        }
    }

    mins := Floor(ShopCountdown / 60)
    secs := Mod(ShopCountdown, 60)
    TxtShopTimer.Text := (mins < 10 ? "0" mins : mins) ":" (secs < 10 ? "0" secs : secs)

    if (ShopCountdown <= 10)
        TxtShopTimer.SetFont("cF85149 bold")
    else if (ShopCountdown <= 45)
        TxtShopTimer.SetFont("cFFB347 bold")
    else
        TxtShopTimer.SetFont("c2EE5C0 bold")

    ; Relative Server Event Countdown (5m)
    if (EventCountdown > 0)
        EventCountdown--
    else
        EventCountdown := 300

    evMins := Floor(EventCountdown / 60)
    evSecs := Mod(EventCountdown, 60)
    TxtEventTimer.Text := (evMins < 10 ? "0" evMins : evMins) ":" (evSecs < 10 ? "0" evSecs : evSecs)

    if (EventCountdown <= 10)
        TxtEventTimer.SetFont("cF85149 bold")
    else if (EventCountdown <= 45)
        TxtEventTimer.SetFont("cFFB347 bold")
    else
        TxtEventTimer.SetFont("cFFD166 bold")

    ; Fixed Selene Cycle (every 30 mins: :00 and :30)
    selMinsPast := Mod(curMin, 30)
    selRawSecs := selMinsPast * 60 + curSec - SeleneClockOffsetSeconds
    if (selRawSecs < 0)
        selRawSecs += 1800
    selCyclePos := Mod(selRawSecs, 1800)
    selDurationSecs := SeleneDurationMinutes * 60

    if (selCyclePos < selDurationSecs) {
        SeleneActive := true
        rem := selDurationSecs - selCyclePos
        m := Floor(rem / 60), s := Mod(rem, 60)
        TxtSeleneTimer.Text := "ACTIVE " (m < 10 ? "0" m : m) ":" (s < 10 ? "0" s : s)
        TxtSeleneTimer.SetFont("cE088FF bold")

        if (ShopMode == "Selene" && selCyclePos == ServerClockOffset) {
            if (LastTriggeredMinute != curMin) {
                LastTriggeredMinute := curMin
                if (IsRunning && !IsExecutingShop)
                    SetTimer(DoAutoBuySequence, -50)
            }
        }
    } else {
        SeleneActive := false
        rem := 1800 - selCyclePos
        m := Floor(rem / 60), s := Mod(rem, 60)
        TxtSeleneTimer.Text := "AWAY · " (m < 10 ? "0" m : m) ":" (s < 10 ? "0" s : s)
        TxtSeleneTimer.SetFont("cC084FC bold")
    }

    ; Rod Ability Cooldown (Key V)
    if (EnableRodAbility && IsRunning && !IsExecutingShop) {
        if (RodAbilityCountdown > 0) {
            RodAbilityCountdown--
            rMins := Floor(RodAbilityCountdown / 60)
            rSecs := Mod(RodAbilityCountdown, 60)
            TxtRodAbilityTimer.Text := (rMins < 10 ? "0" rMins : rMins) ":" (rSecs < 10 ? "0" rSecs : rSecs)
            if (RodAbilityCountdown <= 15)
                TxtRodAbilityTimer.SetFont("cFFD166 bold")
            else
                TxtRodAbilityTimer.SetFont("c2EE5C0 bold")
        } else {
            TriggerRodAbility()
            RodAbilityCountdown := RodAbilityCooldownSeconds
            TxtRodAbilityTimer.Text := "ABILITY !"
            TxtRodAbilityTimer.SetFont("cFF9D00 bold")
        }
    }

    ; Hallows Eve OCR Detection
    if (EnableHallowsEve && IsRunning && !IsExecutingShop) {
        nowTick := A_TickCount
        if ((nowTick - LastOcrCheckTick) >= (CheckIntervalSeconds * 1000)) {
            LastOcrCheckTick := nowTick
            CheckHallowsEveEvent()
        }
    }

    ; 24/7 Fishing Watchdog
    if (EnableWatchdog && IsRunning && !IsExecutingShop) {
        nowTick := A_TickCount
        if ((nowTick - LastWatchdogTick) >= (WatchdogIntervalSeconds * 1000)) {
            LastWatchdogTick := nowTick
            CheckFishingWatchdog()
        }
    }

    ; Anti-AFK Jump (Roblox disconnects after 20 minutes)
    if (IsRunning && !IsExecutingShop) {
        nowTick := A_TickCount
        if ((nowTick - LastAntiAfkTick) >= (AntiAfkInterval * 1000)) {
            LastAntiAfkTick := nowTick
            DoAntiAfkJump()
        }
    }
}

; --- Hallows Eve OCR Detection & Character Swap ---
CheckHallowsEveEvent() {
    global EnableHallowsEve, IsRunning, IsExecutingShop
    global EventRatioX, EventRatioY, EventRatioW, EventRatioH
    global EventCharSlot, NormalCharSlot, RodSlot
    global IsHallowsEveActive, TxtHallowsEveStatus

    if (!EnableHallowsEve || !IsRunning || IsExecutingShop)
        return

    RobloxPos := GetRobloxClientPos()
    hwnd := WinExist("ahk_exe RobloxPlayerBeta.exe") || WinExist("Roblox")
    if (!hwnd || RobloxPos.w < 200 || RobloxPos.h < 200)
        return

    WinGetClientPos(&winX, &winY, &cw, &ch, hwnd)
    screenX := winX + Integer(cw * EventRatioX)
    screenY := winY + Integer(ch * EventRatioY)
    screenW := Integer(cw * EventRatioW)
    screenH := Integer(ch * EventRatioH)

    if (screenW <= 10 || screenH <= 10)
        return

    try {
        ocrResult := OCR.FromRect(screenX, screenY, screenW, screenH, {scale: 2.0})
        detectedText := ocrResult ? ocrResult.Text : ""
        found := InStr(detectedText, "Hallows", false) || InStr(detectedText, "Hallow", false) || InStr(detectedText, "Eve", false)

        if (found) {
            if (!IsHallowsEveActive) {
                IsHallowsEveActive := true
                TxtHallowsEveStatus.Text := "🎃 ACTIVE (Slot " EventCharSlot ")"
                TxtHallowsEveStatus.SetFont("cFF9D00 bold")

                ActivateRoblox()
                Sleep(80)
                Send(String(EventCharSlot))
                Sleep(150)
                Send(String(RodSlot))
                Sleep(150)
                StartFishingClick()
            }
        } else {
            if (IsHallowsEveActive) {
                IsHallowsEveActive := false
                TxtHallowsEveStatus.Text := "● INACTIVE (Slot " NormalCharSlot ")"
                TxtHallowsEveStatus.SetFont("cB8A5C9")

                ; Switch back to normal character (never leave special character held outside event)
                ActivateRoblox()
                Sleep(80)
                Send(String(NormalCharSlot))
                Sleep(150)
                Send(String(RodSlot))
                Sleep(150)
                StartFishingClick()
            }
        }
    } catch {
    }
}

ManualOcrCheck() {
    global EventRatioX, EventRatioY, EventRatioW, EventRatioH
    RobloxPos := GetRobloxClientPos()
    hwnd := WinExist("ahk_exe RobloxPlayerBeta.exe") || WinExist("Roblox")
    if (!hwnd || RobloxPos.w < 200) {
        MsgBox("Roblox is not active for OCR check.", "OCR Check", "Icon!")
        return
    }

    WinGetClientPos(&winX, &winY, &cw, &ch, hwnd)
    screenX := winX + Integer(cw * EventRatioX)
    screenY := winY + Integer(ch * EventRatioY)
    screenW := Integer(cw * EventRatioW)
    screenH := Integer(ch * EventRatioH)

    testText := ""
    try {
        ocrRes := OCR.FromRect(screenX, screenY, screenW, screenH, {scale: 2.0})
        if (ocrRes)
            testText := ocrRes.Text
    }
    MsgBox("OCR text detected in event box (Scale 2x):`n`"" testText "`"`n`nCoordinates: X=" screenX " Y=" screenY " W=" screenW " H=" screenH, "OCR Event Check", "Iconi")
}

ToggleShopMode() {
    global ShopMode, BtnShopMode, IniPath
    if (ShopMode == "Boosts") {
        ShopMode := "Selene"
        BtnShopMode.Text := "[ MODE : SELENE SHOP ]"
        BtnShopMode.SetFont("cC084FC bold")
    } else {
        ShopMode := "Boosts"
        BtnShopMode.Text := "[ MODE : BOOST SHOP ]"
        BtnShopMode.SetFont("c2EE5C0 bold")
    }
    IniWrite(ShopMode, IniPath, "Shop_Settings", "ShopMode")
    PlayBeep(650, 100)
}

TriggerRodAbility() {
    global RodAbilityKey, IsRunning, IsExecutingShop
    if (!IsRunning || IsExecutingShop)
        return

    if WinActive("ahk_exe RobloxPlayerBeta.exe") || WinActive("Roblox") {
        Send("{" RodAbilityKey " down}")
        Sleep(80)
        Send("{" RodAbilityKey " up}")
    } else {
        ActivateRoblox()
        Sleep(120)
        Send("{" RodAbilityKey " down}")
        Sleep(80)
        Send("{" RodAbilityKey " up}")
    }
}

ManualTriggerRodAbility() {
    global RodAbilityCountdown, RodAbilityCooldownSeconds, RodAbilityKey, TxtRodAbilityTimer
    TriggerRodAbility()
    RodAbilityCountdown := RodAbilityCooldownSeconds
    TxtRodAbilityTimer.Text := "ACTIVATED !"
    TxtRodAbilityTimer.SetFont("cFF9D00 bold")
    PlayBeep(850, 100)
}

CheckFishingWatchdog() {
    global EnableWatchdog, IsRunning, IsExecutingShop, RodSlotKey
    if (!EnableWatchdog || !IsRunning || IsExecutingShop)
        return

    if WinActive("ahk_exe RobloxPlayerBeta.exe") || WinActive("Roblox") {
        Send(String(RodSlotKey))
        Sleep(100)
        StartFishingClick()
    }
}

StartFishingClick() {
    global WaterRatioX, WaterRatioY
    RobloxPos := GetRobloxClientPos()
    if (RobloxPos.w > 100) {
        CoordMode("Mouse", "Client")
        waterX := Integer(RobloxPos.w * WaterRatioX)
        waterY := Integer(RobloxPos.h * WaterRatioY)
        Click(waterX, waterY)
    }
}

DoAntiAfkJump() {
    global AutoSwitchDesktop, DesktopStepsRight, DesktopSwitchDelayMs
    global IsRunning, IsExecutingShop
    if (!IsRunning || IsExecutingShop)
        return

    didSwitch := false
    if (AutoSwitchDesktop && !WinActive("ahk_exe RobloxPlayerBeta.exe")) {
        SwitchDesktopRight(DesktopStepsRight)
        didSwitch := true
        Sleep(DesktopSwitchDelayMs)
    }

    ActivateRoblox()
    Sleep(250)
    Send("{Space down}")
    Sleep(100)
    Send("{Space up}")
    Sleep(250)

    if (didSwitch) {
        SwitchDesktopLeft(DesktopStepsRight)
        Sleep(DesktopSwitchDelayMs)
    }
}

BuyCashButton(bx, by) {
    global ClickIntervalMs, ClicksPerButton, IsRunning, IsExecutingShop
    if (!IsRunning || !IsExecutingShop)
        return

    CoordMode("Mouse", "Client")
    SendMode("Event")
    SetMouseDelay(2)
    MouseMove(bx, by, 3)
    Sleep(250)

    Loop ClicksPerButton {
        if (!IsRunning || !IsExecutingShop)
            return
        Click(bx, by, "Down")
        Sleep(60)
        Click(bx, by, "Up")
        if (!IsRunning || !IsExecutingShop)
            return
        Sleep(ClickIntervalMs)
    }
    Sleep(200)
}

; --- Auto-Buy Routine ---
DoAutoBuySequence() {
    global IsExecutingShop, ShopOpenDelay, ScrollTicks
    global Buy_Cash1, Buy_Cash2, Buy_Cash3
    global Buy_Gems1, Buy_Gems2, Buy_Gems3
    global Buy_Mutation, Buy_FastCatch, Buy_Luck
    global AutoSwitchDesktop, DesktopStepsRight, DesktopSwitchDelayMs
    global TxtStatus, IsRunning, ShopMode

    if (IsExecutingShop)
        return
    IsExecutingShop := true

    didSwitchDesktop := false
    if (AutoSwitchDesktop && !WinActive("ahk_exe RobloxPlayerBeta.exe")) {
        PlayBeep(650, 100)
        SwitchDesktopRight(DesktopStepsRight)
        didSwitchDesktop := true
        Sleep(DesktopSwitchDelayMs)
    }

    if (!IsRunning || !IsExecutingShop) {
        if (didSwitchDesktop)
            SwitchDesktopLeft(DesktopStepsRight)
        IsExecutingShop := false
        return
    }

    TxtStatus.Text := "WAKING ROBLOX..."
    TxtStatus.SetFont("cD29922 bold")

    ActivateRoblox()
    Sleep(800)

    if (!IsRunning || !IsExecutingShop) {
        if (didSwitchDesktop)
            SwitchDesktopLeft(DesktopStepsRight)
        IsExecutingShop := false
        return
    }

    RobloxPos := GetRobloxClientPos()
    if (RobloxPos.w < 200) {
        if (didSwitchDesktop)
            SwitchDesktopLeft(DesktopStepsRight)
        IsExecutingShop := false
        return
    }

    cw := RobloxPos.w
    ch := RobloxPos.h
    CoordMode("Mouse", "Client")

    scrollCenterX := Integer(cw * 0.50)
    scrollCenterY := Integer(ch * 0.38)
    SendMode("Event")
    SetMouseDelay(2)
    MouseMove(scrollCenterX, scrollCenterY, 3)
    Sleep(150)

    TxtStatus.Text := (ShopMode == "Selene" ? "SELENE SHOP..." : "OPENING SHOP...")
    Send("{e down}")
    Sleep(150)
    Send("{e up}")

    Sleep(ShopOpenDelay)

    if (!IsRunning || !IsExecutingShop) {
        if (didSwitchDesktop)
            SwitchDesktopLeft(DesktopStepsRight)
        IsExecutingShop := false
        return
    }

    Sleep(300)
    Click(scrollCenterX, scrollCenterY)
    Sleep(150)

    ; Reset scroll to top
    TxtStatus.Text := "RESETTING TOP..."
    Loop 8 {
        if (!IsRunning || !IsExecutingShop) {
            if (didSwitchDesktop)
                SwitchDesktopLeft(DesktopStepsRight)
            IsExecutingShop := false
            return
        }
        Send("{WheelUp}")
        Sleep(70)
    }
    Sleep(300)

    if (!IsRunning || !IsExecutingShop) {
        if (didSwitchDesktop)
            SwitchDesktopLeft(DesktopStepsRight)
        IsExecutingShop := false
        return
    }

    col1_CashX := Integer(cw * 0.2744)
    col2_CashX := Integer(cw * 0.4541)
    col3_CashX := Integer(cw * 0.6328)

    s1_row1_Y := Integer(ch * 0.4653)
    s2_row1_Y := Integer(ch * 0.4340)
    s2_row2_Y := Integer(ch * 0.6806)

    close_X := Integer(cw * 0.7871)
    close_Y := Integer(ch * 0.2049)

    ; Step 1: Cash Potions (Screen 1)
    if (Buy_Cash1 && IsRunning && IsExecutingShop) {
        TxtStatus.Text := "Cash Lvl 1..."
        BuyCashButton(col1_CashX, s1_row1_Y)
    }
    if (Buy_Cash2 && IsRunning && IsExecutingShop) {
        TxtStatus.Text := "Cash Lvl 2..."
        BuyCashButton(col2_CashX, s1_row1_Y)
    }
    if (Buy_Cash3 && IsRunning && IsExecutingShop) {
        TxtStatus.Text := "Cash Lvl 3..."
        BuyCashButton(col3_CashX, s1_row1_Y)
    }

    if (!IsRunning || !IsExecutingShop) {
        if (didSwitchDesktop)
            SwitchDesktopLeft(DesktopStepsRight)
        IsExecutingShop := false
        return
    }

    ; Step 2: Wheel Scroll (3 ticks on Desktop)
    needsScroll := (Buy_Gems1 || Buy_Gems2 || Buy_Gems3 || Buy_Mutation || Buy_FastCatch || Buy_Luck)
    if (needsScroll) {
        TxtStatus.Text := "SCROLLING DOWN..."
        SendMode("Event")
        SetMouseDelay(2)
        MouseMove(scrollCenterX, scrollCenterY, 3)
        Sleep(80)
        Click(scrollCenterX, scrollCenterY)
        Sleep(120)

        Loop ScrollTicks {
            if (!IsRunning || !IsExecutingShop) {
                if (didSwitchDesktop)
                    SwitchDesktopLeft(DesktopStepsRight)
                IsExecutingShop := false
                return
            }
            Send("{WheelDown}")
            Sleep(150)
        }
        Sleep(500)

        ; Step 3: Gems Potions
        if (Buy_Gems1 && IsRunning && IsExecutingShop) {
            TxtStatus.Text := "Gems Lvl 1..."
            BuyCashButton(col1_CashX, s2_row1_Y)
        }
        if (Buy_Gems2 && IsRunning && IsExecutingShop) {
            TxtStatus.Text := "Gems Lvl 2..."
            BuyCashButton(col2_CashX, s2_row1_Y)
        }
        if (Buy_Gems3 && IsRunning && IsExecutingShop) {
            TxtStatus.Text := "Gems Lvl 3..."
            BuyCashButton(col3_CashX, s2_row1_Y)
        }

        ; Step 4: Special Potions
        if (Buy_Mutation && IsRunning && IsExecutingShop) {
            TxtStatus.Text := "Mutation..."
            BuyCashButton(col1_CashX, s2_row2_Y)
        }
        if (Buy_FastCatch && IsRunning && IsExecutingShop) {
            TxtStatus.Text := "Fast Catch..."
            BuyCashButton(col2_CashX, s2_row2_Y)
        }
        if (Buy_Luck && IsRunning && IsExecutingShop) {
            TxtStatus.Text := "Luck Lvl 1..."
            BuyCashButton(col3_CashX, s2_row2_Y)
        }
    }

    ; Close Shop
    TxtStatus.Text := "CLOSING SHOP..."
    SendMode("Event")
    SetMouseDelay(2)
    MouseMove(close_X, close_Y, 3)
    Sleep(250)
    Click(close_X, close_Y)
    Sleep(600)

    ; Re-engage fishing
    if (IsRunning) {
        TxtStatus.Text := "● FISHING ACTIVE"
        TxtStatus.SetFont("c2EE5C0 bold")
        StartFishingClick()
    } else {
        TxtStatus.Text := "● PAUSED"
        TxtStatus.SetFont("cC490C4 bold")
    }

    if (didSwitchDesktop)
        SwitchDesktopLeft(DesktopStepsRight)

    IsExecutingShop := false
}

; --- Interactive Calibrations (F7 & F8) ---
CalibrateEventArea() {
    global EventRatioX, EventRatioY, EventRatioW, EventRatioH, IniPath
    global AutoSwitchDesktop, DesktopStepsRight, DesktopSwitchDelayMs

    didSwitch := false
    if (AutoSwitchDesktop && !WinActive("ahk_exe RobloxPlayerBeta.exe")) {
        SwitchDesktopRight(DesktopStepsRight)
        didSwitch := true
        Sleep(DesktopSwitchDelayMs)
    }

    ActivateRoblox()
    Sleep(250)

    RobloxPos := GetRobloxClientPos()
    if (RobloxPos.w <= 0 || RobloxPos.h <= 0) {
        MsgBox("Roblox is not active.", "Error", "Icon!")
        return
    }

    ToolTip("✦ SELECTION ZONE EVENT (F7) ✦`nMaintenez le CLIC GAUCHE, GLISSEZ pour tracer le rectangle, puis RELÂCHEZ !`n(Touche Échap pour annuler)")

    while !GetKeyState("LButton", "P") {
        if GetKeyState("Escape", "P") {
            ToolTip()
            if (didSwitch)
                SwitchDesktopLeft(DesktopStepsRight)
            return
        }
        Sleep(20)
    }

    CoordMode("Mouse", "Screen")
    MouseGetPos(&startX, &startY)

    SelectGui := Gui("-Caption +AlwaysOnTop +ToolWindow -DPIScale +E0x20")
    SelectGui.BackColor := "0x996696"
    WinSetTransparent(100, SelectGui)

    while GetKeyState("LButton", "P") {
        if GetKeyState("Escape", "P") {
            SelectGui.Destroy()
            ToolTip()
            if (didSwitch)
                SwitchDesktopLeft(DesktopStepsRight)
            return
        }
        MouseGetPos(&curX, &curY)
        bx := Min(startX, curX)
        by := Min(startY, curY)
        bw := Max(Abs(curX - startX), 1)
        bh := Max(Abs(curY - startY), 1)
        SelectGui.Show("x" bx " y" by " w" bw " h" bh " NoActivate")
        Sleep(15)
    }

    MouseGetPos(&endX, &endY)
    SelectGui.Destroy()
    ToolTip()

    minScreenX := Min(startX, endX)
    maxScreenX := Max(startX, endX)
    minScreenY := Min(startY, endY)
    maxScreenY := Max(startY, endY)
    w := maxScreenX - minScreenX
    h := maxScreenY - minScreenY

    if (w < 15 || h < 15) {
        MsgBox("Selection too small, calibration cancelled.", "Event Calibration", "Icon!")
        if (didSwitch)
            SwitchDesktopLeft(DesktopStepsRight)
        return
    }

    hwnd := WinExist("ahk_exe RobloxPlayerBeta.exe") || WinExist("Roblox")
    WinGetClientPos(&winX, &winY, &cw, &ch, hwnd)

    clientMinX := minScreenX - winX
    clientMinY := minScreenY - winY

    EventRatioX := Round(clientMinX / cw, 3)
    EventRatioY := Round(clientMinY / ch, 3)
    EventRatioW := Round(w / cw, 3)
    EventRatioH := Round(h / ch, 3)

    IniWrite(EventRatioX, IniPath, "Hallows_Eve", "EventRatioX")
    IniWrite(EventRatioY, IniPath, "Hallows_Eve", "EventRatioY")
    IniWrite(EventRatioW, IniPath, "Hallows_Eve", "EventRatioW")
    IniWrite(EventRatioH, IniPath, "Hallows_Eve", "EventRatioH")

    testText := ""
    try {
        ocrRes := OCR.FromRect(minScreenX, minScreenY, w, h, {scale: 2.0})
        if (ocrRes)
            testText := ocrRes.Text
    }

    MsgBox("Event box calibrated successfully!`n`nRatios: X=" EventRatioX " | Y=" EventRatioY " | W=" EventRatioW " | H=" EventRatioH "`n`nOCR text recognized (Scale 2x):`n`"" testText "`"", "Calibration Success", "Iconi")

    if (didSwitch) {
        SwitchDesktopLeft(DesktopStepsRight)
        Sleep(DesktopSwitchDelayMs)
    }
}

CalibrateWaterSpot() {
    global WaterRatioX, WaterRatioY, IniPath
    global AutoSwitchDesktop, DesktopStepsRight, DesktopSwitchDelayMs

    didSwitch := false
    if (AutoSwitchDesktop && !WinActive("ahk_exe RobloxPlayerBeta.exe")) {
        SwitchDesktopRight(DesktopStepsRight)
        didSwitch := true
        Sleep(DesktopSwitchDelayMs)
    }

    ActivateRoblox()
    Sleep(250)

    RobloxPos := GetRobloxClientPos()
    if (RobloxPos.w <= 0 || RobloxPos.h <= 0) {
        MsgBox("Roblox is not active.", "Error", "Icon!")
        return
    }

    MsgBox("WATER TARGET CALIBRATION:`n`nPlace cursor on the water fishing spot and CLICK.`n`nThe coordinates will be saved automatically!", "Water Calibration (F8)", "Iconi")

    KeyWait("LButton", "D")
    MouseGetPos(&clickX, &clickY)
    KeyWait("LButton", "U")

    cw := RobloxPos.w, ch := RobloxPos.h
    WaterRatioX := Round(clickX / cw, 3)
    WaterRatioY := Round(clickY / ch, 3)

    IniWrite(WaterRatioX, IniPath, "Fishing_Settings", "WaterRatioX")
    IniWrite(WaterRatioY, IniPath, "Fishing_Settings", "WaterRatioY")

    MsgBox("Water target calibrated successfully!`n`nRatios: X=" WaterRatioX " | Y=" WaterRatioY, "Calibration Success", "Iconi")

    if (didSwitch) {
        SwitchDesktopLeft(DesktopStepsRight)
        Sleep(DesktopSwitchDelayMs)
    }
}

GetRobloxClientPos() {
    result := {w: 0, h: 0}
    hwnd := WinExist("ahk_exe RobloxPlayerBeta.exe")
    if (!hwnd)
        hwnd := WinExist("Roblox")
    if (hwnd) {
        WinGetClientPos(&cx, &cy, &cw, &ch, hwnd)
        result.w := cw
        result.h := ch
    }
    return result
}

ActivateRoblox() {
    if WinExist("ahk_exe RobloxPlayerBeta.exe")
        WinActivate("ahk_exe RobloxPlayerBeta.exe")
    else if WinExist("Roblox")
        WinActivate("Roblox")
}

ToggleMacroState() {
    global IsRunning, TxtStatus, BtnToggle, NormalCharSlot, RodSlot
    global AutoSwitchDesktop, DesktopStepsRight, DesktopSwitchDelayMs
    IsRunning := !IsRunning
    if (IsRunning) {
        TxtStatus.Text := "● FISHING ACTIVE"
        TxtStatus.SetFont("c2EE5C0 bold")
        BtnToggle.Text := "⏸  PAUSE"
        PlayBeep(750, 150)

        didSwitch := false
        if (AutoSwitchDesktop && !WinActive("ahk_exe RobloxPlayerBeta.exe")) {
            SwitchDesktopRight(DesktopStepsRight)
            didSwitch := true
            Sleep(DesktopSwitchDelayMs)
        }

        ActivateRoblox()
        Sleep(250)

        ; Equip standard character and fishing rod at startup
        Send(String(NormalCharSlot))
        Sleep(150)
        Send(String(RodSlot))
        Sleep(150)

        if (EnableRodAbility) {
            TriggerRodAbility()
            RodAbilityCountdown := RodAbilityCooldownSeconds
        }

        StartFishingClick()

        if (didSwitch) {
            Sleep(250)
            SwitchDesktopLeft(DesktopStepsRight)
            Sleep(DesktopSwitchDelayMs)
        }
    } else {
        TxtStatus.Text := "● PAUSED"
        TxtStatus.SetFont("cC490C4 bold")
        BtnToggle.Text := "▶  START"
        PlayBeep(450, 200)
    }
}

; --- Keyboard Hotkeys ---
F1:: ToggleMacroState()

F2:: {
    PlayBeep(300, 250)
    ExitApp()
}

F3:: {
    global ServerClockOffset, IniPath
    curSec := Integer(A_Sec)
    curMin := Integer(A_Min)
    promptMsg := "Shop resets every 5 min (:00, :05...)`nTime: " curMin ":" (curSec < 10 ? "0" curSec : curSec) "`nCurrent offset: +" ServerClockOffset "s`nNew offset (seconds):"
    inputVal := InputBox(promptMsg, "Server Offset", "w340 h200", String(ServerClockOffset))
    if (inputVal.Result != "Cancel" && Trim(inputVal.Value) != "") {
        ServerClockOffset := Integer(Trim(inputVal.Value))
        IniWrite(ServerClockOffset, IniPath, "Shop_Settings", "ServerClockOffsetSeconds")
        PlayBeep(600, 100)
    }
}

F4:: ResetEventTimer()

ResetEventTimer() {
    global EventCountdown, TxtEventTimer
    EventCountdown := 300
    TxtEventTimer.Text := "05:00"
    TxtEventTimer.SetFont("cFFD166 bold")
    PlayBeep(700, 100)
}

F5:: DoAutoBuySequence()
F6:: ManualOcrCheck()
F7:: CalibrateEventArea()
F8:: CalibrateWaterSpot()

ParseIniInt(val, defaultVal := 0) {
    cleaned := Trim(RegExReplace(val, "^[ =]+", ""))
    return (cleaned != "" && IsInteger(cleaned)) ? Integer(cleaned) : defaultVal
}

ParseIniFloat(val, defaultVal := 0.0) {
    cleaned := Trim(RegExReplace(val, "^[ =]+", ""))
    return (cleaned != "" && IsNumber(cleaned)) ? Float(cleaned) : defaultVal
}

LoadConfig() {
    global
    if !FileExist(IniPath)
        return

    Buy_Cash1 := ParseIniInt(IniRead(IniPath, "Potions_Row1", "Buy_Cash_Lvl1", IniRead(IniPath, "Potions_Ligne1", "Buy_Cash_Lvl1", 1)), 1)
    Buy_Cash2 := ParseIniInt(IniRead(IniPath, "Potions_Row1", "Buy_Cash_Lvl2", IniRead(IniPath, "Potions_Ligne1", "Buy_Cash_Lvl2", 1)), 1)
    Buy_Cash3 := ParseIniInt(IniRead(IniPath, "Potions_Row1", "Buy_Cash_Lvl3", IniRead(IniPath, "Potions_Ligne1", "Buy_Cash_Lvl3", 1)), 1)

    Buy_Gems1 := ParseIniInt(IniRead(IniPath, "Potions_Row2", "Buy_Gems_Lvl1", IniRead(IniPath, "Potions_Ligne2", "Buy_Gems_Lvl1", 1)), 1)
    Buy_Gems2 := ParseIniInt(IniRead(IniPath, "Potions_Row2", "Buy_Gems_Lvl2", IniRead(IniPath, "Potions_Ligne2", "Buy_Gems_Lvl2", 1)), 1)
    Buy_Gems3 := ParseIniInt(IniRead(IniPath, "Potions_Row2", "Buy_Gems_Lvl3", IniRead(IniPath, "Potions_Ligne2", "Buy_Gems_Lvl3", 1)), 1)

    Buy_Mutation := ParseIniInt(IniRead(IniPath, "Potions_Row3", "Buy_Mutation_Lvl1", IniRead(IniPath, "Potions_Ligne3", "Buy_Mutation_Lvl1", 1)), 1)
    Buy_FastCatch := ParseIniInt(IniRead(IniPath, "Potions_Row3", "Buy_FastCatch_Lvl1", IniRead(IniPath, "Potions_Ligne3", "Buy_FastCatch_Lvl1", 1)), 1)
    Buy_Luck := ParseIniInt(IniRead(IniPath, "Potions_Row3", "Buy_Luck_Lvl1", IniRead(IniPath, "Potions_Ligne3", "Buy_Luck_Lvl1", 1)), 1)

    ShopMode := IniRead(IniPath, "Shop_Settings", "ShopMode", "Boosts")
    ClicksPerButton := ParseIniInt(IniRead(IniPath, "Shop_Settings", "ClicksPerButton", 3), 3)
    ClickIntervalMs := ParseIniInt(IniRead(IniPath, "Shop_Settings", "ClickIntervalMs", 700), 700)
    ServerClockOffset := ParseIniInt(IniRead(IniPath, "Shop_Settings", "ServerClockOffsetSeconds", 7), 7)
    ShopOpenDelay := ParseIniInt(IniRead(IniPath, "Shop_Settings", "ShopOpenDelayMs", 4000), 4000)
    ScrollTicks := ParseIniInt(IniRead(IniPath, "Shop_Settings", "ScrollWheelTicks", 3), 3)

    AutoSwitchDesktop := ParseIniInt(IniRead(IniPath, "Virtual_Desktop", "AutoSwitchDesktop", 1), 1)
    DesktopStepsRight := ParseIniInt(IniRead(IniPath, "Virtual_Desktop", "DesktopStepsRight", 2), 2)
    DesktopSwitchDelayMs := ParseIniInt(IniRead(IniPath, "Virtual_Desktop", "DesktopSwitchDelayMs", 350), 350)

    WalkKey := IniRead(IniPath, "Navigation_Settings", "WalkKey", "q")
    WalkDurationMs := ParseIniInt(IniRead(IniPath, "Navigation_Settings", "WalkDurationMs", 1600), 1600)
    AdjustKey := IniRead(IniPath, "Navigation_Settings", "AdjustKey", "d")
    AdjustDurationMs := ParseIniInt(IniRead(IniPath, "Navigation_Settings", "AdjustDurationMs", 350), 350)
    AutoRecoveryEnabled := ParseIniInt(IniRead(IniPath, "Navigation_Settings", "AutoRecoveryEnabled", 1), 1)

    AntiAfkInterval := ParseIniInt(IniRead(IniPath, "Fishing_Settings", "AntiAfkIntervalSeconds", 180), 180)
    WaterRatioX := ParseIniFloat(IniRead(IniPath, "Fishing_Settings", "WaterRatioX", 0.324), 0.324)
    WaterRatioY := ParseIniFloat(IniRead(IniPath, "Fishing_Settings", "WaterRatioY", 0.556), 0.556)
    EnableSoundBeep := ParseIniInt(IniRead(IniPath, "Sound_Settings", "EnableSoundBeep", 0), 0)
    EventClockOffset := ParseIniInt(IniRead(IniPath, "Event_Settings", "EventClockOffsetSeconds", 0), 0)

    EnableWatchdog := ParseIniInt(IniRead(IniPath, "Fishing_Watchdog", "EnableWatchdog", 1), 1)
    WatchdogIntervalSeconds := ParseIniInt(IniRead(IniPath, "Fishing_Watchdog", "WatchdogIntervalSeconds", 25), 25)
    RodSlotKey := ParseIniInt(IniRead(IniPath, "Fishing_Watchdog", "RodSlotKey", 1), 1)

    EnableHallowsEve := ParseIniInt(IniRead(IniPath, "Hallows_Eve", "EnableHallowsEve", 1), 1)
    EventCharSlot := ParseIniInt(IniRead(IniPath, "Hallows_Eve", "EventCharSlot", 2), 2)
    NormalCharSlot := ParseIniInt(IniRead(IniPath, "Hallows_Eve", "NormalCharSlot", 1), 1)
    RodSlot := ParseIniInt(IniRead(IniPath, "Hallows_Eve", "RodSlot", 1), 1)
    CheckIntervalSeconds := ParseIniInt(IniRead(IniPath, "Hallows_Eve", "CheckIntervalSeconds", 4), 4)
    EventRatioX := ParseIniFloat(IniRead(IniPath, "Hallows_Eve", "EventRatioX", 0.35), 0.35)
    EventRatioY := ParseIniFloat(IniRead(IniPath, "Hallows_Eve", "EventRatioY", 0.04), 0.04)
    EventRatioW := ParseIniFloat(IniRead(IniPath, "Hallows_Eve", "EventRatioW", 0.30), 0.30)
    EventRatioH := ParseIniFloat(IniRead(IniPath, "Hallows_Eve", "EventRatioH", 0.12), 0.12)

    SeleneCycleMinutes := ParseIniInt(IniRead(IniPath, "Selene_Settings", "SeleneCycleMinutes", 30), 30)
    SeleneDurationMinutes := ParseIniInt(IniRead(IniPath, "Selene_Settings", "SeleneDurationMinutes", 5), 5)
    SeleneClockOffsetSeconds := ParseIniInt(IniRead(IniPath, "Selene_Settings", "SeleneClockOffsetSeconds", 0), 0)

    EnableRodAbility := ParseIniInt(IniRead(IniPath, "Rod_Ability", "EnableRodAbility", 1), 1)
    RodAbilityKey := IniRead(IniPath, "Rod_Ability", "RodAbilityKey", "v")
    RodAbilityCooldownSeconds := ParseIniInt(IniRead(IniPath, "Rod_Ability", "RodAbilityCooldownSeconds", 481), 481)
    RodAbilityCountdown := RodAbilityCooldownSeconds
}
