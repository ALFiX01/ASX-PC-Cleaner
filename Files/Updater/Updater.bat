::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAnk
::fBw5plQjdCuDJOl7RaKA9quH/eQy7NtmtmmtA9RLEVpWEpCtilLtyFVrAoivE9hTwlDmSZ8u2XRmv8QDCBlBeyiqfh0xvSNss3OhMtSVtAGvQ0uGhg==
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF+5
::cxAkpRVqdFKZSjk=
::cBs/ulQjdF+5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpCI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+JeA==
::cxY6rQJ7JhzQF1fEqQJQ
::ZQ05rAF9IBncCkqN+0xwdVs0
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFD9VQg2LMFeeCbYJ5e31+/m7hUQJfPc9RK7o4vm+A60w5kDle5M/6lxTlM4fMC5IehO/ax0InH5Gt3CAJYmZqwqB
::YB416Ek+ZW8=
::
::
::978f952a14a936cc963da21a135fa983
@echo off

chcp 65001 >nul 2>&1
:: Запуск от имени администратора
reg add HKLM /F >nul 2>&1
if %errorlevel% neq 0 (
    start "" /wait /I /min powershell -NoProfile -Command "start -verb runas '%~s0'" && exit /b
    exit /b
)

setlocal EnableDelayedExpansion

mode con: cols=80 lines=25 >nul 2>&1

REM Установка переменной Directory
reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Directory" >nul 2>&1
if errorlevel 1 (
    REM Если ключ не существует, создаем его и директорию
    if not exist "%ProgramFiles%" (
        echo Ошибка 02: Директория Program Files не найдена.
        echo Проверьте целостность системы Windows.
        pause
        exit /b 1
    )
    reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /t REG_SZ /v "Directory" /d "%ProgramFiles%\ASX" /f >nul 2>&1
    set "ASX-Directory=%ProgramFiles%\ASX"
    
    REM Создаем структуру директорий
    if not exist "!ASX-Directory!\Files\Logs" (
        md "!ASX-Directory!\Files\Logs" >nul 2>&1
    )
) else (
    REM Если ключ существует, получаем значение
    for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Directory" 2^>nul ^| find /i "Directory"') do set "ASX-Directory=%%b"
    
    if not exist "!ASX-Directory!" (
        REM Если директория не существует, создаем ее и устанавливаем флаг первого запуска
        md "!ASX-Directory!\Files\Logs" >nul 2>&1
        set "SaveData=HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Data"
        call:ASX_First_launch
        echo [INFO ] %TIME% - Создана директория !ASX-Directory! >> "!ASX-Directory!\Files\Logs\%date%.txt"
    ) else (
        REM Проверка структуры директорий
        if not exist "!ASX-Directory!\Files\Temp" md "!ASX-Directory!\Files\Temp" >nul 2>&1
    )
)

set "UpdaterVersion=1.1"

REM Цветной текст
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a" & set "COL=%%b")

cls
title Установщик программного обеспечения от ALFiX, Inc. (v%UpdaterVersion%)
echo.
echo        %COL%[36m ┌──────────────────────────────────────────────────────────────┐
echo         ^│     %COL%[91m ██╗   ██╗██████╗ ██████╗  █████╗ ████████╗███████╗     %COL%[36m ^│
echo         ^│     %COL%[91m ██║   ██║██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝     %COL%[36m ^│
echo         ^│     %COL%[91m ██║   ██║██████╔╝██║  ██║███████║   ██║   █████╗       %COL%[36m ^│
echo         ^│     %COL%[91m ██║   ██║██╔═══╝ ██║  ██║██╔══██║   ██║   ██╔══╝       %COL%[36m ^│
echo         ^│     %COL%[91m ╚██████╔╝██║     ██████╔╝██║  ██║   ██║   ███████╗     %COL%[36m ^│
echo         ^│     %COL%[91m  ╚═════╝ ╚═╝     ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝     %COL%[36m ^│
echo         └──────────────────────────────────────────────────────────────┘
echo.
echo        %COL%[37m Добро пожаловать в программу обновления ASX PC Cleaner
echo        %COL%[90m Для корректной работы рекомендуется отключить антивирус
echo        %COL%[37m ──────────────────── ВЫПОЛНЯЕТСЯ ОБНОВЛЕНИЕ ──────────────────── %COL%[90m
echo.


echo         ^[*^] Скачивание файлов
curl -g -L -# -o "%TEMP%\ASX-PC-Cleaner.exe" "https://github.com/ALFiX01/ASX-PC-Cleaner/raw/refs/heads/main/Files/PC_cleaner/ASX-PC-Cleaner.exe" >nul 2>&1

for %%I in ("%TEMP%\ASX-PC-Cleaner.exe") do set FileSize=%%~zI
if %FileSize% LSS 100 (
    echo       %COL%[91m ^[*^] Error - Файл GoodbyeZapret.zip поврежден или URL не доступен ^(Size %FileSize%^) %COL%[90m
    pause
    del /Q "%TEMP%\ASX-PC-Cleaner.exe"
    exit
)


if exist "%ASX-Directory%\Files\Utilites\PC_Cleaner\ASX-PC-Cleaner.exe" (
  rd /s /q "%ASX-Directory%\Files\Utilites\PC_Cleaner\ASX-PC-Cleaner.exe" >nul 2>&1
)

if exist "%TEMP%\ASX-PC-Cleaner.exe" (
    move /Y "%TEMP%\ASX-PC-Cleaner.exe" "%ASX-Directory%\Files\Utilites\PC_Cleaner\ASX-PC-Cleaner.exe"
)


start "" "%ASX-Directory%\Files\Utilites\PC_Cleaner\ASX-PC-Cleaner.exe"
exit
