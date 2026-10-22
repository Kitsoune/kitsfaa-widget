#Requires AutoHotkey v2.0+
#SingleInstance Force

#include Lib\OCR.ahk

CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")
CoordMode("ToolTip", "Screen")
SendMode("Event")
SetMouseDelay(2)

global AppVersion := "4.8"
global IniPath := A_ScriptDir "\config.ini"
global IsRunning := false
global IsExecutingShop := false
global ManualAction := false

global ShopMode := "Boosts"
global ServerClockOffset := 7
global LastBoostCycle := -1
global LastSeleneCycle := -1
global SeleneDurationMinutes := 5
global SeleneClockOffsetSeconds := 0
global SeleneBuyAtSeconds := [30, 150]
global SeleneActive := false

global ClicksPerButton := 3
global ClickIntervalMs := 700
global ShopOpenDelay := 4000
global ScrollSettleMs := 450

global EnableAutoRebirth := 1
global RebirthIntervalMinutes := 60
global LastRebirthTick := A_TickCount

global AutoSwitchDesktop := 0
global DesktopStepsRight := 2
global DesktopSwitchDelayMs := 350

global WaterRatioX := 0.324
global WaterRatioY := 0.556
global AntiAfkInterval := 180
global LastAntiAfkTick := A_TickCount
global EnableSoundBeep := 0

global EnableRodAbility := 1
global RodAbilityKey := "v"
global RodAbilityCooldownSeconds := 481
global RodAbilityReadyTick := A_TickCount

global EnableAutoFishWatchdog := 1
global AutoFishCheckSeconds := 5
global AutoFishColorTolerance := 60
global AutoFishOffCount := 0
global AutoFishHiddenCount := 0
global AutoFishRestarts := 0
global LastAutoFishTick := 0

global EnableHallowsEve := 1
global EventCharSlot := 2
global NormalCharSlot := 0
global CheckIntervalSeconds := 4
global EventRatioX := 0.35
global EventRatioY := 0.04
global EventRatioW := 0.30
global EventRatioH := 0.12
global IsHallowsEveActive := false
global EventCharOut := false
global HallowsEndTick := 0
global HallowsEveMissCount := 0
global HallowsAwayUntil := 0
global LastOcrCheckTick := 0

global WizardRunning := false
global WizardActive := false
global WizardKey := ""
global WizardPrompt := ""
global WizardTicks := 0
global WizardScrollEnabled := false
global SetupGui := ""
global OptionsGui := ""
global DisclaimerText := "FAA Macro is a free, unofficial, fan-made tool, provided as is, without any warranty.`n`n"
    . "It clicks and buys in the game for you. A game update, lag, a changed shop layout or a bug can make it click the wrong button, buy the wrong item, spend your in-game currency or open a Robux purchase window.`n`n"
    . "By using the widget and the macro, you accept to do so at your own risk. The developer is not responsible for any unwanted purchase, any loss of items or currency, or any action taken against your account."

global DefaultPoints := Map(
    "Boost.Cash1", "0,0.2744,0.4653", "Boost.Cash2", "0,0.4541,0.4653", "Boost.Cash3", "0,0.6328,0.4653",
    "Boost.Gems1", "2,0.2744,0.4730", "Boost.Gems2", "2,0.4541,0.4730", "Boost.Gems3", "2,0.6328,0.4730",
    "Boost.Mutation", "4,0.2744,0.4960", "Boost.FastCatch", "4,0.4541,0.4960", "Boost.Luck", "4,0.6328,0.4960",
    "Boost.Close", "0,0.7871,0.2049",
    "Selene.Luck3", "0,0.274,0.470", "Selene.Heavens", "2,0.450,0.448",
    "Selene.Luck2", "2,0.635,0.448", "Selene.Food1", "2,0.450,0.680",
    "Selene.Close", "0,0.788,0.190",
    "Rebirth.Open", "0,0.034,0.408", "Rebirth.Confirm", "0,0.356,0.725", "Rebirth.Close", "0,0.754,0.174"
)

global BoostItems := [
    ShopItem("Boost.Cash1", "Cash Potion Lvl 1", "Potions_Row1", "Buy_Cash_Lvl1"),
    ShopItem("Boost.Cash2", "Cash Potion Lvl 2", "Potions_Row1", "Buy_Cash_Lvl2"),
    ShopItem("Boost.Cash3", "Cash Potion Lvl 3", "Potions_Row1", "Buy_Cash_Lvl3"),
    ShopItem("Boost.Gems1", "Gems Potion Lvl 1", "Potions_Row2", "Buy_Gems_Lvl1"),
    ShopItem("Boost.Gems2", "Gems Potion Lvl 2", "Potions_Row2", "Buy_Gems_Lvl2"),
    ShopItem("Boost.Gems3", "Gems Potion Lvl 3", "Potions_Row2", "Buy_Gems_Lvl3"),
    ShopItem("Boost.Mutation", "Mutation Potion", "Potions_Row3", "Buy_Mutation_Lvl1"),
    ShopItem("Boost.FastCatch", "Fast Catch Potion", "Potions_Row3", "Buy_FastCatch_Lvl1"),
    ShopItem("Boost.Luck", "Luck Potion Lvl 1", "Potions_Row3", "Buy_Luck_Lvl1")
]

global SeleneSlots := Map("Selene.Luck3", 1, "Selene.Heavens", 5, "Selene.Luck2", 6, "Selene.Food1", 8)

global SeleneItems := [
    ShopItem("Selene.Luck3", "Luck Potion Lvl 3", "Selene_Potions", "Buy_Luck_Lvl3", true),
    ShopItem("Selene.Heavens", "Heaven's Collide Potion", "Selene_Potions", "Buy_HeavensCollide", true),
    ShopItem("Selene.Luck2", "Luck Potion Lvl 2", "Selene_Potions", "Buy_Luck_Lvl2", true),
    ShopItem("Selene.Food1", "Food Potion Lvl 1", "Selene_Potions", "Buy_Food_Lvl1", true)
]

global UpdateRepo := "Kitsoune/kitsfaa-widget"
global UpdateRequest := ""
global ThemeId := "nino"
global Themes := Map(
    "nino", {name: "Nino Nakano", colors: Map()},
    "celestia", {name: "Celestia Ludenberg", colors: Map(
        "F7D4E8", "FFFFFF", "A88BB5", "8E8282", "C9A0C9", "C8BEBE", "BFAACF", "D9CFCF",
        "7EE8C8", "F2F2F2", "F49AC1", "FF4545", "C9A0FF", "B39A9A", "FFD166", "E3B65C",
        "FF9D00", "FF4545", "C490C4", "9A8C8C", "6E5A7A", "5C4E4E", "8C7799", "7D6E6E",
        "160F1E", "120A0B", "2A1D36", "2A1415", "B0569A", "BA0000", "F2E6F7", "F2EAEA")},
    "kaneki", {name: "Tokyo Ghoul · Kaneki", colors: Map(
        "F7D4E8", "FFFEFE", "A88BB5", "B4B4B4", "C9A0C9", "BDBDBD", "BFAACF", "D4D4D4",
        "7EE8C8", "FFFEFE", "F49AC1", "FC2A2A", "C9A0FF", "A6A6A6", "FFD166", "FF7070",
        "FF9D00", "FC2A2A", "C490C4", "8C8C8C", "6E5A7A", "4D4D4D", "8C7799", "707070",
        "160F1E", "0C0C0C", "2A1D36", "1C1C1C", "B0569A", "C80000", "F2E6F7", "F0F0F0")}
)

LoadConfig()

global WidgetGui := Gui("-Caption +AlwaysOnTop +ToolWindow -DPIScale", "Fish an Anime RNG · KITS Progress Inc.")
WidgetGui.BackColor := "0x010101"
WidgetGui.MarginX := 0
WidgetGui.MarginY := 0

if FileExist(ThemeImage())
    WidgetGui.Add("Picture", "x0 y0 w452 h326", ThemeImage())

AddText("x106 y21 w196 h20 Center", "FISH AN ANIME RNG", "F7D4E8", "s10 bold")
AddText("x126 y41 w200 h14 Center", "KITS Progress Inc. · v" AppVersion, "A88BB5", "s7")
AddText("x304 y21 w18 h20 Center", "ⓘ", "C9A0C9", "s9 bold").OnEvent("Click", (*) => ShowInfo())
AddText("x322 y21 w20 h20 Center", "✕", "C9A0C9", "s9 bold").OnEvent("Click", (*) => ExitApp())

for i, label in ["BOOST SHOP", "SELENE", "ROD ABILITY", "HALLOWS EVE", "AUTO FISH"]
    AddText("x100 y" (RowY(i - 1) + 4) " w110 h16", label, "BFAACF", "s8 bold")

global TxtShopTimer := AddRowValue(0, "05:00", "7EE8C8")
global TxtSeleneTimer := AddRowValue(1, "AWAY · 30:00", "C9A0FF")
global TxtRodAbilityTimer := AddRowValue(2, FormatMMSS(RodAbilityCooldownSeconds), "FFD166")
global TxtHallowsEveStatus := AddRowValue(3, "● INACTIVE", "BFAACF", "s8 bold", "Segoe UI")
global TxtAutoFish := AddRowValue(4, "-", "BFAACF", "s8 bold", "Segoe UI")
TxtRodAbilityTimer.OnEvent("Click", (*) => ManualTriggerRodAbility())
TxtHallowsEveStatus.OnEvent("Click", (*) => ManualOcrCheck())

global TxtStatus := AddText("x82 y204 w288 h18 Center", "● PAUSED", "C490C4", "s9 bold")
global BtnToggle := AddText("x82 y226 w288 h32 Center 0x200", "▶  START", "FFFFFF", "s11 bold")
BtnToggle.OnEvent("Click", (*) => ToggleMacroState())

