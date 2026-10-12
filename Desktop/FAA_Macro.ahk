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

global SeleneCycleMinutes := 30            ; Fixed 30-minute Selene cycle (:00 and :30)
global SeleneDurationMinutes := 5
global SeleneClockOffsetSeconds := 0
global SeleneActive := false

; Boost Shop Potion purchases (1 = Buy, 0 = Skip)
global Buy_Cash1 := 1, Buy_Cash2 := 1, Buy_Cash3 := 1
global Buy_Gems1 := 1, Buy_Gems2 := 1, Buy_Gems3 := 1
global Buy_Mutation := 1, Buy_FastCatch := 1, Buy_Luck := 1

; Selene Store purchases (1 = Buy, 0 = Skip - Only allowed potions!)
global Buy_Selene_Luck3 := 1
global Buy_Selene_Heavens := 1
global Buy_Selene_Luck2 := 1
global Buy_Selene_Food1 := 1

; Auto-Rebirth settings
global EnableAutoRebirth := 1
global RebirthIntervalMinutes := 60
global LastRebirthTick := A_TickCount

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

; Rod Ability (Key V)
global EnableRodAbility := 1
global RodAbilityKey := "v"
global RodAbilityCooldownSeconds := 481    ; Default: 8m 01s
global RodAbilityCountdown := 481

; Hallows Eve OCR & Character Swap
global EnableHallowsEve := 1
global EventCharSlot := 2                  ; Special event character slot
global NormalCharSlot := 0                 ; Standard character slot (0 = toggle off EventCharSlot)
global CheckIntervalSeconds := 4
global EventRatioX := 0.35
global EventRatioY := 0.04
global EventRatioW := 0.30
global EventRatioH := 0.12
global IsHallowsEveActive := false
global HallowsEveMissCount := 0
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
VerCtrl := WidgetGui.Add("Text", "x" (CX+30) " y26 w220 h14 Center BackgroundTrans cB090BC", "KITS Progress Inc. · Desktop v3.3")
VerCtrl.SetFont("s7 bold", "Segoe UI")

CloseCtrl := WidgetGui.Add("Text", "x" (CX+252) " y10 w20 h20 Center BackgroundTrans cC490C4", "✕")
CloseCtrl.SetFont("s9 bold", "Segoe UI")
CloseCtrl.OnEvent("Click", (*) => ExitApp())

; Timers & HUD Elements
WidgetGui.Add("Text", "x" (CX+35) " y44 w85 h16 BackgroundTrans cB8A5C9", "BOOST SHOP")
global TxtShopTimer := WidgetGui.Add("Text", "x" (CX+130) " y42 w115 h18 Right BackgroundTrans c2EE5C0", "00:00")
TxtShopTimer.SetFont("s10 bold", "Consolas")

WidgetGui.Add("Text", "x" (CX+35) " y65 w85 h16 BackgroundTrans cB8A5C9", "SELENE")
global TxtSeleneTimer := WidgetGui.Add("Text", "x" (CX+130) " y65 w115 h18 Right BackgroundTrans cC084FC", "AWAY · 30:00")
TxtSeleneTimer.SetFont("s9 bold", "Consolas")

WidgetGui.Add("Text", "x" (CX+35) " y86 w85 h16 BackgroundTrans cB8A5C9", "ABILITY")
global TxtRodAbilityTimer := WidgetGui.Add("Text", "x" (CX+130) " y86 w115 h18 Right BackgroundTrans c2EE5C0", "08:01")
TxtRodAbilityTimer.SetFont("s9 bold", "Consolas")
TxtRodAbilityTimer.OnEvent("Click", (*) => ManualTriggerRodAbility())

WidgetGui.Add("Text", "x" (CX+35) " y107 w85 h16 BackgroundTrans cB8A5C9", "HALLOWS EVE")
global TxtHallowsEveStatus := WidgetGui.Add("Text", "x" (CX+120) " y106 w125 h16 Right BackgroundTrans cB8A5C9", "● INACTIVE")
TxtHallowsEveStatus.SetFont("s8 bold", "Segoe UI")
TxtHallowsEveStatus.OnEvent("Click", (*) => ManualOcrCheck())

global TxtStatus := WidgetGui.Add("Text", "x" (CX+30) " y128 w220 h17 Center BackgroundTrans cC490C4", "● PAUSED")
TxtStatus.SetFont("s9 bold", "Segoe UI")

