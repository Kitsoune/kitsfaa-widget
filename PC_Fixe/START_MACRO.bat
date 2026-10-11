@echo off
title FAA Macro Launcher
echo ===================================================
echo     Launching Fish an Anime RNG (FAA) Macro
echo ===================================================
echo.

set AHK_EXE=""

if exist "%LOCALAPPDATA%\Programs\AutoHotkey\v2\AutoHotkey64.exe" (
    set AHK_EXE="%LOCALAPPDATA%\Programs\AutoHotkey\v2\AutoHotkey64.exe"
) else if exist "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" (
    set AHK_EXE="C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
) else (
    where AutoHotkey64.exe >nul 2>&1
    if %errorlevel% equ 0 (
        set AHK_EXE="AutoHotkey64.exe"
    )
)

if %AHK_EXE%=="" (
    echo [ERROR] AutoHotkey v2 not found!
    echo Please make sure AutoHotkey v2 is installed.
    pause
    exit /b 1
)

start "" %AHK_EXE% "%~dp0FAA_Macro.ahk"
echo Widget and Macro launched successfully!
timeout /t 2 >nul
exit
