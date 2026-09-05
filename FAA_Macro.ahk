#Requires AutoHotkey v2.0+
#SingleInstance Force

; ==============================================================================
;   FISH AN ANIME RNG (FAA) — ÉDITION NAKANO NINO V7.5
; ==============================================================================
; THÈME : Nakano Nino (#996696) - Liquid Glass
; MOTEUR : Version 6 Septembre 23:26
; ==============================================================================

; --- PARAMÈTRES GLOBAUX ---
global IniPath := A_ScriptDir "\config.ini"
global IsRunning := false
global IsExecutingShop := false

; Timers et Horloge Fixe du Boost Shop (:00, :05, :10...)
global ServerClockOffset := 7
global ShopCountdown := 0
global LastTriggeredMinute := -1

; Timer Événement Serveur (Cycle relatif de 5 min, synchronisable via F4 ou clic)
global EventCountdown := 300

; Timer indicatif de Sélène (Médiane / estimation réaliste ~10:00)
global SeleneCountdown := 600
global SeleneActive := false
global SeleneActiveRemaining := 0

; Configuration des Potions
global Buy_Cash1 := 1, Buy_Cash2 := 1, Buy_Cash3 := 1
global Buy_Gems1 := 1, Buy_Gems2 := 1, Buy_Gems3 := 1
global Buy_Mutation := 1, Buy_FastCatch := 1, Buy_Luck := 1

; Réglages d'achat
global ClicksPerButton := 3          ; 3 clics posés par bouton pour vider le stock
global ClickIntervalMs := 700        ; 700ms entre chaque clic
global ShopOpenDelay := 4000         ; 4s d'attente pour affichage complet du shop
global ScrollTicks := 3              ; 3 crans de molette pour descendre à l'écran 2

; Bureau Virtuel Windows (Bureau 1 vers Bureau 3)
global AutoSwitchDesktop := 1
global DesktopStepsRight := 2
global DesktopSwitchDelayMs := 350

; Pêche & Anti-AFK
global WaterRatioX := 0.324
global WaterRatioY := 0.556
global AntiAfkInterval := 180
global LastAntiAfkTick := A_TickCount
global EnableSoundBeep := 0

; Charger la configuration depuis config.ini
LoadConfig()

; ==============================================================================
;   CRÉATION DU WIDGET NAKANO NINO (LIQUID GLASS HUD)
; ==============================================================================
global WidgetGui := Gui("-Caption +AlwaysOnTop +ToolWindow -DPIScale", "Fish an Anime RNG · KITS Progress Inc.")
WidgetGui.BackColor := "0x010101"

; Fond liquid glass BMP avec rubans latéraux
BgPath := A_ScriptDir "\assets\widget_full.bmp"
if FileExist(BgPath)
    WidgetGui.Add("Picture", "x0 y0 w390 h200", BgPath)

; Coordonnées relatives au cadre (offset +55px pour les rubans à gauche)
CX := 55

; --- TITRE & BRANDING ---
TitleCtrl := WidgetGui.Add("Text", "x" (CX+30) " y12 w220 h22 Center BackgroundTrans cE8B4E8", "✦ FISH AN ANIME RNG ✦")
TitleCtrl.SetFont("s10 bold", "Segoe UI")
VerCtrl := WidgetGui.Add("Text", "x" (CX+30) " y28 w220 h14 Center BackgroundTrans cB090BC", "KITS Progress Inc.  ·  Nino Vers.")
VerCtrl.SetFont("s7 bold", "Segoe UI")

; Bouton fermer [✕]
CloseCtrl := WidgetGui.Add("Text", "x" (CX+252) " y12 w20 h20 Center BackgroundTrans cC490C4", "✕")
CloseCtrl.SetFont("s9 bold", "Segoe UI")
CloseCtrl.OnEvent("Click", (*) => ExitApp())

; --- TIMERS DES ÉVÉNEMENTS ---
WidgetGui.Add("Text", "x" (CX+35) " y44 w85 h16 BackgroundTrans cB8A5C9", "BOOST SHOP")
global TxtShopTimer := WidgetGui.Add("Text", "x" (CX+130) " y42 w115 h18 Right BackgroundTrans c2EE5C0", "00:00")
TxtShopTimer.SetFont("s10 bold", "Consolas")

EventLabel := WidgetGui.Add("Text", "x" (CX+35) " y61 w85 h16 BackgroundTrans cB8A5C9", "NEXT EVENT")
EventLabel.OnEvent("Click", (*) => ResetEventTimer())
global TxtEventTimer := WidgetGui.Add("Text", "x" (CX+130) " y59 w115 h18 Right BackgroundTrans cFFD166", "05:00")
TxtEventTimer.SetFont("s10 bold", "Consolas")
TxtEventTimer.OnEvent("Click", (*) => ResetEventTimer())

WidgetGui.Add("Text", "x" (CX+35) " y78 w85 h16 BackgroundTrans cB8A5C9", "SÉLÈNE")
global TxtSeleneTimer := WidgetGui.Add("Text", "x" (CX+130) " y78 w115 h18 Right BackgroundTrans cC084FC", "AWAY · 10:00")
TxtSeleneTimer.SetFont("s9 bold", "Consolas")

; --- STATUT ---
global TxtStatus := WidgetGui.Add("Text", "x" (CX+30) " y98 w220 h18 Center BackgroundTrans cC490C4", "● EN PAUSE")
TxtStatus.SetFont("s9 bold", "Segoe UI")

; --- BOUTON DÉMARRER (Centré & Épuré) ---
global BtnToggle := WidgetGui.Add("Text", "x" (CX+30) " y118 w220 h36 Center 0x200 BackgroundTrans cFFFFFF", "▶  DÉMARRER")
BtnToggle.SetFont("s11 bold", "Segoe UI")
BtnToggle.OnEvent("Click", (*) => ToggleMacroState())

; --- FOOTER RACCOURCIS ---
FooterCtrl := WidgetGui.Add("Text", "x" (CX) " y172 w280 h18 Center BackgroundTrans c6A4E72", "F1 · Pause  ·  F4 · Sync Event  ·  F5 · Shop  ·  F2 · Quitter")
FooterCtrl.SetFont("s8", "Segoe UI")

; Rendre le widget déplaçable
OnMessage(0x0201, WM_LBUTTONDOWN)

; Position en haut à droite
WinWidth := 390
WinHeight := 200
PosX := A_ScreenWidth - WinWidth - 5
PosY := 30
WidgetGui.Show("x" PosX " y" PosY " w" WinWidth " h" WinHeight " NoActivate")

; Rendre le fond 010101 transparent (seul le cadre + rubans restent visibles)
WinSetTransColor("010101", WidgetGui)

; Timers périodiques
SetTimer(TimerSecondTick, 1000)
SetTimer(AntiAfkLoop, 2000)

; ==============================================================================
;   DRAG WIDGET
; ==============================================================================
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    if (hwnd = WidgetGui.Hwnd)
        PostMessage(0xA1, 2, 0, , "ahk_id " WidgetGui.Hwnd)
}