global BtnToggle := WidgetGui.Add("Text", "x" (CX+30) " y148 w220 h28 Center 0x200 BackgroundTrans cFFFFFF", "▶  START")
BtnToggle.SetFont("s11 bold", "Segoe UI")
BtnToggle.OnEvent("Click", (*) => ToggleMacroState())

global BtnShopMode := WidgetGui.Add("Text", "x" (CX+30) " y176 w220 h17 Center BackgroundTrans c2EE5C0", "[ MODE : BOOST SHOP ]")
BtnShopMode.SetFont("s8 bold", "Segoe UI")
BtnShopMode.OnEvent("Click", (*) => ToggleShopMode())

FooterCtrl := WidgetGui.Add("Text", "x" (CX) " y198 w280 h16 Center BackgroundTrans c6A4E72", "F1 · Pause  |  F7 · Event  |  F8 · Water  |  F9 · Rebirth  |  F2 · Exit")
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
    global ShopCountdown, ServerClockOffset, LastTriggeredMinute, TxtShopTimer
    global SeleneCycleMinutes, SeleneDurationMinutes, SeleneClockOffsetSeconds
    global SeleneActive, TxtSeleneTimer
    global IsRunning, IsExecutingShop, ShopMode
    global LastAntiAfkTick, AntiAfkInterval
    global LastOcrCheckTick, CheckIntervalSeconds, EnableHallowsEve
    global EnableRodAbility, RodAbilityCountdown, RodAbilityCooldownSeconds, TxtRodAbilityTimer
    global EnableAutoRebirth, RebirthIntervalMinutes, LastRebirthTick

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

    ; Hallows Eve OCR Detection (runs even when paused so user sees HUD live status)
    if (EnableHallowsEve && !IsExecutingShop) {
        nowTick := A_TickCount
        if ((nowTick - LastOcrCheckTick) >= (CheckIntervalSeconds * 1000)) {
            LastOcrCheckTick := nowTick
            CheckHallowsEveEvent()
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

    ; Auto-Rebirth periodic cycle (default every 60 minutes)
    if (EnableAutoRebirth && IsRunning && !IsExecutingShop) {
        nowTick := A_TickCount
        if ((nowTick - LastRebirthTick) >= (RebirthIntervalMinutes * 60000)) {
            LastRebirthTick := nowTick
            SetTimer(DoAutoRebirthSequence, -50)
        }
    }
}

; --- Hallows Eve Detection Engine & Character Swap ---
DetectHallowsEveInRect(screenX, screenY, screenW, screenH) {
    ; Method 1: ImageSearch (Fastest & 100% precision if reference asset exists)
    assetPath := A_ScriptDir "\assets\hallows_eve.png"
    if FileExist(assetPath) {
        CoordMode("Pixel", "Screen")
        if ImageSearch(&fX, &fY, screenX, screenY, screenX + screenW, screenY + screenH, "*40 " assetPath)
            return {found: true, method: "ImageSearch", text: "[Matched assets\hallows_eve.png]"}
    }

    ; Method 2: Multi-pass Adaptive OCR (Windows UWP OCR)
    ; Pass 1: Standard 1.0x (best for large bold game title fonts and normal text)
    ; Pass 2: Grayscale 1.0x (removes color gradient noise in stylized 3D fonts)
    ; Pass 3: 1.4x scale (best for smaller subtitle / description text)
    ocrTexts := []
    try {
        r1 := OCR.FromRect(screenX, screenY, screenW, screenH, {scale: 1.0})
        if (r1 && r1.Text != "")
            ocrTexts.Push(r1.Text)
    }
    try {
        r2 := OCR.FromRect(screenX, screenY, screenW, screenH, {scale: 1.0, grayscale: 1})
        if (r2 && r2.Text != "")
            ocrTexts.Push(r2.Text)
    }
    try {
        r3 := OCR.FromRect(screenX, screenY, screenW, screenH, {scale: 1.4})
        if (r3 && r3.Text != "")
            ocrTexts.Push(r3.Text)
    }
    try {
        r4 := OCR.FromRect(screenX, screenY, screenW, screenH, {scale: 1.0, monochrome: 150})
        if (r4 && r4.Text != "")
            ocrTexts.Push(r4.Text)
    }
    try {
        r5 := OCR.FromRect(screenX, screenY, screenW, screenH, {scale: 1.0, invertcolors: 1})
        if (r5 && r5.Text != "")
            ocrTexts.Push(r5.Text)
    }

    allText := ""
    for t in ocrTexts
        allText .= t " `n"
    lower := StrLower(allText)

    ; 1) Negative Filter / Anti-False Positive Guard:
    ; Comprehensive exclusion list based on official Fish an Anime RNG wiki events:
    ; Random Events: Blizzard, Sweet Dreams, Solar, Lunar, Slime Rain, Thunder
    ; Rare & Server: Sub Zero, Sakura Season, Lucrative Realization, Complex Matrix, Toxic Wasteland, Forgotten Ruins, Sad Ending, Starfall
    ; Catch & Ritual: Heaven's Collide, Hell's Gates, Limerence Complexity, Broken Thoughts, Eclipse
    ; Potion: Cyberspace, Dreamspace
    otherEvents := [
        "collide", "heaven", "angelic",
        "hell's gate", "hells gate", "hell's", "hells",
        "starfall", "sakura", "sub zero", "blizzard", "thunder",
        "sweet dream", "slime rain", "toxic waste", "forgotten ruin",
        "sad ending", "complex matrix", "cyberspace", "dreamspace",
        "lucrative", "realization", "limerence", "broken thought", "eclipse"
    ]

    matchedExclusion := ""
    for ev in otherEvents {
        if InStr(lower, ev) {
            matchedExclusion := ev
            break
        }
    }
    if (matchedExclusion != "" && !InStr(lower, "hallow"))
        return {found: false, method: "Excluded (" matchedExclusion ")", text: allText, hasTitle: false, hasDesc: false}

    ; 2) Event Title signatures (Strictly HALLOWS EVE):
    ; NEVER match 'eve' alone, as 'Event Duration' appears in every single event!
    hasTitle := InStr(lower, "hallow") 
             || InStr(lower, "hallows") 
             || (InStr(lower, "allow") && InStr(lower, "eve"))

    ; 3) Exclusive Hallows Eve mechanics (from live game banner):
    ; "Held Characters can be Turned into a DRACULA!"
    ; The only unique mutation of Hallows Eve is DRACULA (or Demonic + Dracula).
    ; Generic words like 'held', 'turn', 'turned into' are SHARED across multiple events and must NEVER trigger on their own!
    hasDracula := InStr(lower, "dracula")
               || (InStr(lower, "demonic") && InStr(lower, "drac"))

    ; Valid Hallows Eve requires either:
    ; - The title explicitly containing HALLOW / HALLOWS / ALLOWS EVE, OR
    ; - The description mentioning DRACULA mutation!
    isHallows := hasTitle || hasDracula
    return {found: isHallows, method: "Multi-Pass OCR", text: allText, hasTitle: hasTitle, hasDesc: hasDracula}
}

