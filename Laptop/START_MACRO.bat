@echo off
setlocal
title FAA Macro Launcher
echo ===================================================
echo     Launching Fish an Anime RNG (FAA) Macro
echo ===================================================
echo.

:find_ahk
set "AHK_EXE="

if exist "%LOCALAPPDATA%\Programs\AutoHotkey\v2\AutoHotkey64.exe" (
    set "AHK_EXE=%LOCALAPPDATA%\Programs\AutoHotkey\v2\AutoHotkey64.exe"
    goto :launch
)

if exist "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" (
    set "AHK_EXE=C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
    goto :launch
)

where AutoHotkey64.exe >nul 2>&1
if %errorlevel% equ 0 (
    set "AHK_EXE=AutoHotkey64.exe"
    goto :launch
)

:not_found
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
if errorlevel 2 goto :download_web
if errorlevel 1 goto :install_winget

:download_web
echo Opening official AutoHotkey v2 installer download...
start https://www.autohotkey.com/download/ahk-v2.exe
pause
exit /b 1

:install_winget
echo.
echo Installing AutoHotkey v2 via Windows Package Manager...
winget install AutoHotkey.AutoHotkey --accept-package-agreements --accept-source-agreements
echo.
echo If installation completed, please press any key to re-launch!
pause
goto :find_ahk

:launch
echo Launching widget with: "%AHK_EXE%"
start "" "%AHK_EXE%" "%~dp0FAA_Macro.ahk"
echo Widget and Macro launched successfully!
ping 127.0.0.1 -n 2 >nul
exit /b 0