; ==============================================================================
;   FONCTIONS BUREAUX VIRTUELS WINDOWS
; ==============================================================================
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

; ==============================================================================
;   TICK SECONDE (HORLOGE DU BOOST SHOP :00, :05, :10...)
; ==============================================================================
TimerSecondTick() {
    global ShopCountdown, ServerClockOffset, LastTriggeredMinute
    global EventCountdown, EventClockOffset, TxtEventTimer
    global SeleneCountdown, SeleneActive, SeleneActiveRemaining, TxtSeleneTimer
    global IsRunning, IsExecutingShop

    curMin := Integer(A_Min)
    curSec := Integer(A_Sec)

    minsPast := Mod(curMin, 5)
    rawRem := (4 - minsPast) * 60 + (60 - curSec)
    ShopCountdown := Mod(rawRem, 300)

    ; Déclenchement automatique de l'achat à l'heure du restock (:00/:05 + offset)
    if (minsPast == 0 && curSec == ServerClockOffset) {
        if (LastTriggeredMinute != curMin) {
            LastTriggeredMinute := curMin
            if (IsRunning && !IsExecutingShop)
                SetTimer(DoAutoBuySequence, -50)
        }
    }

    ; Format MM:SS Boost Shop
    mins := Floor(ShopCountdown / 60)
    secs := Mod(ShopCountdown, 60)
    TxtShopTimer.Text := (mins < 10 ? "0" mins : mins) ":" (secs < 10 ? "0" secs : secs)

    if (ShopCountdown <= 10)
        TxtShopTimer.SetFont("cF85149 bold")
    else if (ShopCountdown <= 45)
        TxtShopTimer.SetFont("cFFB347 bold")
    else
        TxtShopTimer.SetFont("c2EE5C0 bold")

    ; Format MM:SS Next Event (cycle relatif autonome de 5 min)
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

    ; Décompte indicatif Sélène (en violet)
    if (SeleneActive) {
        if (SeleneActiveRemaining > 0) {
            SeleneActiveRemaining--
            m := Floor(SeleneActiveRemaining / 60)
            s := Mod(SeleneActiveRemaining, 60)
            TxtSeleneTimer.Text := "ACTIVE " (m < 10 ? "0" m : m) ":" (s < 10 ? "0" s : s)
            TxtSeleneTimer.SetFont("cE088FF bold")
        } else {
            SeleneActive := false
            SeleneCountdown := 600
        }
    } else {
        if (SeleneCountdown > 0) {
            SeleneCountdown--
            m := Floor(SeleneCountdown / 60)
            s := Mod(SeleneCountdown, 60)
            TxtSeleneTimer.Text := "AWAY · " (m < 10 ? "0" m : m) ":" (s < 10 ? "0" s : s)
            TxtSeleneTimer.SetFont("cC084FC bold")
        } else {
            SeleneActive := true
            SeleneActiveRemaining := 240
        }
    }
}