global BtnModeBoost := AddText("x82 y266 w90 h24 Center 0x200", "BOOST", "7EE8C8", "s8 bold")
global BtnModeSelene := AddText("x172 y266 w90 h24 Center 0x200", "SELENE", "6E5A7A", "s8 bold")
BtnModeBoost.OnEvent("Click", (*) => SetShopMode("Boosts"))
BtnModeSelene.OnEvent("Click", (*) => SetShopMode("Selene"))

AddText("x270 y266 w100 h24 Center 0x200", "⚙  SETUP", "F7D4E8", "s8 bold").OnEvent("Click", (*) => ShowSetupMenu())
AddText("x82 y296 w288 h14 Center", "F1 Start · F4 Setup · F5 Shop · F9 Rebirth · F2 Quit", "8C7799", "s7")

SetShopMode(ShopMode, false)
RefreshAutoFishText()

OnMessage(0x0201, WM_LBUTTONDOWN)
OnExit(SaveWidgetPos)

WidgetGui.Show(InitialWidgetPos() " w452 h326 NoActivate")
WinSetTransColor("010101", WidgetGui)

if !IniInt("Widget", "DisclaimerAccepted", 0) {
    if (MsgBox(DisclaimerText "`n`nDo you accept these terms?", "FAA Macro · Disclaimer", "YesNo Icon! 0x40000") != "Yes")
        ExitApp()
    IniWrite(1, IniPath, "Widget", "DisclaimerAccepted")
}

SetTimer(TimerSecondTick, 1000)
if IniInt("Updates", "CheckOnStart", 1)
    SetTimer(CheckForUpdate, -3000)

if (IniRead(IniPath, "Routine", "SetupShown", "0") = "0") {
    IniWrite(1, IniPath, "Routine", "SetupShown")
    SetTimer(() => ShowSetupMenu(true), -700)
}

ShopItem(id, label, section, key, guard := false) => {id: id, label: label, section: section, key: key, buy: 1, guard: guard}

RowY(i) => 72 + 26 * i

AddText(opts, text, color, font := "s8 bold", face := "Segoe UI") {
    ctrl := WidgetGui.Add("Text", opts " BackgroundTrans c" Tc(color), text)
    ctrl.SetFont(font, face)
    return ctrl
}

AddRowValue(row, text, color, font := "s9 bold", face := "Consolas") => AddText("x206 y" (RowY(row) + 3) " w156 h17 Right", text, color, font, face)