CheckHallowsEveEvent() {
    global EnableHallowsEve, IsRunning, IsExecutingShop
    global EventRatioX, EventRatioY, EventRatioW, EventRatioH
    global EventCharSlot, NormalCharSlot
    global IsHallowsEveActive, TxtHallowsEveStatus, HallowsEveMissCount

    if (!EnableHallowsEve || IsExecutingShop)
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

    det := DetectHallowsEveInRect(screenX, screenY, screenW, screenH)

    if (det.found) {
        HallowsEveMissCount := 0
        if (!IsHallowsEveActive) {
            IsHallowsEveActive := true
            TxtHallowsEveStatus.Text := IsRunning ? ("🎃 ACTIVE (Slot " EventCharSlot ")") : "🎃 ACTIVE"
            TxtHallowsEveStatus.SetFont("cFF9D00 bold")

            if (IsRunning) {
                ; Hold event character via Key 'é' (Slot 2) without interrupting ongoing fishing
                ActivateRoblox()
                Sleep(80)
                PressHotbarSlot(EventCharSlot)
                Sleep(100)
            }
        }
    } else {
        if (IsHallowsEveActive) {
            ; Debounce non-detections (e.g. catch text briefly covering banner)
            HallowsEveMissCount++
            if (HallowsEveMissCount >= 2) {
                wasActive := IsHallowsEveActive
                IsHallowsEveActive := false
                HallowsEveMissCount := 0
                TxtHallowsEveStatus.Text := (NormalCharSlot > 0 && NormalCharSlot != EventCharSlot) ? "● INACTIVE (Slot " NormalCharSlot ")" : "● INACTIVE"
                TxtHallowsEveStatus.SetFont("cB8A5C9")
                if (IsRunning && wasActive) {
                    ; Release event character by re-pressing Key 'é' (Slot 2)
                    slotToUnequip := (NormalCharSlot > 0 && NormalCharSlot != EventCharSlot) ? NormalCharSlot : EventCharSlot
                    ActivateRoblox()
                    Sleep(80)
                    PressHotbarSlot(slotToUnequip)
                    Sleep(100)
                }
            }
        }
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

    det := DetectHallowsEveInRect(screenX, screenY, screenW, screenH)
    detSummary := det.found ? "YES (🎃 ACTIVE)" : "NO (Normal event or idle)"
    MsgBox(
        "✦ OCR EVENT CHECK RESULT ✦`n`n"
        "Coordinates: X=" screenX " Y=" screenY " W=" screenW " H=" screenH "`n"
        "Detection Method: " det.method "`n"
        "Hallows Eve Detected: " detSummary "`n`n"
        "✦ Recognized Text (Multi-pass):`n`"" Trim(det.text) "`"",
        "OCR Event Check",
        "Iconi"
    )
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

PressHotbarSlot(slotNum) {
    if (slotNum <= 0)
        return
    ; Uses raw physical scancode to guarantee 100% compatibility on AZERTY (é, &, ", etc.) and QWERTY:
    ; Slot 1 = sc002 (& / 1), Slot 2 = sc003 (é / 2), Slot 3 = sc004 (" / 3)...
    sc := Format("sc{:03X}", slotNum + 1)
    Send("{" sc " down}")
    Sleep(80)
    Send("{" sc " up}")
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



; --- Auto-Rebirth Routine (100% Robux-Safe) ---
DoAutoRebirthSequence() {
    global IsRunning, IsExecutingShop, TxtStatus
    global AutoSwitchDesktop, DesktopStepsRight, DesktopSwitchDelayMs
    global LastRebirthTick

    if (IsExecutingShop)
        return
    IsExecutingShop := true

    didSwitch := false
    if (AutoSwitchDesktop && !WinActive("ahk_exe RobloxPlayerBeta.exe")) {
        SwitchDesktopRight(DesktopStepsRight)
        didSwitch := true
        Sleep(DesktopSwitchDelayMs)
    }

    ActivateRoblox()
    Sleep(300)

    RobloxPos := GetRobloxClientPos()
    if (RobloxPos.w < 200 || RobloxPos.h < 200) {
        if (didSwitch)
            SwitchDesktopLeft(DesktopStepsRight)
        IsExecutingShop := false
        return
    }

    cw := RobloxPos.w, ch := RobloxPos.h
    CoordMode("Mouse", "Client")
    SendMode("Event")
    SetMouseDelay(2)

    TxtStatus.Text := "AUTO-REBIRTH..."
    TxtStatus.SetFont("cFF9D00 bold")

    ; Step 1: Open Rebirth menu via left sidebar icon (X=0.034, Y=0.408)
    sbX := Integer(cw * 0.034)
    sbY := Integer(ch * 0.408)
    MouseMove(sbX, sbY, 3)
    Sleep(200)
    Click(sbX, sbY)
    Sleep(700)

    ; Step 2: Click green Rebirth! button on left (X=0.356, Y=0.725)
    ; NOTE: Robux button is on the right (X=0.620) - we strictly click left!
    gbX := Integer(cw * 0.356)
    gbY := Integer(ch * 0.725)
    MouseMove(gbX, gbY, 3)
    Sleep(200)
    Click(gbX, gbY)
    Sleep(250)
    Click(gbX, gbY)
    Sleep(400)

    ; Step 3: Close Rebirth modal & dismiss Robux purchase prompt if not enough cash
    ; NOTE: If player lacks cash, Roblox opens a "Buy Robux" prompt in the screen center.
    ; (closeX, closeY) at (0.754, 0.174) is completely OUTSIDE the Robux modal (100% safe, never clicks "Acheter").
    ; - 1st click: Hits the outside backdrop, safely dismissing the Robux prompt if present.
    ; - 2nd click: Hits the red [X] button of the Rebirth menu behind it to close the menu.
    ; - 3rd click: Extra safety click in case of lag/animation delay.
    closeX := Integer(cw * 0.754)
    closeY := Integer(ch * 0.174)
    MouseMove(closeX, closeY, 3)
    Sleep(200)
    Click(closeX, closeY)  ; Click 1: Dismisses Robux prompt if open, or closes Rebirth
    Sleep(400)             ; Wait for Robux popup dismiss animation
    Click(closeX, closeY)  ; Click 2: Closes Rebirth red [X] button
    Sleep(300)
    Click(closeX, closeY)  ; Click 3: Safety click against lag
    Sleep(300)

    LastRebirthTick := A_TickCount

    ; Re-engage fishing
    if (IsRunning) {
        TxtStatus.Text := "● FISHING ACTIVE"
        TxtStatus.SetFont("c2EE5C0 bold")
        StartFishingClick()
    } else {
        TxtStatus.Text := "● PAUSED"
        TxtStatus.SetFont("cC490C4 bold")
    }

    if (didSwitch)
        SwitchDesktopLeft(DesktopStepsRight)

    IsExecutingShop := false
}

; --- Selene Store Routine (Only buys allowed potions, zero Robux) ---
DoSeleneBuySequence(cw, ch, scrollCenterX, scrollCenterY, didSwitchDesktop) {
    global IsRunning, IsExecutingShop, TxtStatus
    global DesktopStepsRight, ScrollTicks
    global Buy_Selene_Luck3, Buy_Selene_Heavens, Buy_Selene_Luck2, Buy_Selene_Food1

    ; Selene's Store Coordinates (Calibrated with precision from live screen):
    ; Item 1: Luck Potion Lvl. 3 (Row 1, Col 1, before scroll) - Gems button on left
    s1_col1_X := Integer(cw * 0.274)
    s1_row1_Y := Integer(ch * 0.470)

    ; Step 1: Buy Luck Potion Lvl. 3 before scrolling
    if (Buy_Selene_Luck3 && IsRunning && IsExecutingShop) {
        TxtStatus.Text := "Selene Luck Lvl 3..."
        BuyCashButton(s1_col1_X, s1_row1_Y)
    }

    if (!IsRunning || !IsExecutingShop) {
        if (didSwitchDesktop)
            SwitchDesktopLeft(DesktopStepsRight)
        IsExecutingShop := false
        return
    }

    ; Step 2: Scroll down to reveal Heaven's Collide, Luck Lvl 2, Food Lvl 1
    needsScroll := (Buy_Selene_Heavens || Buy_Selene_Luck2 || Buy_Selene_Food1)
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

        ; Scrolled coordinates (Exact button centers):
        ; Row 1: Heaven's Collide (Col 2, Gems) & Luck Potion Lvl 2 (Col 3, Cash)
        s2_col2_X := Integer(cw * 0.450)
        s2_col3_X := Integer(cw * 0.635)
        s2_row1_Y := Integer(ch * 0.448)

        ; Row 2: Food Potion Lvl. 1 (Col 2, Cash)
        s2_row2_Y := Integer(ch * 0.680)

        ; Item 2: Heaven's Collide Potion (Row 1, Col 2) - Gems button on left
        if (Buy_Selene_Heavens && IsRunning && IsExecutingShop) {
            TxtStatus.Text := "Heaven's Collide..."
            BuyCashButton(s2_col2_X, s2_row1_Y)
        }

        ; Item 3: Luck Potion Lvl. 2 (Row 1, Col 3) - Cash button on left
        if (Buy_Selene_Luck2 && IsRunning && IsExecutingShop) {
            TxtStatus.Text := "Selene Luck Lvl 2..."
            BuyCashButton(s2_col3_X, s2_row1_Y)
        }

        ; Item 4: Food Potion Lvl. 1 (Row 2, Col 2) - Cash button on left
        if (Buy_Selene_Food1 && IsRunning && IsExecutingShop) {
            TxtStatus.Text := "Selene Food Lvl 1..."
            BuyCashButton(s2_col2_X, s2_row2_Y)
        }
    }

    ; Close Selene Store (Red [X] button at X=0.788, Y=0.190)
    TxtStatus.Text := "CLOSING STORE..."
    close_X := Integer(cw * 0.788)
    close_Y := Integer(ch * 0.190)
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

    ; Branch to dedicated Selene Store sequence
    if (ShopMode == "Selene") {
        DoSeleneBuySequence(cw, ch, scrollCenterX, scrollCenterY, didSwitchDesktop)
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

    while !GetKeyState("LButton", "P") {
        if GetKeyState("Escape", "P") {
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

    ; Auto-expand 35% upward so top floating title logo is never clipped
    topPad := Integer(h * 0.35)
    adjustedMinScreenY := Max(winY, minScreenY - topPad)
    adjustedH := maxScreenY - adjustedMinScreenY

    clientMinX := minScreenX - winX
    clientMinY := adjustedMinScreenY - winY

    EventRatioX := Round(clientMinX / cw, 3)
    EventRatioY := Round(clientMinY / ch, 3)
    EventRatioW := Round(w / cw, 3)
    EventRatioH := Round(adjustedH / ch, 3)

    IniWrite(EventRatioX, IniPath, "Hallows_Eve", "EventRatioX")
    IniWrite(EventRatioY, IniPath, "Hallows_Eve", "EventRatioY")
    IniWrite(EventRatioW, IniPath, "Hallows_Eve", "EventRatioW")
    IniWrite(EventRatioH, IniPath, "Hallows_Eve", "EventRatioH")

    det := DetectHallowsEveInRect(minScreenX, adjustedMinScreenY, w, adjustedH)
    detSummary := det.found ? "YES (🎃 ACTIVE)" : "NO (Normal event or idle)"

    if (det.found) {
        IsHallowsEveActive := true
        TxtHallowsEveStatus.Text := IsRunning ? ("🎃 ACTIVE (Slot " EventCharSlot ")") : "🎃 ACTIVE"
        TxtHallowsEveStatus.SetFont("cFF9D00 bold")
    } else {
        IsHallowsEveActive := false
        TxtHallowsEveStatus.Text := (NormalCharSlot > 0 && NormalCharSlot != EventCharSlot) ? "● INACTIVE (Slot " NormalCharSlot ")" : "● INACTIVE"
        TxtHallowsEveStatus.SetFont("cB8A5C9")
    }

    MsgBox(
        "Event box calibrated successfully!`n`n"
        "Ratios: X=" EventRatioX " | Y=" EventRatioY " | W=" EventRatioW " | H=" EventRatioH "`n`n"
        "Detection Method: " det.method "`n"
        "Hallows Eve Detected: " detSummary "`n`n"
        "✦ Recognized Text (Multi-pass):`n`"" Trim(det.text) "`"",
        "Calibration Success",
        "Iconi"
    )

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
    global IsRunning, TxtStatus, BtnToggle
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

        if (EnableRodAbility) {
            TriggerRodAbility()
            RodAbilityCountdown := RodAbilityCooldownSeconds
        }

        if (IsHallowsEveActive) {
            TxtHallowsEveStatus.Text := "🎃 ACTIVE (Slot " EventCharSlot ")"
            TxtHallowsEveStatus.SetFont("cFF9D00 bold")
            PressHotbarSlot(EventCharSlot)
            Sleep(100)
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



F5:: DoAutoBuySequence()
F6:: ManualOcrCheck()
F7:: CalibrateEventArea()
F8:: CalibrateWaterSpot()
F9:: DoAutoRebirthSequence()

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
    if !FileExist(IniPath) && FileExist(A_ScriptDir "\config.example.ini")
        FileCopy(A_ScriptDir "\config.example.ini", IniPath)
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
    EnableHallowsEve := ParseIniInt(IniRead(IniPath, "Hallows_Eve", "EnableHallowsEve", 1), 1)
    EventCharSlot := ParseIniInt(IniRead(IniPath, "Hallows_Eve", "EventCharSlot", 2), 2)
    NormalCharSlot := ParseIniInt(IniRead(IniPath, "Hallows_Eve", "NormalCharSlot", 0), 0)
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

    ; Selene Potions
    Buy_Selene_Luck3 := ParseIniInt(IniRead(IniPath, "Selene_Potions", "Buy_Luck_Lvl3", 1), 1)
    Buy_Selene_Heavens := ParseIniInt(IniRead(IniPath, "Selene_Potions", "Buy_HeavensCollide", 1), 1)
    Buy_Selene_Luck2 := ParseIniInt(IniRead(IniPath, "Selene_Potions", "Buy_Luck_Lvl2", 1), 1)
    Buy_Selene_Food1 := ParseIniInt(IniRead(IniPath, "Selene_Potions", "Buy_Food_Lvl1", 1), 1)

    ; Auto-Rebirth
    EnableAutoRebirth := ParseIniInt(IniRead(IniPath, "Auto_Rebirth", "EnableAutoRebirth", 1), 1)
    RebirthIntervalMinutes := ParseIniInt(IniRead(IniPath, "Auto_Rebirth", "RebirthIntervalMinutes", 60), 60)
}
