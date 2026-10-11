@echo off
title FAA Macro Launcher
echo ===================================================
echo     Launching Fish an Anime RNG (FAA) Macro
echo ===================================================
echo.

:restart
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
    echo ===================================================
    echo  [!] AutoHotkey v2 is not installed on this PC.
    echo ===================================================
    echo.
    echo  Please choose an option:
    echo    [1] Install AutoHotkey v2 automatically via winget
    echo    [2] Open official AutoHotkey download website
    echo    [3] Exit
    echo.
    choice /c 123 /n /m "Select option [1, 2, or 3]: "
    if errorlevel 3 exit /b 1
    if errorlevel 2 (
        echo Opening official AutoHotkey v2 installer download...
        start https://www.autohotkey.com/download/ahk-v2.exe
        pause
        exit /b 1
    )
    if errorlevel 1 (
        echo.
        echo Installing AutoHotkey v2 via Windows Package Manager (winget)...
        winget install AutoHotkey.AutoHotkey --accept-package-agreements --accept-source-agreements
        echo.
        echo If installation completed, please press any key to re-launch!
        pause
        goto :restart
    )
)

start "" %AHK_EXE% "%~dp0FAA_Macro.ahk"
echo Widget and Macro launched successfully!
timeout /t 2 >nul
exit