FormatMMSS(sec) => Format("{:02d}:{:02d}", sec // 60, Mod(sec, 60))

SetFontColor(ctrl, color, weight := "bold") => ctrl.SetFont("c" Tc(color) " " weight)

Tc(color) => Themes[ThemeId].colors.Has(color) ? Themes[ThemeId].colors[color] : color

ShowInfo() => MsgBox("FAA Macro v" AppVersion " · KITS Progress Inc.`nTheme: " Themes[ThemeId].name "`n`n" DisclaimerText, "FAA Macro · Info", "Iconi 0x40000")

ThemeImage() => A_ScriptDir "\assets\themes\" ThemeId "\widget_full.bmp"

ShowThemeMenu() {
    m := Menu()
    for id, theme in Themes {
        m.Add(theme.name, ApplyTheme.Bind(id))
        if (id = ThemeId)
            m.Check(theme.name)
    }
    m.Show()
}

ApplyTheme(id, *) {
    if (id = ThemeId || IsExecutingShop)
        return
    IniWrite(id, IniPath, "Widget", "Theme")
    Reload()
}

CheckForUpdate() {
    global UpdateRequest
    try {
        UpdateRequest := ComObject("WinHttp.WinHttpRequest.5.1")
        UpdateRequest.Open("GET", "https://api.github.com/repos/" UpdateRepo "/releases/latest", true)
        UpdateRequest.SetRequestHeader("User-Agent", "FAA-Macro")
        UpdateRequest.Send()
        SetTimer(PollUpdateCheck, 500)
    }
}

PollUpdateCheck() {
    static waited := 0
    try done := UpdateRequest.WaitForResponse(0)
    catch {
        SetTimer(PollUpdateCheck, 0)
        return
    }
    if !done {
        if ((waited += 500) >= 15000)
            SetTimer(PollUpdateCheck, 0)
        return
    }
    SetTimer(PollUpdateCheck, 0)
    try {
        if (UpdateRequest.Status != 200)
            return
        body := UpdateRequest.ResponseText
    } catch
        return
    if (RegExMatch(body, '"tag_name"\s*:\s*"v?([\d.]+)"', &m) && IsNewerVersion(m[1], AppVersion))
        OfferUpdate(m[1], body)
}

IsNewerVersion(remote, current) {
    r := StrSplit(remote, "."), c := StrSplit(current, ".")
    Loop Max(r.Length, c.Length) {
        a := A_Index <= r.Length && IsInteger(r[A_Index]) ? Integer(r[A_Index]) : 0
        b := A_Index <= c.Length && IsInteger(c[A_Index]) ? Integer(c[A_Index]) : 0
        if (a != b)
            return a > b
    }
    return false
}

OfferUpdate(version, body) {
    Log("Update available: v" version)
    intro := "FAA Macro v" version " is available (you have v" AppVersion ").`n`n"
    if DirExist(A_ScriptDir "\.git") {
        if (MsgBox(intro "This folder is a git clone, so it is not replaced. Open the release page?", "FAA Update", "YesNo Iconi") = "Yes")
            Run("https://github.com/" UpdateRepo "/releases/latest")
        return
    }
    if (MsgBox(intro "Download and install it now?`nYour config.ini and recorded routine are kept, then the macro restarts.", "FAA Update", "YesNo Iconi") != "Yes")
        return
    url := RegExMatch(body, '"browser_download_url"\s*:\s*"([^"]+\.zip)"', &z) ? z[1] : "https://github.com/" UpdateRepo "/raw/v" version "/releases/FAA-Macro-v" version ".zip"
    InstallUpdate(version, url)
}

InstallUpdate(version, url) {
    work := A_Temp "\faa-update"
    try {
        if DirExist(work)
            DirDelete(work, true)
        DirCreate(work)
        Download(url, work "\update.zip")
        RunWait("powershell -NoProfile -Command `"Expand-Archive -LiteralPath '" work "\update.zip' -DestinationPath '" work "\files' -Force`"", , "Hide")
        src := work "\files"
        Loop Files src "\*", "D"
            if FileExist(A_LoopFileFullPath "\FAA_Macro.ahk")
                src := A_LoopFileFullPath
        if !FileExist(src "\FAA_Macro.ahk")
            throw Error("FAA_Macro.ahk is missing from the downloaded zip")
        DirCopy(src, A_ScriptDir, 1)
    } catch as e {
        Log("Update failed: " e.Message)
        MsgBox("The update could not be installed:`n" e.Message "`n`nThe release page opens so you can download it by hand.", "FAA Update", "Icon!")
        Run("https://github.com/" UpdateRepo "/releases/latest")
        return
    }
    Log("Updated to v" version)
    Reload()
}

SetStatus(text, color) {
    TxtStatus.Text := text
    SetFontColor(TxtStatus, color)
}

InitialWidgetPos() {
    x := ParseIniInt(IniRead(IniPath, "Widget", "PosX", ""), A_ScreenWidth - 462)
    y := ParseIniInt(IniRead(IniPath, "Widget", "PosY", ""), 20)
    x := Max(0, Min(x, A_ScreenWidth - 120))
    y := Max(0, Min(y, A_ScreenHeight - 120))
    return "x" x " y" y
}

SaveWidgetPos(*) {
    try {
        WinGetPos(&x, &y, , , WidgetGui)
        IniWrite(x, IniPath, "Widget", "PosX")
        IniWrite(y, IniPath, "Widget", "PosY")
    }
}

WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    if (hwnd = WidgetGui.Hwnd)
        PostMessage(0xA1, 2, 0, , "ahk_id " WidgetGui.Hwnd)
}

PlayBeep(freq, dur) {
    if (EnableSoundBeep)
        SoundBeep(freq, dur)
}

RobloxClient() {
    hwnd := WinExist("ahk_exe RobloxPlayerBeta.exe") || WinExist("Roblox")
    if !hwnd
        return {hwnd: 0, x: 0, y: 0, w: 0, h: 0}
    WinGetClientPos(&x, &y, &w, &h, hwnd)
    return {hwnd: hwnd, x: x, y: y, w: w, h: h}
}

ActivateRoblox() {
    rc := RobloxClient()
    if rc.hwnd
        WinActivate("ahk_id " rc.hwnd)
}

ToScreen(rc, rx, ry) => ({x: rc.x + Integer(rc.w * rx), y: rc.y + Integer(rc.h * ry)})

MoveTo(rc, rx, ry) {
    p := ToScreen(rc, rx, ry)
    MouseMove(p.x, p.y, 3)
}

ClickAt(rc, rx, ry) {
    p := ToScreen(rc, rx, ry)
    MouseMove(p.x, p.y, 3)
    Sleep(150)
    Click(p.x, p.y)
}

SwitchDesktop(dir, steps) {
    Loop steps {
        Send("^#{" dir "}")
        Sleep(DesktopSwitchDelayMs)
    }
}

EnterRoblox() {
    didSwitch := false
    if (AutoSwitchDesktop && !WinActive("ahk_exe RobloxPlayerBeta.exe")) {
        SwitchDesktop("Right", DesktopStepsRight)
        didSwitch := true
    }
    ActivateRoblox()
    Sleep(400)
    return didSwitch
}

LeaveRoblox(didSwitch) {
    if didSwitch
        SwitchDesktop("Left", DesktopStepsRight)
}

BeginAction() {
    global IsExecutingShop
    if IsExecutingShop
        return false
    IsExecutingShop := true
    WinSetExStyle("+0x20", WidgetGui)
    return true
}

EndAction() {
    global IsExecutingShop, ManualAction
    IsExecutingShop := false
    ManualAction := false
    WinSetExStyle("-0x20", WidgetGui)
}

ActionAlive() => IsExecutingShop && (IsRunning || ManualAction)

Log(msg) {
    try FileAppend(FormatTime(, "yyyy-MM-dd HH:mm:ss") "  " msg "`n", A_ScriptDir "\macro.log", "UTF-8")
}

ResumeFishing() {
    if IsRunning
        SetStatus("● FISHING ACTIVE", "7EE8C8")
    else
        SetStatus("● PAUSED", "C490C4")
}

ParsePoint(str) {
    parts := StrSplit(str, ",", " `t")
    if (parts.Length = 2)
        parts.InsertAt(1, "0")
    if (parts.Length != 3 || !IsInteger(parts[1]) || !IsNumber(parts[2]) || !IsNumber(parts[3]))
        return ""
    return {t: Integer(parts[1]), x: Float(parts[2]), y: Float(parts[3])}
}

GetPoint(id) {
    p := ParsePoint(IniRead(IniPath, "Routine", id, ""))
    return IsObject(p) ? p : ParsePoint(DefaultPoints[id])
}

IsRecorded(section, key) => IniRead(IniPath, section, key, "") != ""

TimerSecondTick() {
    global LastBoostCycle, LastSeleneCycle, SeleneActive
    global LastOcrCheckTick, LastAntiAfkTick, LastRebirthTick, LastAutoFishTick

    curHour := Integer(A_Hour), curMin := Integer(A_Min), curSec := Integer(A_Sec)
    idle := IsRunning && !IsExecutingShop

    boostPos := Mod(curMin, 5) * 60 + curSec
    boostLeft := Mod(300 - boostPos, 300)
    TxtShopTimer.Text := FormatMMSS(boostLeft)
    SetFontColor(TxtShopTimer, boostLeft <= 10 ? "F85149" : boostLeft <= 45 ? "FFB347" : "7EE8C8")

    boostCycle := curHour * 12 + curMin // 5
    if (idle && ShopMode = "Boosts" && LastBoostCycle != boostCycle
        && boostPos >= ServerClockOffset && boostPos < ServerClockOffset + 45) {
        LastBoostCycle := boostCycle
        Log("Boost restock trigger (+" boostPos "s)")
        SetTimer(DoAutoBuySequence, -50)
    }

    selSecOfDay := curHour * 3600 + curMin * 60 + curSec - SeleneClockOffsetSeconds + 86400
    selPos := Mod(selSecOfDay, 1800)
    selCycle := selSecOfDay // 1800
    selDur := SeleneDurationMinutes * 60
    SeleneActive := selPos < selDur
    if SeleneActive {
        TxtSeleneTimer.Text := "ACTIVE · " FormatMMSS(selDur - selPos)
        SetFontColor(TxtSeleneTimer, "F49AC1")
        if (idle && ShopMode = "Selene") {
            for i, at in SeleneBuyAtSeconds {
                key := selCycle * 10 + i
                if ((LastSeleneCycle // 10 != selCycle || LastSeleneCycle < key) && selPos >= at && selPos < selDur - 20) {
                    LastSeleneCycle := key
                    Log("Selene trigger #" i " (" FormatMMSS(selPos) " after arrival)")
                    SetTimer(DoAutoBuySequence, -50)
                    break
                }
            }
        }
    } else {
        TxtSeleneTimer.Text := "AWAY · " FormatMMSS(1800 - selPos)
        SetFontColor(TxtSeleneTimer, "C9A0FF")
    }

    if EnableRodAbility
        UpdateRodAbility(idle, Mod(curSec, 2) = 0)

    if (IsHallowsEveActive && HallowsEndTick)
        SetHallowsHud(true)

    nowTick := A_TickCount

    if (EnableHallowsEve && !IsExecutingShop && nowTick - LastOcrCheckTick >= CheckIntervalSeconds * 1000) {
        LastOcrCheckTick := nowTick
        CheckHallowsEveEvent()
    }

    if (EnableAutoFishWatchdog && idle && nowTick - LastAutoFishTick >= AutoFishCheckSeconds * 1000) {
        LastAutoFishTick := nowTick
        CheckAutoFish()
    }

    if (idle && nowTick - LastAntiAfkTick >= AntiAfkInterval * 1000) {
        LastAntiAfkTick := nowTick
        DoAntiAfkJump()
    }

    if (EnableAutoRebirth && idle && nowTick - LastRebirthTick >= RebirthIntervalMinutes * 60000) {
        LastRebirthTick := nowTick
        SetTimer(DoAutoRebirthSequence, -50)
    }
}

GetAutoFish() {
    parts := StrSplit(IniRead(IniPath, "Routine", "AutoFish", ""), ",", " `t")
    if (parts.Length != 4 || !IsNumber(parts[1]) || !IsNumber(parts[2]) || !IsInteger(parts[3]) || !IsInteger(parts[4]))
        return ""
    return {x: Float(parts[1]), y: Float(parts[2]), on: Integer(parts[3]), off: Integer(parts[4])}
}

ColorDist(a, b) {
    a := Integer(a), b := Integer(b)
    dr := ((a >> 16) & 0xFF) - ((b >> 16) & 0xFF)
    dg := ((a >> 8) & 0xFF) - ((b >> 8) & 0xFF)
    db := (a & 0xFF) - (b & 0xFF)
    return Sqrt(dr * dr + dg * dg + db * db)
}

SetAutoFishText(text, color) {
    TxtAutoFish.Text := text
    SetFontColor(TxtAutoFish, color)
}

GetClickToFish() {
    parts := StrSplit(IniRead(IniPath, "Routine", "ClickToFish", ""), ",", " `t")
    if (parts.Length != 3 || !IsNumber(parts[1]) || !IsNumber(parts[2]) || !IsInteger(parts[3]))
        return ""
    return {x: Float(parts[1]), y: Float(parts[2]), color: Integer(parts[3])}
}

ClickToFishVisible(rc, ctf) => IsObject(ctf) && ColorDist(SampleArea(rc, ctf), ctf.color) <= AutoFishColorTolerance

RefreshAutoFishText() {
    if !EnableAutoFishWatchdog
        SetAutoFishText("WATCHDOG OFF", "8C7799")
    else if !IsObject(GetClickToFish())
        SetAutoFishText("CLICK TO FISH · F4", "FFB347")
    else
        SetAutoFishText(AutoFishRestarts ? "● FISHING · " AutoFishRestarts "↻" : "● FISHING", "7EE8C8")
}

AutoFishState(rc, af) {
    if !IsObject(af)
        return "unknown"
    color := SampleArea(rc, af)
    dOn := ColorDist(color, af.on)
    dOff := ColorDist(color, af.off)
    tolerance := AutoFishTolerance(af)
    if (dOn <= tolerance && dOn <= dOff)
        return "on"
    return dOff <= tolerance ? "off" : "hidden"
}

CheckAutoFish() {
    global AutoFishOffCount, AutoFishHiddenCount, AutoFishRestarts
    af := GetAutoFish()
    ctf := GetClickToFish()
    if (!IsObject(af) && !IsObject(ctf)) {
        RefreshAutoFishText()
        return
    }
    rc := RobloxClient()
    if (!rc.hwnd || rc.w < 200 || !WinActive("ahk_id " rc.hwnd))
        return

    state := AutoFishState(rc, af)
    if (state = "on") {
        AutoFishOffCount := 0
        AutoFishHiddenCount := 0
        RefreshAutoFishText()
        return
    }
    if (state = "off") {
        AutoFishHiddenCount := 0
        AutoFishOffCount++
        SetAutoFishText("○ AUTO FISH OFF", "FFB347")
        if (AutoFishOffCount >= 2) {
            AutoFishOffCount := 0
            AutoFishRestarts++
            ClickAt(rc, af.x, af.y)
            Log("Watchdog: Auto Fish was OFF, clicked it")
            SetAutoFishText("↻ RESTARTED", "F49AC1")
        }
        return
    }

    AutoFishOffCount := 0
    ctfVisible := ClickToFishVisible(rc, ctf)
    if (state = "unknown" && !ctfVisible) {
        AutoFishHiddenCount := 0
        RefreshAutoFishText()
        return
    }

    AutoFishHiddenCount++
    SetAutoFishText(ctfVisible ? "○ NOT FISHING" : "? HIDDEN", ctfVisible ? "FFB347" : "BFAACF")
    if (ctfVisible && AutoFishHiddenCount >= 2) {
        AutoFishHiddenCount := 0
        AutoFishRestarts++
        ClickAt(rc, ctf.x, ctf.y)
        Log("Watchdog: not fishing, clicked Click to Fish")
        SetAutoFishText("↻ RESTARTED", "F49AC1")
    }
}

DetectHallowsEveInRect(screenX, screenY, screenW, screenH) {
    assetPath := A_ScriptDir "\assets\hallows_eve.png"
    if FileExist(assetPath) {
        if ImageSearch(&fX, &fY, screenX, screenY, screenX + screenW, screenY + screenH, "*40 " assetPath)
            return {found: true, method: "ImageSearch", text: "[Matched assets\hallows_eve.png]"}
    }

    allText := ""
    for opts in [{scale: 1.0}, {scale: 1.0, grayscale: 1}, {scale: 1.4}, {scale: 1.0, monochrome: 150}, {scale: 1.0, invertcolors: 1}] {
        try {
            r := OCR.FromRect(screenX, screenY, screenW, screenH, opts)
            if (r && r.Text != "")
                allText .= r.Text " `n"
        }
    }
    return ClassifyEventText(allText)
}

ClassifyEventText(allText) {
    squashed := SquashOcr(allText)

    if RegExMatch(squashed, "g[ae]te|nightmare|gems|f[a-z]?[lt]{1,2}ing|[ob]lood|luckand|boosted", &hell)
        return {found: false, method: "Hell's Gates (" hell[0] ")", text: allText, hasTitle: false, hasDesc: false}

    hasDraculaMechanic := (InStr(squashed, "dracul") || InStr(squashed, "racula"))
        && (InStr(squashed, "turn") || InStr(squashed, "held") || InStr(squashed, "character"))
    if hasDraculaMechanic
        return {found: true, method: "OCR · Dracula description", text: allText, hasTitle: false, hasDesc: true}

    otherEvents := [
        "collide", "heaven", "angelic",
        "hell's gate", "hells gate", "hell's", "hells",
        "starfall", "sakura", "sub zero", "blizzard", "thunder",
        "sweet dream", "slime rain", "slime shower", "toxic waste", "forgotten ruin",
        "sad ending", "complex matrix", "cyberspace", "dreamspace",
        "lucrative", "realization", "limerence", "broken thought", "eclipse",
        "lunar", "solar", "blood moon", "blood", "radioactive", "foggy", "acid rain",
        "lucky river", "river"
    ]
    for ev in otherEvents {
        if InStr(squashed, SquashOcr(ev))
            return {found: false, method: "Other event (" ev ")", text: allText, hasTitle: false, hasDesc: false}
    }

    if InStr(squashed, "hallow")
        return {found: true, method: "OCR · Hallows title", text: allText, hasTitle: true, hasDesc: false}
    return {found: false, method: "Multi-Pass OCR", text: allText, hasTitle: false, hasDesc: false}
}

SquashOcr(text) => RegExReplace(RegExReplace(RegExReplace(StrLower(text), "[1i|!]", "l"), "0", "o"), "[^a-z]")

EventRect(rc) =>({x: rc.x + Integer(rc.w * EventRatioX), y: rc.y + Integer(rc.h * EventRatioY), w: Integer(rc.w * EventRatioW), h: Integer(rc.h * EventRatioH)})

HallowsActiveText() => "🎃 ACTIVE" (HallowsLeftSeconds() ? " · " FormatMMSS(HallowsLeftSeconds()) : IsRunning ? " (Slot " EventCharSlot ")" : "")

HallowsInactiveText() => (NormalCharSlot > 0 && NormalCharSlot != EventCharSlot) ? "● INACTIVE (Slot " NormalCharSlot ")" : "● INACTIVE"

SetHallowsHud(active) {
    TxtHallowsEveStatus.Text := active ? HallowsActiveText() : HallowsInactiveText()
    SetFontColor(TxtHallowsEveStatus, active ? "FF9D00" : "BFAACF")
}

ParseEventDuration(text) {
    best := 0
    pos := 1
    lower := StrLower(text)
    while (pos := RegExMatch(lower, "dura\w*\W{0,3}(\d{1,2})\s*[:.;]\s*(\d{2})", &m, pos)) {
        secs := Integer(m[1]) * 60 + Integer(m[2])
        if (Integer(m[2]) < 60 && secs > 0 && secs <= 900)
            best := Max(best, secs)
        pos += m.Len
    }
    return best
}

GetEventSlot() {
    parts := StrSplit(IniRead(IniPath, "Routine", "EventSlot", ""), ",", " `t")
    if (parts.Length != 4 || !IsNumber(parts[1]) || !IsNumber(parts[2]) || !IsInteger(parts[3]) || !IsInteger(parts[4]))
        return ""
    return {x: Float(parts[1]), y: Float(parts[2]), out: Integer(parts[3]), away: Integer(parts[4])}
}

EventCharState(rc, slot) {
    color := SampleArea(rc, slot)
    dOut := ColorDist(color, slot.out)
    dAway := ColorDist(color, slot.away)
    if (Min(dOut, dAway) > Max(AutoFishColorTolerance, ColorDist(slot.out, slot.away) * 0.45))
        return "unknown"
    return dOut <= dAway ? "out" : "away"
}

FocusRoblox() {
    rc := RobloxClient()
    if !rc.hwnd
        return false
    Loop 3 {
        WinActivate("ahk_id " rc.hwnd)
        if WinWaitActive("ahk_id " rc.hwnd, , 0.5)
            return true
    }
    try Log("Hallows Eve: Roblox is not in front ('" WinGetTitle("A") "'), key not sent")
    return false
}

PressEventKey(wantOut) {
    Sleep(120)
    PressHotbarSlot(wantOut || NormalCharSlot <= 0 || NormalCharSlot = EventCharSlot ? EventCharSlot : NormalCharSlot)
}

SetEventChar(wantOut) {
    global EventCharOut
    slot := GetEventSlot()
    if !IsObject(slot) {
        if (wantOut = EventCharOut || !FocusRoblox())
            return
        PressEventKey(wantOut)
        EventCharOut := wantOut
        Log(wantOut ? "Hallows Eve: event character OUT" : "Hallows Eve: event character AWAY")
        return
    }
    rc := RobloxClient()
    Loop 3 {
        state := EventCharState(rc, slot)
        if (state = (wantOut ? "out" : "away")) {
            if (EventCharOut != wantOut)
                Log(wantOut ? "Hallows Eve: event character OUT (seen on the hotbar)" : "Hallows Eve: event character AWAY (seen on the hotbar)")
            EventCharOut := wantOut
            return
        }
        if (state = "unknown" || !FocusRoblox())
            return
        PressEventKey(wantOut)
        Sleep(700)
    }
    Log("Hallows Eve: the event character is still " (wantOut ? "away" : "out") " after 3 key presses")
}

HallowsLeftSeconds() => HallowsEndTick ? Max(0, (HallowsEndTick - A_TickCount) // 1000) : 0

CheckHallowsEveEvent() {
    global IsHallowsEveActive, HallowsEveMissCount, HallowsEndTick, HallowsAwayUntil
    if (!EnableHallowsEve || IsExecutingShop)
        return

    rc := RobloxClient()
    if (!rc.hwnd || rc.w < 200 || rc.h < 200)
        return
    r := EventRect(rc)
    if (r.w <= 10 || r.h <= 10)
        return

    det := DetectHallowsEveInRect(r.x, r.y, r.w, r.h)

    if det.found {
        HallowsEveMissCount := 0
        if (secs := ParseEventDuration(det.text))
            HallowsEndTick := A_TickCount + (secs + 3) * 1000
        if !IsHallowsEveActive {
            IsHallowsEveActive := true
            SetHallowsHud(true)
            Log("Hallows Eve detected via " det.method (secs ? " (" FormatMMSS(secs) " left)" : "") " | OCR: " SubStr(RegExReplace(det.text, "\s+", " "), 1, 300))
        }
        if IsRunning
            SetEventChar(true)
        return
    }

    if !IsHallowsEveActive {
        if (IsRunning && A_TickCount < HallowsAwayUntil)
            SetEventChar(false)
        return
    }
    if (HallowsLeftSeconds() > 0)
        return
    HallowsEveMissCount++
    if (HallowsEveMissCount < (HallowsEndTick ? 1 : 3))
        return
    IsHallowsEveActive := false
    HallowsEveMissCount := 0
    HallowsEndTick := 0
    HallowsAwayUntil := A_TickCount + 60000
    SetHallowsHud(false)
    Log("Hallows Eve ended")
    if IsRunning
        SetEventChar(false)
}

ShowOcrResult(title, header, rect, det) {
    MsgBox(
        header "`n`n"
        "Zone: X=" rect.x " Y=" rect.y " W=" rect.w " H=" rect.h "`n"
        "Method: " det.method "`n"
        "Hallows Eve detected: " (det.found ? "YES 🎃" : "NO") "`n`n"
        "Recognized text:`n`"" Trim(det.text) "`"",
        title, "Iconi"
    )
}

ManualOcrCheck() {
    rc := RobloxClient()
    if (!rc.hwnd || rc.w < 200) {
        MsgBox("Roblox is not open.", "OCR Check", "Icon!")
        return
    }
    r := EventRect(rc)
    ShowOcrResult("OCR Check", "✦ OCR EVENT CHECK ✦", r, DetectHallowsEveInRect(r.x, r.y, r.w, r.h))
}

SetShopMode(mode, save := true) {
    global ShopMode := mode
    SetFontColor(BtnModeBoost, mode = "Boosts" ? "7EE8C8" : "6E5A7A")
    SetFontColor(BtnModeSelene, mode = "Selene" ? "F49AC1" : "6E5A7A")
    BtnModeBoost.Text := (mode = "Boosts" ? "● " : "") "BOOST"
    BtnModeSelene.Text := (mode = "Selene" ? "● " : "") "SELENE"
    if save {
        IniWrite(mode, IniPath, "Shop_Settings", "ShopMode")
        PlayBeep(650, 100)
    }
}

PressRodKey() {
    Send("{" RodAbilityKey " down}")
    Sleep(80)
    Send("{" RodAbilityKey " up}")
}

TriggerRodAbility() {
    if (!IsRunning || IsExecutingShop)
        return
    if !(WinActive("ahk_exe RobloxPlayerBeta.exe") || WinActive("Roblox")) {
        ActivateRoblox()
        Sleep(120)
    }
    PressRodKey()
}

RestartRodCooldown() {
    global RodAbilityReadyTick := A_TickCount + RodAbilityCooldownSeconds * 1000
}

GetAbilityButton() {
    parts := StrSplit(IniRead(IniPath, "Routine", "AbilityButton", ""), ",", " `t")
    if (parts.Length != 3 || !IsNumber(parts[1]) || !IsNumber(parts[2]) || !IsInteger(parts[3]))
        return ""
    return {x: Float(parts[1]), y: Float(parts[2]), color: Integer(parts[3])}
}

AbilityButtonReady() {
    ab := GetAbilityButton()
    rc := RobloxClient()
    if (!IsObject(ab) || !rc.hwnd || rc.w < 200 || !WinActive("ahk_id " rc.hwnd))
        return false
    return ColorDist(SampleArea(rc, ab), ab.color) <= AutoFishColorTolerance
}

UpdateRodAbility(idle, checkButton) {
    left := Max(0, (RodAbilityReadyTick - A_TickCount) // 1000)
    ready := left = 0 || (checkButton && AbilityButtonReady())
    if (ready && idle) {
        TriggerRodAbility()
        RestartRodCooldown()
        TxtRodAbilityTimer.Text := "ABILITY !"
        SetFontColor(TxtRodAbilityTimer, "FF9D00")
        return
    }
    TxtRodAbilityTimer.Text := ready ? "READY" : FormatMMSS(left)
    SetFontColor(TxtRodAbilityTimer, ready || left <= 15 ? "FF9D00" : "FFD166")
}

ManualTriggerRodAbility() {
    ActivateRoblox()
    Sleep(120)
    PressRodKey()
    RestartRodCooldown()
    TxtRodAbilityTimer.Text := "ACTIVATED !"
    SetFontColor(TxtRodAbilityTimer, "FF9D00")
    PlayBeep(850, 100)
}

PressHotbarSlot(slotNum) {
    if (slotNum <= 0)
        return
    SetKeyDelay(50, 70)
    Send("{" Format("sc{:03X}", slotNum + 1) "}")
}

StartFishingClick() {
    rc := RobloxClient()
    if (rc.w <= 100)
        return
    state := AutoFishState(rc, GetAutoFish())
    if (state = "on" || state = "off")
        return
    ctf := GetClickToFish()
    if ClickToFishVisible(rc, ctf)
        ClickAt(rc, ctf.x, ctf.y)
    else if !IsObject(ctf)
        ClickAt(rc, WaterRatioX, WaterRatioY)
}

DoAntiAfkJump() {
    if (!IsRunning || IsExecutingShop)
        return
    didSwitch := EnterRoblox()
    Send("{Space down}")
    Sleep(100)
    Send("{Space up}")
    Sleep(250)
    LeaveRoblox(didSwitch)
}

DoAutoRebirthSequence() {
    global LastRebirthTick
    if !BeginAction()
        return
    didSwitch := EnterRoblox()
    try {
        rc := RobloxClient()
        if (rc.w < 200 || rc.h < 200)
            return
        SetStatus("AUTO-REBIRTH...", "FF9D00")

        p := GetPoint("Rebirth.Open")
        ClickAt(rc, p.x, p.y)
        Sleep(700)
        if !ActionAlive()
            return

        p := GetPoint("Rebirth.Confirm")
        ClickAt(rc, p.x, p.y)
        Sleep(250)
        if !ActionAlive()
            return
        ClickAt(rc, p.x, p.y)
        Sleep(400)

        p := GetPoint("Rebirth.Close")
        Loop 3 {
            ClickAt(rc, p.x, p.y)
            Sleep(350)
        }

        LastRebirthTick := A_TickCount
        Log("Rebirth done")
        ResumeFishing()
    } finally {
        LeaveRoblox(didSwitch)
        EndAction()
    }
}

ShopSignature(rc) {
    sig := []
    for pt in [[0.35, 0.42], [0.50, 0.55], [0.65, 0.42]]
        sig.Push(SampleArea(rc, {x: pt[1], y: pt[2]}))
    return sig
}

ShopLooksOpen(rc, before) {
    changed := 0
    for i, color in ShopSignature(rc)
        changed += ColorDist(color, before[i]) > 45
    return changed >= 2
}

WaitShopOpen(rc, before) {
    start := A_TickCount
    while (A_TickCount - start < Max(ShopOpenDelay, 8000)) {
        if !ActionAlive()
            return false
        Sleep(250)
        if ShopLooksOpen(rc, before)
            return true
    }
    return false
}

OpenShop(rc) {
    MoveTo(rc, 0.50, 0.38)
    Sleep(150)
    before := ShopSignature(rc)
    opened := false
    Loop 2 {
        Send("{e down}")
        Sleep(150)
        Send("{e up}")
        if (opened := WaitShopOpen(rc, before))
            break
        if !ActionAlive()
            return false
    }
    Log(opened ? "Shop opened" : "Shop DID NOT open after 2 x E")
    if !opened {
        SetStatus("SHOP DID NOT OPEN", "F85149")
        return false
    }
    Sleep(800)
    MoveTo(rc, 0.50, 0.38)
    Sleep(150)
    Loop 15 {
        Send("{WheelUp}")
        Sleep(60)
    }
    Sleep(ScrollSettleMs)
    return ActionAlive()
}

ScrollShop(rc, delta) {
    if (delta = 0)
        return
    MoveTo(rc, 0.50, 0.38)
    Sleep(80)
    Loop Abs(delta) {
        if (!ActionAlive() && !WizardRunning)
            return
        Send(delta > 0 ? "{WheelDown}" : "{WheelUp}")
        Sleep(150)
    }
    Sleep(ScrollSettleMs)
}

BuyButton(rc, pt) {
    p := ToScreen(rc, pt.x, pt.y)
    MouseMove(p.x, p.y, 3)
    Sleep(250)
    Loop ClicksPerButton {
        if !ActionAlive()
            return
        Click(p.x, p.y, "Down")
        Sleep(60)
        Click(p.x, p.y, "Up")
        Sleep(ClickIntervalMs)
    }
    Sleep(200)
}

DoAutoBuySequence() {
    if !BeginAction()
        return
    didSwitch := EnterRoblox()
    try {
        rc := RobloxClient()
        if (rc.w < 200 || !ActionAlive())
            return
        isSelene := ShopMode = "Selene"
        SetStatus(isSelene ? "OPENING SELENE..." : "OPENING SHOP...", "D29922")
        if !OpenShop(rc)
            return

        scrolled := 0
        summary := ""
        shifted := false
        if isSelene {
            first := GetPoint("Selene.Luck3")
            ScrollShop(rc, first.t)
            scrolled := first.t
            if (shifted := RegExMatch(CardText(rc, first), "i)exclusive|obtained"))
                Log("Selene: character card in slot 1, every potion shifted by one slot")
        }
        for it in (isSelene ? SeleneItems : BoostItems) {
            if !ActionAlive()
                return
            if !it.buy
                continue
            p := shifted ? ShiftedSelenePoint(it.id) : GetPoint(it.id)
            ScrollShop(rc, p.t - scrolled)
            scrolled := p.t
            TxtStatus.Text := it.label "..."
            if it.guard {
                summary .= it.label ": " GuardedBuy(rc, it, p) " · "
                continue
            }
            BuyButton(rc, p)
            Log("  bought " it.label " at " Round(p.x, 3) "," Round(p.y, 3) " (scroll " p.t ")")
        }

        if (summary != "")
            Log("Selene summary: " RTrim(summary, " ·"))
        if !ActionAlive()
            return
        TxtStatus.Text := "CLOSING SHOP..."
        p := GetPoint(isSelene ? "Selene.Close" : "Boost.Close")
        ClickAt(rc, p.x, p.y)
        Sleep(600)
        ResumeFishing()
    } finally {
        LeaveRoblox(didSwitch)
        EndAction()
    }
}

ToggleMacroState() {
    global IsRunning
    global ManualAction
    if WizardRunning
        return
    if IsExecutingShop {
        IsRunning := false
        ManualAction := false
        SetStatus("■ STOPPED", "F85149")
        BtnToggle.Text := "▶  START"
        PlayBeep(300, 200)
        return
    }
    IsRunning := !IsRunning
    if !IsRunning {
        SetStatus("● PAUSED", "C490C4")
        BtnToggle.Text := "▶  START"
        PlayBeep(450, 200)
        return
    }

    SetStatus("● FISHING ACTIVE", "7EE8C8")
    BtnToggle.Text := "⏸  PAUSE"
    PlayBeep(750, 150)

    didSwitch := EnterRoblox()
    if EnableRodAbility {
        TriggerRodAbility()
        RestartRodCooldown()
    }
    SetHallowsHud(IsHallowsEveActive)
    SetEventChar(IsHallowsEveActive)
    StartFishingClick()
    LeaveRoblox(didSwitch)
}

CalibrateEventArea() {
    global EventRatioX, EventRatioY, EventRatioW, EventRatioH, IsHallowsEveActive

    didSwitch := EnterRoblox()
    rc := RobloxClient()
    if (rc.w <= 0 || rc.h <= 0) {
        MsgBox("Roblox is not open.", "Event Calibration", "Icon!")
        LeaveRoblox(didSwitch)
        return
    }

    ToolTip("Drag a box around the event banner · ESC to cancel", rc.x + 12, rc.y + 12)
    while !GetKeyState("LButton", "P") {
        if GetKeyState("Escape", "P") {
            ToolTip()
            LeaveRoblox(didSwitch)
            return
        }
        Sleep(20)
    }
    ToolTip()

    MouseGetPos(&startX, &startY)
    SelectGui := Gui("-Caption +AlwaysOnTop +ToolWindow -DPIScale +E0x20")
    SelectGui.BackColor := "0xEC78B0"
    WinSetTransparent(90, SelectGui)

    while GetKeyState("LButton", "P") {
        if GetKeyState("Escape", "P") {
            SelectGui.Destroy()
            LeaveRoblox(didSwitch)
            return
        }
        MouseGetPos(&curX, &curY)
        SelectGui.Show("x" Min(startX, curX) " y" Min(startY, curY) " w" Max(Abs(curX - startX), 1) " h" Max(Abs(curY - startY), 1) " NoActivate")
        Sleep(15)
    }

    MouseGetPos(&endX, &endY)
    SelectGui.Destroy()

    minX := Min(startX, endX), minY := Min(startY, endY)
    w := Abs(endX - startX), h := Abs(endY - startY)
    if (w < 15 || h < 15) {
        MsgBox("Selection too small, calibration cancelled.", "Event Calibration", "Icon!")
        LeaveRoblox(didSwitch)
        return
    }

    topY := Max(rc.y, minY - Integer(h * 0.35))
    fullH := minY + h - topY

    EventRatioX := Round((minX - rc.x) / rc.w, 3)
    EventRatioY := Round((topY - rc.y) / rc.h, 3)
    EventRatioW := Round(w / rc.w, 3)
    EventRatioH := Round(fullH / rc.h, 3)

    IniWrite(EventRatioX, IniPath, "Hallows_Eve", "EventRatioX")
    IniWrite(EventRatioY, IniPath, "Hallows_Eve", "EventRatioY")
    IniWrite(EventRatioW, IniPath, "Hallows_Eve", "EventRatioW")
    IniWrite(EventRatioH, IniPath, "Hallows_Eve", "EventRatioH")

    det := DetectHallowsEveInRect(minX, topY, w, fullH)
    IsHallowsEveActive := det.found
    SetHallowsHud(det.found)
    ShowOcrResult("Event Calibration", "Event box saved!", {x: minX, y: topY, w: w, h: fullH}, det)
    LeaveRoblox(didSwitch)
}

SetWizardKey(key) {
    global WizardKey := key
}

ShowWizardTip() {
    rc := RobloxClient()
    text := "✦ FAA SETUP ✦`n`n" WizardPrompt "`n`n"
    if WizardScrollEnabled
        text .= "↓ / ↑   scroll the shop   (scrolled: " WizardTicks ")`n"
    text .= "ENTER  confirm   ·   BACKSPACE  skip   ·   ESC  cancel`nThe macro never clicks while you aim."
    ToolTip(text, rc.x + 12, rc.y + 12)
}

WaitWizardKey(prompt) {
    global WizardKey, WizardActive, WizardPrompt
    WizardPrompt := prompt
    WizardKey := ""
    ShowWizardTip()
    WizardActive := true
    while (WizardKey = "")
        Sleep(30)
    WizardActive := false
    ToolTip()
    return WizardKey
}

WizardScroll(dir) {
    global WizardTicks
    if (!WizardScrollEnabled || (dir < 0 && WizardTicks <= 0))
        return
    MouseGetPos(&mx, &my)
    ScrollShop(RobloxClient(), dir)
    WizardTicks += dir
    MouseMove(mx, my, 0)
    ShowWizardTip()
}

CapturePoint(prompt) {
    Loop {
        key := WaitWizardKey(prompt)
        if (key != "enter")
            return key
        rc := RobloxClient()
        MouseGetPos(&mx, &my)
        rx := Round((mx - rc.x) / rc.w, 4)
        ry := Round((my - rc.y) / rc.h, 4)
        if (rx >= 0 && rx <= 1 && ry >= 0 && ry <= 1)
            return {x: rx, y: ry}
        SoundBeep(300, 150)
    }
}

Cancelled(result) => !IsObject(result) && result = "cancel"

SetupInfo(text) => MsgBox(text, "FAA Setup", "OKCancel Iconi") != "Cancel"

RecordWater() {
    global WaterRatioX, WaterRatioY
    r := CapturePoint("WATER SPOT`nAim at the water where you cast your rod, then press ENTER.")
    if !IsObject(r)
        return !Cancelled(r)
    WaterRatioX := r.x, WaterRatioY := r.y
    IniWrite(r.x, IniPath, "Fishing_Settings", "WaterRatioX")
    IniWrite(r.y, IniPath, "Fishing_Settings", "WaterRatioY")
    return true
}

SampleArea(rc, pt) {
    center := ToScreen(rc, pt.x, pt.y)
    r := 0, g := 0, b := 0, n := 0
    Loop 5 {
        dx := Integer((A_Index - 3) * rc.w * 0.012)
        Loop 3 {
            c := Integer(PixelGetColor(center.x + dx, center.y + Integer((A_Index - 2) * rc.h * 0.012)))
            r += (c >> 16) & 0xFF, g += (c >> 8) & 0xFF, b += c & 0xFF, n++
        }
    }
    return Format("0x{:06X}", ((r // n) << 16) | ((g // n) << 8) | (b // n))
}

SampleButton(rc, pt, waitMs) {
    MoveTo(rc, 0.50, 0.20)
    Sleep(waitMs)
    return SampleArea(rc, pt)
}

AutoFishTolerance(af) => Max(AutoFishColorTolerance, ColorDist(af.on, af.off) * 0.45)

RecordAutoFish() {
    r := CapturePoint("AUTO FISH BUTTON`nMake sure Auto Fish is ON, aim at the coloured part of its button, then press ENTER.`nThe macro will toggle it OFF and back ON to learn both colours.")
    if !IsObject(r)
        return !Cancelled(r)
    rc := RobloxClient()
    onColor := SampleButton(rc, r, 400)
    ClickAt(rc, r.x, r.y)
    offColor := SampleButton(rc, r, 1000)
    ClickAt(rc, r.x, r.y)
    backColor := SampleButton(rc, r, 1000)

    if (ColorDist(onColor, offColor) < 30 || ColorDist(backColor, onColor) > ColorDist(backColor, offColor)) {
        MsgBox("Could not tell Auto Fish ON from OFF at that spot.`n`nON " onColor "  ·  OFF " offColor "  ·  back ON " backColor "`n`nCheck that Auto Fish is ON right now, then record it again from SETUP while aiming at the middle of the button.", "FAA Setup", "Icon!")
        return true
    }
    IniWrite(r.x "," r.y "," onColor "," offColor, IniPath, "Routine", "AutoFish")
    RefreshAutoFishText()
    return true
}

RecordShop(isSelene) {
    global WizardTicks, WizardScrollEnabled
    items := isSelene ? SeleneItems : BoostItems
    name := isSelene ? "SELENE'S SHOP" : "BOOST SHOP"

    if (isSelene && !SeleneActive
        && MsgBox("Selene is AWAY right now (see the widget).`nRecord her shop anyway?", "FAA Setup", "YesNo Icon?") = "No")
        return true
    if !SetupInfo(name "`n`nStand right next to the shop NPC, then press OK.`n`nThe macro opens the shop with E and scrolls it to the top, exactly like when farming. Then aim at each BUY button and press ENTER. Nothing is bought while you aim.")
        return false

    ActivateRoblox()
    Sleep(300)
    rc := RobloxClient()
    if !OpenShop(rc)
        return false

    WizardTicks := 0
    WizardScrollEnabled := true
    try {
        for i, it in items {
            r := CapturePoint(name " · " i "/" items.Length "`n" it.label "`nAim at its BUY button (press ↓ to scroll if it is hidden), then press ENTER.")
            if Cancelled(r)
                return false
            if !IsObject(r)
                continue
            IniWrite(WizardTicks "," r.x "," r.y, IniPath, "Routine", it.id)
        }
    } finally {
        WizardScrollEnabled := false
    }

    r := CapturePoint(name " · last step`nAim at the red ✕ that closes the shop, then press ENTER. The macro clicks it for you.")
    if !IsObject(r)
        return !Cancelled(r)
    IniWrite("0," r.x "," r.y, IniPath, "Routine", isSelene ? "Selene.Close" : "Boost.Close")
    ClickAt(rc, r.x, r.y)
    Sleep(600)
    return true
}

RecordClickToFish() {
    r := CapturePoint("CLICK TO FISH BUTTON`nStop fishing (walk one step) so the green 'Click to Fish!' button appears, aim at its middle, then press ENTER.`nThe macro clicks it afterwards to start fishing again.")
    if !IsObject(r)
        return !Cancelled(r)
    rc := RobloxClient()
    color := SampleButton(rc, r, 400)
    IniWrite(r.x "," r.y "," color, IniPath, "Routine", "ClickToFish")
    ClickAt(rc, r.x, r.y)
    Sleep(500)
    RefreshAutoFishText()
    return true
}

RecordEventSlot() {
    global EventCharOut
    r := CapturePoint("EVENT CHARACTER SLOT (Hallows Eve)`nTake your event character OUT (hotbar slot " EventCharSlot "), aim at the part of its slot that changes colour when it is held (usually the border), then press ENTER.`nThe macro puts it away once to learn both colours.")
    if !IsObject(r)
        return !Cancelled(r)
    rc := RobloxClient()
    outColor := SampleButton(rc, r, 300)
    PressHotbarSlot(EventCharSlot)
    awayColor := SampleButton(rc, r, 900)
    if (ColorDist(outColor, awayColor) < 30) {
        MsgBox("Could not see a difference at that spot.`n`nOUT " outColor "  ·  AWAY " awayColor "`n`nRecord it again from SETUP while aiming at the slot border.", "FAA Setup", "Icon!")
        return true
    }
    IniWrite(r.x "," r.y "," outColor "," awayColor, IniPath, "Routine", "EventSlot")
    EventCharOut := false
    return true
}

RecordAbilityButton() {
    r := CapturePoint("ROD ABILITY BUTTON`nWait until your ability button (e.g. 'Forgotten Call [V]') is GREEN / ready, aim at its middle, then press ENTER.`nThe macro then uses the ability once.")
    if !IsObject(r)
        return !Cancelled(r)
    rc := RobloxClient()
    IniWrite(r.x "," r.y "," SampleButton(rc, r, 400), IniPath, "Routine", "AbilityButton")
    PressRodKey()
    RestartRodCooldown()
    return true
}

ParseDuration(text) {
    text := Trim(text)
    if RegExMatch(text, "^(\d+):(\d{1,2})$", &m)
        return Integer(m[1]) * 60 + Integer(m[2])
    return IsInteger(text) ? Integer(text) : 0
}

EditAbilityCooldown() {
    global RodAbilityCooldownSeconds
    input := InputBox("Rod ability cooldown, as m:ss or in seconds.`nCurrent: " FormatMMSS(RodAbilityCooldownSeconds) " (" RodAbilityCooldownSeconds " s)", "FAA Setup", "w320 h150", FormatMMSS(RodAbilityCooldownSeconds))
    seconds := ParseDuration(input.Value)
    if (input.Result = "OK" && seconds >= 5) {
        RodAbilityCooldownSeconds := seconds
        IniWrite(seconds, IniPath, "Rod_Ability", "RodAbilityCooldownSeconds")
        RestartRodCooldown()
    }
    ShowSetupMenu()
}

CardText(rc, pt) {
    x := rc.x + Integer(rc.w * (pt.x - 0.045)), y := rc.y + Integer(rc.h * (pt.y - 0.19))
    w := Integer(rc.w * 0.175), h := Integer(rc.h * 0.165)
    for opts in [{scale: 1.0}, {scale: 1.0, grayscale: 1}] {
        try result := OCR.FromRect(x, y, w, h, opts)
        catch
            continue
        text := Trim(RegExReplace(result.Text, "\s+", " "))
        if (text != "")
            return text
    }
    return ""
}

ShiftedSelenePoint(id) {
    target := SeleneSlots[id]
    row := target // 3, col := Mod(target, 3)
    h := GetPoint("Selene.Heavens"), l := GetPoint("Selene.Luck2")
    colStep := (h.t = l.t && Abs(h.y - l.y) < 0.03) ? l.x - h.x : 0.1865
    for refId, slot in SeleneSlots {
        if ((slot - 1) // 3 = row) {
            ref := GetPoint(refId)
            return {t: ref.t, x: ref.x + (col - Mod(slot - 1, 3)) * colStep, y: ref.y}
        }
    }
    return GetPoint(id)
}

StockText(card) =>RegExMatch(card, "i)[o0]ut\s*of\s*st[o0]ck") ? "OUT OF STOCK" : RegExMatch(card, "i)x\s?\S{1,3}\s?left", &m) ? m[0] : "stock ?"

WrongCard(card) => RegExMatch(card, "i)exclusive|obtained|unlocks|abilit")

GuardedBuy(rc, it, p) {
    card := CardText(rc, p)
    snippet := SubStr(card, 1, 90)
    if WrongCard(card) {
        Log("  ⚠ " it.label ": the card under the button is NOT this potion ('" snippet "'), layout shifted? nothing clicked")
        return "skipped (wrong card)"
    }
    if (StockText(card) = "OUT OF STOCK") {
        Log("  " it.label ": out of stock, nothing clicked")
        return "0 (out of stock)"
    }
    BuyButton(rc, p)
    Sleep(400)
    after := StockText(CardText(rc, p))
    Log("  " it.label ": clicked " ClicksPerButton "x · stock " StockText(card) " → " after " · card '" snippet "'")
    return after = "OUT OF STOCK" ? "bought, now sold out" : "clicked, " after
}

RecordBoostShop() => RecordShop(false)

RecordSeleneShop() => RecordShop(true)

RecordRebirth() {
    rc := RobloxClient()
    r := CapturePoint("REBIRTH · 1/3`nAim at the Rebirth icon in the left sidebar, then press ENTER. The macro opens it.")
    if !IsObject(r)
        return !Cancelled(r)
    IniWrite("0," r.x "," r.y, IniPath, "Routine", "Rebirth.Open")
    ClickAt(rc, r.x, r.y)
    Sleep(800)

    r := CapturePoint("REBIRTH · 2/3`nAim at the GREEN cash Rebirth button (never the Robux one), then press ENTER.`nIt is NOT clicked now.")
    if Cancelled(r)
        return false
    if IsObject(r)
        IniWrite("0," r.x "," r.y, IniPath, "Routine", "Rebirth.Confirm")

    r := CapturePoint("REBIRTH · 3/3`nAim at the red ✕ that closes the Rebirth window, then press ENTER. The macro closes it.")
    if !IsObject(r)
        return !Cancelled(r)
    IniWrite("0," r.x "," r.y, IniPath, "Routine", "Rebirth.Close")
    ClickAt(rc, r.x, r.y)
    Sleep(400)
    return true
}

RunSetup(steps*) {
    global WizardRunning, IsExecutingShop, ManualAction
    if (WizardRunning || IsExecutingShop) {
        MsgBox("The macro is busy (shop or rebirth running). Try again in a few seconds.", "FAA Setup", "Icon! T4")
        return
    }
    if IsRunning
        ToggleMacroState()
    if (!RobloxClient().hwnd || RobloxClient().w < 200) {
        MsgBox("Open Roblox and join Fish an Anime RNG first.", "FAA Setup", "Icon!")
        return
    }
    if IsObject(SetupGui)
        SetupGui.Hide()

    WizardRunning := true, IsExecutingShop := true, ManualAction := true
    WidgetGui.Hide()
    try {
        ActivateRoblox()
        Sleep(300)
        for step in steps
            if !step()
                break
    } finally {
        ToolTip()
        WizardRunning := false, IsExecutingShop := false, ManualAction := false
        WidgetGui.Show("NoActivate")
        ShowSetupMenu()
    }
}

SetupHandler(steps*) => (*) => RunSetup(steps*)

SetupRows() => [
    ["🎣   Water spot", IsRecorded("Fishing_Settings", "WaterRatioX"), RecordWater],
    ["🟩   Click to Fish button", IsRecorded("Routine", "ClickToFish"), RecordClickToFish],
    ["🟢   Auto Fish button", IsRecorded("Routine", "AutoFish"), RecordAutoFish],
    ["⚡   Ability button (ready colour)", IsRecorded("Routine", "AbilityButton"), RecordAbilityButton],
    ["🧛   Event character slot (Hallows Eve)", IsRecorded("Routine", "EventSlot"), RecordEventSlot],
    ["🛒   Boost shop", IsRecorded("Routine", "Boost.Close"), RecordBoostShop],
    ["🌙   Selene's shop", IsRecorded("Routine", "Selene.Close"), RecordSeleneShop],
    ["♻   Rebirth", IsRecorded("Routine", "Rebirth.Confirm"), RecordRebirth]
]

ShowSetupMenu(welcome := false) {
    if !IsObject(SetupGui)
        BuildSetupMenu()
    SetupGui["Title"].Text := welcome ? "✦ Welcome!" : "✦ Setup your routine"
    for i, row in SetupRows()
        SetupGui["Row" i].Text := "   " row[1] (row[2] ? "    ✓" : "    · default")
    SetupGui["Cooldown"].Text := "   ⏱   Ability cooldown    " FormatMMSS(RodAbilityCooldownSeconds) "  ✎"
    SetupGui.Show("AutoSize Center")
}

BuildSetupMenu() {
    global SetupGui
    SetupGui := Gui("+AlwaysOnTop +ToolWindow -DPIScale", "FAA Setup")
    SetupGui.BackColor := Tc("160F1E")
    SetupGui.MarginX := 18
    SetupGui.MarginY := 16
    SetupGui.SetFont("s12 bold c" Tc("F7D4E8"), "Segoe UI")
    SetupGui.Add("Text", "w384 vTitle")
    SetupGui.SetFont("s9 norm c" Tc("BFAACF"))
    SetupGui.Add("Text", "w384 y+6", "Record your own buttons once: the macro then works on any screen. Each part can be redone at any time. Items you skip keep their default position.")

    SetupGui.SetFont("s10 norm c" Tc("F2E6F7"))
    for i, row in SetupRows()
        SetupGui.Add("Text", "w384 h32 y+8 0x200 vRow" i " Background" Tc("2A1D36")).OnEvent("Click", SetupHandler(row[3]))
    SetupGui.Add("Text", "w384 h32 y+8 0x200 vCooldown Background" Tc("2A1D36")).OnEvent("Click", (*) => (SetupGui.Hide(), EditAbilityCooldown()))
    SetupGui.Add("Text", "w384 h32 y+8 0x200 Background" Tc("2A1D36"), "   🎃   Hallows Eve banner (drag a box)").OnEvent("Click", (*) => (SetupGui.Hide(), CalibrateEventArea()))
    SetupGui.Add("Text", "w384 h32 y+8 0x200 Background" Tc("2A1D36"), "   🎨   Widget theme    " Themes[ThemeId].name "  ▸").OnEvent("Click", (*) => ShowThemeMenu())
    SetupGui.Add("Text", "w384 h32 y+8 0x200 Background" Tc("2A1D36"), "   🔧   Options && potions to buy  ▸").OnEvent("Click", (*) => (SetupGui.Hide(), ShowOptions()))

    SetupGui.SetFont("s10 bold cFFFFFF")
    SetupGui.Add("Text", "w384 h36 y+14 Center 0x200 Background" Tc("B0569A"), "▶  Record everything").OnEvent("Click", SetupHandler(RecordWater, RecordAutoFish, RecordClickToFish, RecordBoostShop, RecordSeleneShop, RecordRebirth))
    SetupGui.SetFont("s9 norm c" Tc("8C7799"))
    SetupGui.Add("Text", "w384 h26 y+8 Center 0x200", "Close").OnEvent("Click", (*) => SetupGui.Hide())
    SetupGui.SetFont("s8 norm")
    SetupGui.Add("Text", "w384 y+6 Center", "⚠ You use this macro at your own risk.  ⓘ Read the terms").OnEvent("Click", (*) => ShowInfo())
}

ShortLabel(label) => Trim(RegExReplace(RegExReplace(label, "Potion|Lvl", ""), "\s+", " "))

PaintToggle(ctrl, label, on) {
    ctrl.Text := "  " (on ? "✓" : "✗") "   " label
    ctrl.SetFont("c" Tc(on ? "7EE8C8" : "8C7799"))
}

FlipToggle(ctrl, label, section, key, def) {
    on := !IniInt(section, key, def)
    IniWrite(on ? 1 : 0, IniPath, section, key)
    LoadConfig()
    PaintToggle(ctrl, label, on)
    RefreshAutoFishText()
}

AddToggle(gui, opts, label, section, key, def := 1) {
    ctrl := gui.Add("Text", opts " 0x200 Background" Tc("2A1D36"))
    PaintToggle(ctrl, label, IniInt(section, key, def))
    ctrl.OnEvent("Click", (*) => FlipToggle(ctrl, label, section, key, def))
}

ShowOptions() {
    global OptionsGui
    if IsObject(OptionsGui) {
        OptionsGui.Show()
        return
    }

    OptionsGui := Gui("+AlwaysOnTop +ToolWindow -DPIScale", "FAA Options")
    OptionsGui.BackColor := Tc("160F1E")
    OptionsGui.MarginX := 18
    OptionsGui.MarginY := 16
    OptionsGui.SetFont("s12 bold c" Tc("F7D4E8"), "Segoe UI")
    OptionsGui.Add("Text", "w330", "✦ Options")
    OptionsGui.SetFont("s9 norm c" Tc("BFAACF"))
    OptionsGui.Add("Text", "w330 y+6", "Click a line to turn it on or off. Changes apply right away.")

    OptionsGui.SetFont("s10 norm")
    for row in [
        ["♻   Auto rebirth (every " RebirthIntervalMinutes " min)", "Auto_Rebirth", "EnableAutoRebirth", 1],
        ["🎃   Hallows Eve event character", "Hallows_Eve", "EnableHallowsEve", 1],
        ["⚡   Rod ability", "Rod_Ability", "EnableRodAbility", 1],
        ["🟢   Fishing watchdog", "Auto_Fish", "EnableWatchdog", 1],
        ["🔔   Check for updates on launch", "Updates", "CheckOnStart", 1],
        ["🔊   Sound beeps", "Sound_Settings", "EnableSoundBeep", 0]
    ]
        AddToggle(OptionsGui, "xm w330 h30 y+6", row[1], row[2], row[3], row[4])

    OptionsGui.SetFont("s10 bold c" Tc("F7D4E8"))
    OptionsGui.Add("Text", "xm w330 y+16", "🛒 Boost potions to buy")
    OptionsGui.SetFont("s9 norm")
    for i, it in BoostItems
        AddToggle(OptionsGui, "w106 h28 " (Mod(i - 1, 3) ? "x+6 yp" : "xm y+6"), ShortLabel(it.label), it.section, it.key)

    OptionsGui.SetFont("s10 bold c" Tc("F7D4E8"))
    OptionsGui.Add("Text", "xm w330 y+16", "🌙 Selene potions to buy")
    OptionsGui.SetFont("s9 norm")
    for i, it in SeleneItems
        AddToggle(OptionsGui, "w162 h28 " (Mod(i - 1, 2) ? "x+6 yp" : "xm y+6"), ShortLabel(it.label), it.section, it.key)

    OptionsGui.SetFont("s9 norm c" Tc("8C7799"))
    OptionsGui.Add("Text", "xm w330 h26 y+12 Center 0x200", "Close").OnEvent("Click", (*) => OptionsGui.Hide())
    OptionsGui.Show("AutoSize Center")
}

F1:: ToggleMacroState()

F2:: {
    PlayBeep(300, 250)
    ExitApp()
}

F3:: {
    global ServerClockOffset
    promptMsg := "Shop restocks every 5 min (:00, :05...).`nTime now: " A_Min ":" A_Sec "`nCurrent offset: +" ServerClockOffset "s`n`nNew offset (seconds):"
    inputVal := InputBox(promptMsg, "Server Offset", "w340 h200", String(ServerClockOffset))
    if (inputVal.Result != "Cancel" && IsInteger(Trim(inputVal.Value))) {
        ServerClockOffset := Integer(Trim(inputVal.Value))
        IniWrite(ServerClockOffset, IniPath, "Shop_Settings", "ServerClockOffsetSeconds")
        PlayBeep(600, 100)
    }
}

F4:: ShowSetupMenu()

F5:: {
    global ManualAction
    if IsExecutingShop
        return
    ManualAction := true
    DoAutoBuySequence()
}

F6:: ManualOcrCheck()
F7:: CalibrateEventArea()
F8:: RunSetup(RecordWater)

F9:: {
    global ManualAction
    if IsExecutingShop
        return
    ManualAction := true
    DoAutoRebirthSequence()
}

#HotIf WizardActive
Enter::
NumpadEnter::SetWizardKey("enter")
Backspace::SetWizardKey("skip")
Escape::SetWizardKey("cancel")
Down::WizardScroll(1)
Up::WizardScroll(-1)
WheelDown::
WheelUp::return
#HotIf

ParseIniInt(val, defaultVal := 0) {
    cleaned := Trim(RegExReplace(val, "^[ =]+", ""))
    return (cleaned != "" && IsInteger(cleaned)) ? Integer(cleaned) : defaultVal
}

ParseIniFloat(val, defaultVal := 0.0) {
    cleaned := Trim(RegExReplace(val, "^[ =]+", ""))
    return (cleaned != "" && IsNumber(cleaned)) ? Float(cleaned) : defaultVal
}

IniInt(section, key, def) => ParseIniInt(IniRead(IniPath, section, key, def), def)

IniFloat(section, key, def) => ParseIniFloat(IniRead(IniPath, section, key, def), def)

LoadConfig() {
    global
    if (!FileExist(IniPath) && FileExist(A_ScriptDir "\config.example.ini"))
        FileCopy(A_ScriptDir "\config.example.ini", IniPath)
    if !FileExist(IniPath)
        return

    ThemeId := IniRead(IniPath, "Widget", "Theme", "nino")
    if !Themes.Has(ThemeId)
        ThemeId := "nino"
    for it in BoostItems
        it.buy := IniInt(it.section, it.key, 1)
    for it in SeleneItems
        it.buy := IniInt(it.section, it.key, 1)

    ShopMode := IniRead(IniPath, "Shop_Settings", "ShopMode", "Boosts") = "Selene" ? "Selene" : "Boosts"
    ServerClockOffset := IniInt("Shop_Settings", "ServerClockOffsetSeconds", 7)
    ShopOpenDelay := IniInt("Shop_Settings", "ShopOpenDelayMs", 4000)
    ClicksPerButton := IniInt("Shop_Settings", "ClicksPerButton", 3)
    ClickIntervalMs := IniInt("Shop_Settings", "ClickIntervalMs", 700)
    ScrollSettleMs := IniInt("Shop_Settings", "ScrollSettleMs", 450)

    AutoSwitchDesktop := IniInt("Virtual_Desktop", "AutoSwitchDesktop", 0)
    DesktopStepsRight := IniInt("Virtual_Desktop", "DesktopStepsRight", 2)
    DesktopSwitchDelayMs := IniInt("Virtual_Desktop", "DesktopSwitchDelayMs", 350)

    WaterRatioX := IniFloat("Fishing_Settings", "WaterRatioX", 0.324)
    WaterRatioY := IniFloat("Fishing_Settings", "WaterRatioY", 0.556)
    AntiAfkInterval := IniInt("Fishing_Settings", "AntiAfkIntervalSeconds", 180)
    EnableSoundBeep := IniInt("Sound_Settings", "EnableSoundBeep", 0)

    EnableAutoFishWatchdog := IniInt("Auto_Fish", "EnableWatchdog", 1)
    AutoFishCheckSeconds := Max(2, IniInt("Auto_Fish", "CheckIntervalSeconds", 5))
    AutoFishColorTolerance := IniInt("Auto_Fish", "ColorTolerance", 60)

    EnableHallowsEve := IniInt("Hallows_Eve", "EnableHallowsEve", 1)
    EventCharSlot := IniInt("Hallows_Eve", "EventCharSlot", 2)
    NormalCharSlot := IniInt("Hallows_Eve", "NormalCharSlot", 0)
    CheckIntervalSeconds := IniInt("Hallows_Eve", "CheckIntervalSeconds", 4)
    EventRatioX := IniFloat("Hallows_Eve", "EventRatioX", 0.35)
    EventRatioY := IniFloat("Hallows_Eve", "EventRatioY", 0.04)
    EventRatioW := IniFloat("Hallows_Eve", "EventRatioW", 0.30)
    EventRatioH := IniFloat("Hallows_Eve", "EventRatioH", 0.12)

    SeleneDurationMinutes := IniInt("Selene_Settings", "SeleneDurationMinutes", 5)
    SeleneClockOffsetSeconds := IniInt("Selene_Settings", "SeleneClockOffsetSeconds", 0)
    SeleneBuyAtSeconds := []
    for part in StrSplit(IniRead(IniPath, "Selene_Settings", "BuyAtSeconds", "30,150"), ",", " `t")
        if IsInteger(part)
            SeleneBuyAtSeconds.Push(Integer(part))
    if !SeleneBuyAtSeconds.Length
        SeleneBuyAtSeconds := [30, 150]

    EnableRodAbility := IniInt("Rod_Ability", "EnableRodAbility", 1)
    RodAbilityKey := IniRead(IniPath, "Rod_Ability", "RodAbilityKey", "v")
    RodAbilityCooldownSeconds := IniInt("Rod_Ability", "RodAbilityCooldownSeconds", 481)

    EnableAutoRebirth := IniInt("Auto_Rebirth", "EnableAutoRebirth", 1)
    RebirthIntervalMinutes := IniInt("Auto_Rebirth", "RebirthIntervalMinutes", 60)
}
