@echo off
title Lancement Macro FAA
echo ===================================================
echo     Lancement de Fish an Anime RNG (FAA) Macro
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
    echo [ERREUR] AutoHotkey v2 introuvable !
    echo Veuillez verifier l'installation d'AutoHotkey v2.
    pause
    exit /b 1
)

start "" %AHK_EXE% "%~dp0FAA_Macro.ahk"
echo Widget et Macro lances avec succes !
echo Appuyez sur une touche pour fermer cette fenetre...
timeout /t 2 >nul
exit