; ==============================================================================
;   LANCEMENT DE LA PÊCHE (Un seul clic dans l'eau pour activer l'auto-fish du jeu)
; ==============================================================================
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

; ==============================================================================
;   CLIC SÉCURISÉ POSÉ PAR BOUTON CASH (ANTI-DÉSYNCHRONISATION ET TÉLÉPORTATION)
; ==============================================================================
BuyCashButton(bx, by) {
    global ClickIntervalMs, ClicksPerButton, IsRunning, IsExecutingShop
    if (!IsRunning || !IsExecutingShop)
        return

    ; 1. Déplacement en mode Event (vitesse 3) : génère de vrais événements WM_MOUSEMOVE successifs.
    ; Cela force Roblox à déclencher MouseLeave sur l'ancien bouton et MouseEnter sur le nouveau bouton !
    CoordMode("Mouse", "Client")
    SendMode("Event")
    SetMouseDelay(2)
    MouseMove(bx, by, 3)

    ; 2. Pause d'ancrage (250ms) pour laisser l'interface Roblox verrouiller le survol du bouton
    Sleep(250)
    if (!IsRunning || !IsExecutingShop)
        return

    ; 3. Clics avec COORDONNÉES EXPLICITES (bx, by) et maintien physique de 60ms
    ; (Empêche Windows et Roblox d'envoyer le clic aux anciennes coordonnées mémorisées)
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

    ; 4. Pause de repos après le bouton
    Sleep(200)
}

; ==============================================================================
;   SÉQUENCE COMPLÈTE D'ACHAT SHOP (VERSION PARFAITE DU 3 SEPTEMBRE)
; ==============================================================================
DoAutoBuySequence() {
    global IsExecutingShop, ShopOpenDelay, ScrollTicks
    global Buy_Cash1, Buy_Cash2, Buy_Cash3
    global Buy_Gems1, Buy_Gems2, Buy_Gems3
    global Buy_Mutation, Buy_FastCatch, Buy_Luck
    global AutoSwitchDesktop, DesktopStepsRight, DesktopSwitchDelayMs
    global TxtStatus, IsRunning

    if (IsExecutingShop)
        return
    IsExecutingShop := true

    ; 1. Basculement automatique vers le bureau de Roblox si activé
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

    TxtStatus.Text := "RÉVEIL ROBLOX..."
    TxtStatus.SetFont("cD29922 bold")

    ActivateRoblox()
    Sleep(800) ; Laisser Roblox sortir du mode veille du bureau virtuel et stabiliser les FPS

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

    ; Placer d'avance le curseur au centre de la zone du shop AVANT d'ouvrir
    scrollCenterX := Integer(cw * 0.50)
    scrollCenterY := Integer(ch * 0.38)
    SendMode("Event")
    SetMouseDelay(2)
    MouseMove(scrollCenterX, scrollCenterY, 3)
    Sleep(150)

    ; 2. Ouvrir le Shop avec 'E' bien maintenu (150ms) pour garantir la prise en compte
    TxtStatus.Text := "OUVERTURE SHOP..."
    Send("{e down}")
    Sleep(150)
    Send("{e up}")

    ; ATTENDRE que l'interface du shop apparaisse et se stabilise complètement
    Sleep(ShopOpenDelay)

    if (!IsRunning || !IsExecutingShop) {
        if (didSwitchDesktop)
            SwitchDesktopLeft(DesktopStepsRight)
        IsExecutingShop := false
        return
    }

    ; Pause de sécurité (le shop est maintenant 100% visible et le curseur est dessus)
    Sleep(300)
    Click(scrollCenterX, scrollCenterY) ; Clic focus garanti sur l'interface du shop !
    Sleep(150)

    ; 3. RESET DU CATALOGUE TOUT EN HAUT (Évite que la molette zoome la caméra !)
    TxtStatus.Text := "RESET HAUT..."
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

    ; Coordonnées exactes du shop (1024x576)
    col1_CashX := Integer(cw * 0.2744)
    col2_CashX := Integer(cw * 0.4541)
    col3_CashX := Integer(cw * 0.6328)

    s1_row1_Y := Integer(ch * 0.4653)   ; Écran 1 : Cash Potions
    s2_row1_Y := Integer(ch * 0.4340)   ; Écran 2 : Gems Potions
    s2_row2_Y := Integer(ch * 0.6806)   ; Écran 2 : Mutation / Fast Catch / Luck

    close_X := Integer(cw * 0.7871)     ; Croix rouge [X]
    close_Y := Integer(ch * 0.2049)

    ; --- ÉTAPE 1 : ACHAT CASH POTIONS (ÉCRAN 1) ---
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

    ; --- ÉTAPE 2 : DÉFILEMENT À LA MOLETTE (3 CRANS SUR LE CATALOGUE) ---
    needsScroll := (Buy_Gems1 || Buy_Gems2 || Buy_Gems3 || Buy_Mutation || Buy_FastCatch || Buy_Luck)
    if (needsScroll) {
        TxtStatus.Text := "SCROLL BAS..."
        SendMode("Event")
        SetMouseDelay(2)
        MouseMove(scrollCenterX, scrollCenterY, 3)
        Sleep(80)
        Click(scrollCenterX, scrollCenterY) ; Clic focus garanti sur l'interface
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
        Sleep(500) ; Laisser le défilement se stabiliser complètement

        ; --- ÉTAPE 3 : ACHAT GEMS POTIONS (ÉCRAN 2 - LIGNE 1) ---
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

        ; --- ÉTAPE 4 : ACHAT POTIONS SPÉCIALES (ÉCRAN 2 - LIGNE 2) ---
        if (Buy_Mutation && IsRunning && IsExecutingShop) {
            TxtStatus.Text := "Mutation..."
            BuyCashButton(col1_CashX, s2_row2_Y)
        }
        if (Buy_FastCatch && IsRunning && IsExecutingShop) {
            TxtStatus.Text := "Fast Catch..."
            BuyCashButton(col2_CashX, s2_row2_Y)
        }
        if (Buy_Luck && IsRunning && IsExecutingShop) {
            TxtStatus.Text := "Luck..."
            BuyCashButton(col3_CashX, s2_row2_Y)
        }

        ; Remettre le catalogue tout en haut pour le prochain tour
        SendMode("Event")
        SetMouseDelay(2)
        MouseMove(scrollCenterX, scrollCenterY, 3)
        Sleep(100)
        Loop ScrollTicks {
            Send("{WheelUp}")
            Sleep(50)
        }
        Sleep(200)
    }

    ; Pause essentielle pour laisser Roblox terminer les transactions
    Sleep(350)

    ; --- ÉTAPE 5 : FERMETURE DU SHOP PAR LA CROIX ROUGE [X] ---
    TxtStatus.Text := "FERMETURE SHOP..."
    SendMode("Event")
    SetMouseDelay(2)
    MouseMove(close_X, close_Y, 3)
    Sleep(200)
    Loop 2 {
        Click(close_X, close_Y, "Down")
        Sleep(50)
        Click(close_X, close_Y, "Up")
        Sleep(160)
    }
    Sleep(350)

    ; --- ÉTAPE 6 : RELANCER LA PÊCHE ---
    StartFishingClick()

    if (IsRunning) {
        TxtStatus.Text := "● PÊCHE ACTIVE"
        TxtStatus.SetFont("c2EE5C0 bold")
    } else {
        TxtStatus.Text := "● EN PAUSE"
        TxtStatus.SetFont("cC490C4 bold")
    }

    ; Revenir automatiquement sur votre bureau principal de travail
    if (didSwitchDesktop) {
        Sleep(250)
        SwitchDesktopLeft(DesktopStepsRight)
        Sleep(DesktopSwitchDelayMs)
        PlayBeep(900, 100)
    } else {
        PlayBeep(900, 100)
    }

    IsExecutingShop := false
}

; ==============================================================================
;   ANTI-AFK (Saut périodique toutes les 3 minutes)
; ==============================================================================
AntiAfkLoop() {
    global IsRunning, IsExecutingShop, LastAntiAfkTick, AntiAfkInterval
    global AutoSwitchDesktop, DesktopStepsRight, DesktopSwitchDelayMs

    if (!IsRunning || IsExecutingShop)
        return

    now := A_TickCount
    if ((now - LastAntiAfkTick) >= (AntiAfkInterval * 1000)) {
        LastAntiAfkTick := now

        didSwitch := false
        if (AutoSwitchDesktop && !WinActive("ahk_exe RobloxPlayerBeta.exe")) {
            SwitchDesktopRight(DesktopStepsRight)
            didSwitch := true
            Sleep(DesktopSwitchDelayMs)
        }

        ActivateRoblox()
        Sleep(250)

        ; Saut sur place
        Send("{Space down}")
        Sleep(100)
        Send("{Space up}")
        Sleep(250)

        if (didSwitch) {
            SwitchDesktopLeft(DesktopStepsRight)
            Sleep(DesktopSwitchDelayMs)
        }
    }
}

; ==============================================================================
;   CALIBRATION DISCRÈTE (F8)
; ==============================================================================
CalibrateWaterSpot() {
    global AutoSwitchDesktop, DesktopStepsRight, DesktopSwitchDelayMs
    didSwitch := false
    if (AutoSwitchDesktop && !WinActive("ahk_exe RobloxPlayerBeta.exe")) {
        SwitchDesktopRight(DesktopStepsRight)
        didSwitch := true
        Sleep(DesktopSwitchDelayMs)
    }

    ActivateRoblox()
    Sleep(250)
    MsgBox("CLIQUEZ DANS L'EAU :`n`nPlacez votre souris sur l'eau où vous voulez pêcher et faites un Clic Gauche.`nLa position sera enregistrée instantanément !", "Calibrer Spot de Pêche", "Iconi")

    KeyWait("LButton", "D")
    MouseGetPos(&mX, &mY)
    KeyWait("LButton", "U")

    RobloxPos := GetRobloxClientPos()
    if (RobloxPos.w > 0 && RobloxPos.h > 0) {
        global WaterRatioX := Round(mX / RobloxPos.w, 3)
        global WaterRatioY := Round(mY / RobloxPos.h, 3)
        IniWrite(WaterRatioX, IniPath, "Fishing_Settings", "WaterRatioX")
        IniWrite(WaterRatioY, IniPath, "Fishing_Settings", "WaterRatioY")
        MsgBox("Position enregistrée avec succès !`n(Ratio X: " WaterRatioX " | Ratio Y: " WaterRatioY ")", "Spot Enregistré !", "Iconi")
    }

    if (didSwitch) {
        SwitchDesktopLeft(DesktopStepsRight)
        Sleep(DesktopSwitchDelayMs)
    }
}

; ==============================================================================
;   UTILITAIRES ROBLOX
; ==============================================================================
IsRobloxActive() {
    return WinActive("ahk_exe RobloxPlayerBeta.exe") || WinActive("Roblox")
}

ActivateRoblox() {
    if WinExist("ahk_exe RobloxPlayerBeta.exe")
        WinActivate("ahk_exe RobloxPlayerBeta.exe")
    else if WinExist("Roblox")
        WinActivate("Roblox")
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

; ==============================================================================
;   TOGGLE START / PAUSE
; ==============================================================================
ToggleMacroState() {
    global IsRunning, TxtStatus, BtnToggle, IsExecutingShop
    global AutoSwitchDesktop, DesktopStepsRight, DesktopSwitchDelayMs
    IsRunning := !IsRunning
    if (IsRunning) {
        TxtStatus.Text := "● PÊCHE ACTIVE"
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
        StartFishingClick()

        if (didSwitch) {
            Sleep(250)
            SwitchDesktopLeft(DesktopStepsRight)
            Sleep(DesktopSwitchDelayMs)
        }
    } else {
        TxtStatus.Text := "● EN PAUSE"
        TxtStatus.SetFont("cC490C4 bold")
        BtnToggle.Text := "▶  DÉMARRER"
        PlayBeep(450, 200)
    }
}

; ==============================================================================
;   HOTKEYS
; ==============================================================================
F1:: ToggleMacroState()

F2:: {
    PlayBeep(300, 250)
    ExitApp()
}

F3:: {
    global ServerClockOffset
    curSec := Integer(A_Sec)
    curMin := Integer(A_Min)
    promptMsg := "Shop reset toutes les 5 min (:00, :05...)`nHeure : " curMin ":" (curSec < 10 ? "0" curSec : curSec) "`nOffset actuel : +" ServerClockOffset "s`nNouveau décalage :"
    inputVal := InputBox(promptMsg, "Offset Serveur", "w340 h200", String(ServerClockOffset))
    if (inputVal.Result != "Cancel" && Trim(inputVal.Value) != "") {
        ServerClockOffset := Integer(Trim(inputVal.Value))
        IniWrite(ServerClockOffset, IniPath, "Shop_Settings", "ServerClockOffsetSeconds")
        PlayBeep(600, 100)
    }
}

; [F4] Réinitialiser / Synchroniser le timer de l'événement à 05:00
F4:: ResetEventTimer()

ResetEventTimer() {
    global EventCountdown, TxtEventTimer
    EventCountdown := 300
    TxtEventTimer.Text := "05:00"
    TxtEventTimer.SetFont("cFFD166 bold")
    PlayBeep(700, 100)
}

; [F5] Tester manuellement la séquence d'achat au shop
F5:: DoAutoBuySequence()

; [F8] Calibrer le spot de pêche
F8:: CalibrateWaterSpot()

; ==============================================================================
;   HELPERS INI PARSING
; ==============================================================================
ParseIniInt(val, defaultVal := 0) {
    cleaned := Trim(RegExReplace(val, "^[ =]+", ""))
    return (cleaned != "" && IsInteger(cleaned)) ? Integer(cleaned) : defaultVal
}

ParseIniFloat(val, defaultVal := 0.0) {
    cleaned := Trim(RegExReplace(val, "^[ =]+", ""))
    return (cleaned != "" && IsNumber(cleaned)) ? Float(cleaned) : defaultVal
}

; ==============================================================================
;   CHARGEMENT DE CONFIG.INI
; ==============================================================================
LoadConfig() {
    global
    if !FileExist(IniPath)
        return

    ; Potions Ligne 1 (Cash)
    Buy_Cash1 := ParseIniInt(IniRead(IniPath, "Potions_Ligne1", "Buy_Cash_Lvl1", 1), 1)
    Buy_Cash2 := ParseIniInt(IniRead(IniPath, "Potions_Ligne1", "Buy_Cash_Lvl2", 1), 1)
    Buy_Cash3 := ParseIniInt(IniRead(IniPath, "Potions_Ligne1", "Buy_Cash_Lvl3", 1), 1)

    ; Potions Ligne 2 (Gems)
    Buy_Gems1 := ParseIniInt(IniRead(IniPath, "Potions_Ligne2", "Buy_Gems_Lvl1", 1), 1)
    Buy_Gems2 := ParseIniInt(IniRead(IniPath, "Potions_Ligne2", "Buy_Gems_Lvl2", 1), 1)
    Buy_Gems3 := ParseIniInt(IniRead(IniPath, "Potions_Ligne2", "Buy_Gems_Lvl3", 1), 1)

    ; Potions Ligne 3 (Spéciales)
    Buy_Mutation := ParseIniInt(IniRead(IniPath, "Potions_Ligne3", "Buy_Mutation_Lvl1", 1), 1)
    Buy_FastCatch := ParseIniInt(IniRead(IniPath, "Potions_Ligne3", "Buy_FastCatch_Lvl1", 1), 1)
    Buy_Luck := ParseIniInt(IniRead(IniPath, "Potions_Ligne3", "Buy_Luck_Lvl1", 1), 1)

    ; Réglages Shop
    ClicksPerButton := ParseIniInt(IniRead(IniPath, "Shop_Settings", "ClicksPerButton", 3), 3)
    ClickIntervalMs := ParseIniInt(IniRead(IniPath, "Shop_Settings", "ClickIntervalMs", 700), 700)
    ServerClockOffset := ParseIniInt(IniRead(IniPath, "Shop_Settings", "ServerClockOffsetSeconds", 7), 7)
    ShopOpenDelay := ParseIniInt(IniRead(IniPath, "Shop_Settings", "ShopOpenDelayMs", 4000), 4000)
    ScrollTicks := ParseIniInt(IniRead(IniPath, "Shop_Settings", "ScrollWheelTicks", 3), 3)

    ; Bureau Virtuel
    AutoSwitchDesktop := ParseIniInt(IniRead(IniPath, "Virtual_Desktop", "AutoSwitchDesktop", 1), 1)
    DesktopStepsRight := ParseIniInt(IniRead(IniPath, "Virtual_Desktop", "DesktopStepsRight", 2), 2)
    DesktopSwitchDelayMs := ParseIniInt(IniRead(IniPath, "Virtual_Desktop", "DesktopSwitchDelayMs", 350), 350)

    ; Pêche & Anti-AFK
    AntiAfkInterval := ParseIniInt(IniRead(IniPath, "Fishing_Settings", "AntiAfkIntervalSeconds", 180), 180)
    WaterRatioX := ParseIniFloat(IniRead(IniPath, "Fishing_Settings", "WaterRatioX", 0.324), 0.324)
    WaterRatioY := ParseIniFloat(IniRead(IniPath, "Fishing_Settings", "WaterRatioY", 0.556), 0.556)
    EnableSoundBeep := ParseIniInt(IniRead(IniPath, "Sound_Settings", "EnableSoundBeep", 0), 0)
    EventClockOffset := ParseIniInt(IniRead(IniPath, "Event_Settings", "EventClockOffsetSeconds", 0), 0)
}
