@echo off

:: Copyright (C) 2025 ALFiX, Inc.
:: Any tampering with the program code is forbidden (Запрещены любые вмешательства)

:: Запуск от имени администратора
reg add HKLM /F >nul 2>&1
if %errorlevel% neq 0 (
    start "" /wait /I /min powershell -NoProfile -Command "start -verb runas '%~s0'" 
    exit /b
)

:: Получение информации о текущем языке интерфейса и выход, если язык не ru-RU
for /f "tokens=3" %%i in ('reg query "HKCU\Control Panel\International" /v "LocaleName"') do set WinLang=%%i
if /I "%WinLang%" NEQ "ru-RU" (
    cls
    echo  Error 01: Invalid interface language.
    pause
    exit /b
)

:RR
:: Внутренний перезапуск ASX PC Cleaner
mode con: cols=114 lines=38 >nul 2>&1
chcp 65001 >nul 2>&1

setlocal EnableDelayedExpansion

REM ИНФОРМАЦИЯ О ВЕРСИИ
set "Version=1.0"

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
        reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Firstlaunch" /t REG_SZ /d "Yes" /f >nul 2>&1
        set "SaveData=HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Data"
        call:ASX_First_launch
        echo [INFO ] %TIME% - Создана директория !ASX-Directory! >> "!ASX-Directory!\Files\Logs\%date%.txt"
    ) else (
        REM Проверка структуры директорий
        if not exist "!ASX-Directory!\Files\Temp" md "!ASX-Directory!\Files\Temp" >nul 2>&1
    )
)

REM Цветной текст
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a" & set "COL=%%b")

REM Логируем запуск ASX PC Cleaner
echo. >> "!ASX-Directory!\Files\Logs\%date%.txt"
echo 📌 Запуск ASX PC Cleaner >> "!ASX-Directory!\Files\Logs\%date%.txt"


:ASX_cleaner

if not exist "%ASX-Directory%\Files\Logs\ASX_cleaner" md "%ASX-Directory%\Files\Logs\ASX_cleaner" >nul 2>&1
cls
TITLE ASX PC Cleaner %version% beta
echo.
echo.
echo                               %COL%[90m____  ______            ________
echo                              / __ \/ ____/           / ____/ /__  ____ _____  ___  _____
echo                             / /_/ / /      ______   / /   / / _ \/ __ `/ __ \/ _ \/ ___/
echo                            / ____/ /___   /_____/  / /___/ /  __/ /_/ / / / /  __/ / 
echo                           /_/    \____/            \____/_/\___/\__,_/_/ /_/\___/_/ %COL%[36mbeta%COL%[90m
echo.
echo                    Утилита для удаления временных файлов, освобождения дискового пространства
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.

set drive=C:
:: === Первая проверка ===
for /f "skip=1 tokens=1,2" %%A in ('wmic logicaldisk where "DeviceID='%drive%'" get FreeSpace^,Size') do (
    if not defined free1 set free1=%%A
)

echo.
echo.
set /a DelFileCount=0
set /a DelFolderCount=0
set /a ErrorCount=0
echo                            %COL%[37mНажмите любую клавишу, чтобы запустить процесс очистки...
echo.
pause >nul
echo   %COL%[96mЗапускаю процесс очистки...%COL%[37
echo.
title Очистка [1/3]
echo. >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
echo [INFO ] %TIME% - Очистка [1/3] запущена >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"



:: --- ЗАКРЫТИЕ НЕНУЖНЫХ ПРОЦЕССОВ ---
echo Закрытие ненужных процессов... ^(Это может привести к потере данных в открытых приложениях^)

:: Список процессов, которые необходимо закрыть (внимательно просмотрите этот список)
for %%P in (
    "ccleaner64.exe"
    "ccleaner.exe"
    "msedge.exe"
    "firefox.exe"
    "vivaldi.exe"
    "brave.exe"
    "chrome.exe"
    "Acrotray.exe"
    "GoogleUpdate.exe"
    "Skype.exe"
    "Spotify.exe"
    "Steam.exe"
    "Cortana.exe"
) do (
    tasklist /FI "IMAGENAME eq %%~P" 2>nul | find /I "%%~P" >nul
    if not errorlevel 1 (
        taskkill /F /IM "%%~P" >nul 2>&1
        if errorlevel 1 (
            echo  [ERROR] - Не удалось закрыть процесс %%~P ^(возможно, он уже закрывается или доступ запрещен^).
        ) else (
            echo [INFO ] - Процесс закрыт: %%~P
        )
    ) else (
        echo [INFO ] - Процесс %%~P не выполняется.
    )
)


:: --- УДАЛЕНИЕ НЕНУЖНЫХ ЛОГ-ФАЙЛОВ ---
echo Удаление ненужных логов...
for %%L in (
    "%SystemRoot%\Logs\CBS\*.log"
    "%SystemRoot%\Logs\MoSetup\*.log"
    "%SystemRoot%\Panther\*.log"
    "%SystemRoot%\inf\setupapi.*.log"
    "%SystemRoot%\SoftwareDistribution\ReportingEvents.log"
    "%SystemRoot%\SoftwareDistribution\DataStore\Logs\edb*.log"
) do (
    if exist "%%~L" (
        echo [INFO ] - Удаление %%~L ...
        del /s /q /f "%%~L" >nul 2>&1
        if errorlevel 1 (
          echo [ERROR] - Не удалось удалить лог-файл: %%~L
        ) else (
          echo [INFO ] - Удален лог-файл: %%~L
          set /a DelFileCount+=1
        )
    ) else (
         echo [INFO ] - лог-файл не найден: %%~L
    )
)

:: --- ОЧИСТКА КЭША БРАУЗЕРОВ ---
echo Очистка кэша браузеров...
echo [INFO ] - Очистка кэша браузеров.

:: Microsoft Edge
set "EDGE_USER_DATA=%LOCALAPPDATA%\Microsoft\Edge\User Data"
if exist "%EDGE_USER_DATA%\" (
    call :DelDirectory "%EDGE_USER_DATA%\Default\Cache"
    call :DelDirectory "%EDGE_USER_DATA%\Default\Code Cache"
    call :DelDirectory "%EDGE_USER_DATA%\Default\GPUCache"
    call :DelDirectory "%EDGE_USER_DATA%\Default\Service Worker\CacheStorage"
    call :DelDirectory "%EDGE_USER_DATA%\Default\Service Worker\ScriptCache"
    echo [INFO ] - Папки кэша Edge очищены.
) else ( echo [INFO ] - Папка данных Edge не найдена. )

rem Очистка корзины и удаление файлов 
chcp 850 >nul 2>&1
for /f "tokens=*" %%a in ('powershell -Command "Get-ChildItem -Path 'C:\$Recycle.Bin' -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName"') do (
    set /a DelFileCount+=1
)
powershell -Command "Clear-RecycleBin -Confirm:$false -ErrorAction SilentlyContinue"
chcp 65001 >nul 2>&1

rem удаление файлов

for %%a in ("%WinDir%\Temp\*.*" "%systemdrive%*.tmp" "%systemdrive%*._mp" "%systemdrive%*.gid" "%SYSTEMDRIVE%\AMD\*.*" "%SYSTEMDRIVE%\NVIDIA\*.*" "%SYSTEMDRIVE%\INTEL\*.*" "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" "%LocalAppData%\Microsoft\Windows\Explorer\*.db" "%systemdrive%\*.log" "%systemdrive%\*.old" "%windir%\*.bak" "%windir%\Logs\CBS\CbsPersist*.log" "%windir%\Logs\MoSetup\*.log" "%windir%\Panther\*.log" "%windir%\logs\*.log" "%systemdrive%\*.trace" "%WinDir%\Prefetch\*.*" "%Temp%\*.*" "%AppData%\Temp\*.*" "%AppData%\Microsoft\Windows\Recent\*" "%HomePath%\AppData\LocalLow\Temp\*.*" "%LocalAppData%\Microsoft\Windows\INetCache\." "%AppData%\Local\Microsoft\Windows\INetCookies\." "%AppData%\Discord\Cache\." "%AppData%\Discord\Code Cache\." "%ProgramFiles(x86)%\Steam\Dumps" "%ProgramFiles(x86)%\Steam\Traces" "%ProgramFiles(x86)%\Steam\appcache\*.log" "%localappdata%\Microsoft\Windows\WebCache\*.log" "%ProgramData%\Microsoft\Windows Defender\Network Inspection System\Support\*.log" "%ProgramData%\Microsoft\Windows Defender\Scans\History\CacheManager" "%ProgramData%\Microsoft\Windows Defender\Scans\History\ReportLatency\Latency" "%ProgramData%\Microsoft\Windows Defender\Scans\History\Service\*.log" "%ProgramData%\Microsoft\Windows Defender\Scans\MetaStore" "%ProgramData%\Microsoft\Windows Defender\Support" "%ProgramData%\Microsoft\Windows Defender\Scans\History\Results\Quick" "%ProgramData%\Microsoft\Windows Defender\Scans\History\Results\Resource" "%windir%\Minidump\*.dmp" "%localappdata%\CrashDumps\*.dmp" ) do (
    if exist "%%a" (
        del /s /f /q "%%a" >nul 2>&1
        if !errorlevel! equ 0 (
            echo [INFO ] - Удален файл: %%a
            echo [INFO ] %TIME% - Файл %%a удален >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
            set /a DelFileCount+=1
        ) else (
            echo [ERROR] - Файл %%a не может быть удален
            echo [ERROR] %TIME% - Файл %%a не может быть удален >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
            set /a ErrorCount+=1
        )
    ) else (
        echo [WARN ] - Файл %%a не существует
        echo [WARN ] %TIME% - Файл %%a не существует >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
    )
)

title Очистка [2/3]
rem удаление папок 
echo [INFO ] %TIME% - Очистка [2/3] запущена >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
for %%a in ("%WinDir%\Temp" "%WinDir%\Prefetch" "%Temp%" "%AppData%\Temp" "%systemdrive%\windows.old" "%ASX-Directory%\Files\Downloads" "%SystemDrive%\OneDriveTemp" "%ProgramData%\Microsoft\Diagnosis" "%ProgramData%\Microsoft\Network" "%ProgramData%\Microsoft\Search" "%LocalAppData%\Microsoft\Windows\AppCache" "%LocalAppData%\Microsoft\Windows\History" "%LocalAppData%\Microsoft\Windows\WebCache" "%ProgramFiles(x86)%\Steam\logs") do (
    if exist "%%a" (
        rmdir /s /q "%%a" >nul 2>&1
        md %%a >nul 2>&1
        if !errorlevel! equ 0 (
            echo [INFO ] - Папка очищена: %%a
            echo [INFO ] %TIME% - Папка %%a очищена >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
            set /a DelFolderCount+=1
        ) else (
            echo [ERROR] - Папка %%a не может быть очищена
            echo [ERROR] %TIME% - Папка %%a не может быть очищена >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
            set /a ErrorCount+=1
        )
    ) else (
        echo [WARN ] - Папка %%a не существует
        echo [WARN ] %TIME% - Папка %%a не существует >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
    )
)


rem Очистка папки Центра обновления Windows
net stop wuauserv >nul 2>&1
if !errorlevel! equ 0 (
    echo [INFO ] - Служба Windows Update успешно остановлена
    echo [INFO ] %TIME% - Служба Windows Update успешно остановлена >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
) else (
    echo [ERROR] - Ошибка при остановке службы Windows Update
    echo [ERROR] %TIME% - Ошибка при остановке службы Windows Update >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
    set /a ErrorCount+=1
)

net stop cryptSvc >nul 2>&1
if !errorlevel! equ 0 (
    echo [INFO ] - Служба Cryptographic Services успешно остановлена
    echo [INFO ] %TIME% - Служба Cryptographic Services успешно остановлена >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
) else (
    echo [ERROR] - Ошибка при остановке службы Cryptographic Services
    echo [ERROR] %TIME% - Ошибка при остановке службы Cryptographic Services >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
    set /a ErrorCount+=1
)

net stop bits >nul 2>&1
if !errorlevel! equ 0 (
    echo [INFO ] - Служба Background Intelligent Transfer Service успешно остановлена
    echo [INFO ] %TIME% - Служба Background Intelligent Transfer Service успешно остановлена >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
) else (
    echo [ERROR] - Ошибка при остановке службы Background Intelligent Transfer Service
    echo [ERROR] %TIME% - Ошибка при остановке службы Background Intelligent Transfer Service >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
    set /a ErrorCount+=1
)

net stop msiserver >nul 2>&1
if !errorlevel! equ 0 (
    echo [INFO ] - Служба Windows Installer успешно остановлена
    echo [INFO ] %TIME% - Служба Windows Installer успешно остановлена >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
) else (
    echo [ERROR] - Ошибка при остановке службы Windows Installer
    echo [ERROR] %TIME% - Ошибка при остановке службы Windows Installer >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
    set /a ErrorCount+=1
)

echo [INFO ] - Очистка папки Центра обновления Windows...
rd /s /q "%systemdrive%\Windows\SoftwareDistribution"
if !errorlevel! equ 0 (
    echo [INFO ] - Папка %systemdrive%\Windows\SoftwareDistribution успешно удалена
    echo [INFO ] %TIME% - Папка %systemdrive%\Windows\SoftwareDistribution успешно удалена >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
) else (
    echo [ERROR] - Ошибка при удалении папки %systemdrive%\Windows\SoftwareDistribution
    echo [ERROR] %TIME% - Ошибка при удалении папки %systemdrive%\Windows\SoftwareDistribution >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
    set /a ErrorCount+=1
)
md "%systemdrive%\Windows\SoftwareDistribution"

echo [INFO ] - Перезапуск служб, связанных с Центром обновления Windows...
net start wuauserv >nul 2>&1
if !errorlevel! equ 0 (
    echo [INFO ] - Служба Windows Update успешно запущена
    echo [INFO ] %TIME% - Служба Windows Update успешно запущена >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
) else (
    echo [ERROR] - Ошибка при запуске службы Windows Update
    echo [ERROR] %TIME% - Ошибка при запуске службы Windows Update >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
    set /a ErrorCount+=1
)

net start cryptSvc >nul 2>&1
if !errorlevel! equ 0 (
    echo [INFO ] - Служба Cryptographic Services успешно запущена
    echo [INFO ] %TIME% - Служба Cryptographic Services успешно запущена >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
) else (
    echo [ERROR] - Ошибка при запуске службы Cryptographic Services
    echo [ERROR] %TIME% - Ошибка при запуске службы Cryptographic Services >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
    set /a ErrorCount+=1
)

net start bits >nul 2>&1
if !errorlevel! equ 0 (
    echo [INFO ] - Служба Background Intelligent Transfer Service успешно запущена
    echo [INFO ] %TIME% - Служба Background Intelligent Transfer Service успешно запущена >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
) else (
    echo [ERROR] - Ошибка при запуске службы Background Intelligent Transfer Service
    echo [ERROR] %TIME% - Ошибка при запуске службы Background Intelligent Transfer Service >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
    set /a ErrorCount+=1
)

net start msiserver >nul 2>&1
if !errorlevel! equ 0 (
    echo [INFO ] - Служба Windows Installer успешно запущена
    echo [INFO ] %TIME% - Служба Windows Installer успешно запущена >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
) else (
    echo [ERROR] - Ошибка при запуске службы Windows Installer
    echo [ERROR] %TIME% - Ошибка при запуске службы Windows Installer >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
    set /a ErrorCount+=1
)
rem Очистка папки Центра обновления Windows (конец)



rem Очистка кэша видеокарты
wmic path win32_VideoController get name | findstr /i "NVIDIA" >nul
if %errorlevel% equ 0 (
    for %%a in ("%USERPROFILE%\AppData\LocalLow\NVIDIA\PerDriverVersion\DXCache\*.*" ) do (
        if exist "%%a" (
            del /s /f /q "%%a" >nul 2>&1
            if !errorlevel! equ 0 (
                echo [INFO ] - Удален файл: %%a
                echo [INFO ] %TIME% - Файл %%a удален >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
                set /a DelFileCount+=1
            ) else (
                echo [ERROR] - Файл %%a не может быть удален
                echo [ERROR] %TIME% - Файл %%a не может быть удален >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
                set /a ErrorCount+=1
            )
        ) else (
            echo [WARN ] - Файл %%a не существует
            echo [WARN ] %TIME% - Файл %%a не существует >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
        )
    )
) else (
    wmic path win32_VideoController get name | findstr /i "AMD" >nul
    if %errorlevel% equ 0 (
        for %%a in ("%USERPROFILE%\AppData\Local\AMD\DxCache\*.*" ) do (
            if exist "%%a" (
                del /s /f /q "%%a" >nul 2>&1
                if !errorlevel! equ 0 (
                    echo [INFO ] - Удален файл: %%a
                    echo [INFO ] %TIME% - Файл %%a удален >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
                    set /a DelFileCount+=1
                ) else (
                    echo [ERROR] - Файл %%a не может быть удален
                    echo [ERROR] %TIME% - Файл %%a не может быть удален >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
                    set /a ErrorCount+=1
                )
            ) else (
                echo [WARN ] - Файл %%a не существует
                echo [WARN ] %TIME% - Файл %%a не существует >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
            )
        )
        mkdir "%USERPROFILE%\AppData\Local\AMD\DxCache" >nul 2>&1
    ) else (
        echo [WARN ] - Не обнаружено видеокарт NVIDIA или AMD
        echo [WARN ] %TIME% - Не обнаружено видеокарт NVIDIA или AMD >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
    )
)


title Очистка [3/3]
echo [INFO ] %TIME% - Очистка [3/3] запущена >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"

    :: Create registry keys for auto-selection of all cleanup options
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\BranchCache" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\D3D Shader Cache" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Delivery Optimization Files" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Device Driver Packages" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Language Pack" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Offline Pages Files" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\RetailDemo Offline Content" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Service Pack Cleanup" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Setup Log Files" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error memory dump files" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error minidump files" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Upgrade Discarded Files" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\User file versions" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Defender" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Files" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows ESD installation files" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files" /v "StateFlags65535" /t REG_DWORD /d 2 /f >nul 2>&1
    :: First try running directly
    cleanmgr /sagerun:65535    
    :: Runs disk cleanup with predefined settings (StateFlags65535) to clean temporary files, system files, and other cleanup tasks    
    :: If direct execution fails, try with full path
    if !errorlevel! neq 0 (
        echo Retrying with full path...
        %SystemRoot%\System32\cleanmgr.exe /sagerun:65535
    )
    
    :: Check final execution status
    if !errorlevel! equ 0 (
        echo Disk cleanup completed successfully.
    ) else (
        echo Error: Disk cleanup failed with code !errorlevel!
        echo Attempting to launch Disk Cleanup manually...
        start cleanmgr.exe
    )

echo [INFO ] %TIME% - Очистка завершена >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"

:: === Вторая проверка ===
for /f "skip=1 tokens=1,2" %%A in ('wmic logicaldisk where "DeviceID='%drive%'" get FreeSpace^,Size') do (
    if not defined free2 set free2=%%A
)

:: Переводим байты в мегабайты
set /a free1mb=%free1:~0,-6%
set /a free2mb=%free2:~0,-6%
:: Вычисляем разницу
set /a diff=%free2mb% - %free1mb%

timeout 1 /nobreak >nul
cls
TITLE ASX PC Cleaner %version% beta
echo.
echo.
echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: :::::::::
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+:
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########
echo.
echo         %COL%[37mОтчет о проделанной очистке%COL%[37m
echo         ---------------------------
echo.
echo         %COL%[92mПроцесс очистки завершен
echo         %COL%[93mУдалено %DelFileCount% файлов и %DelFolderCount% папок%COL%[37m
echo         %COL%[92mОчищено места: %diff% МБ
echo         %COL%[31mПроизошло ошибок: %ErrorCount%%COL%[37m
echo.
echo.
echo         %COL%[90mВы вернётесь назад автоматически через 10 секунд.
timeout 11 /nobreak >nul
echo [INFO ] %TIME% - Отчет о проделанной очистки >> "%ASX-Directory%\Files\Logs\%date%.txt"
echo [INFO ] %TIME% - Удалено %DelFileCount% файлов и %DelFolderCount% папок >> "%ASX-Directory%\Files\Logs\%date%.txt"
echo [INFO ] %TIME% - Всего ошибок при удалении файлов/папок: %ErrorCount% >> "%ASX-Directory%\Files\Logs\%date%.txt"
echo [INFO ] %TIME% - Завершено ASX_cleaner >> "%ASX-Directory%\Files\Logs\%date%.txt"
REM Дублирование логов в логи ASX_cleaner
echo [INFO ] %TIME% - Отчет о проделанной очистки >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
echo [INFO ] %TIME% - Удалено %DelFileCount% файлов и %DelFolderCount% папок >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
echo [INFO ] %TIME% - Всего ошибок при удалении файлов/папок: %ErrorCount% >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
echo [INFO ] %TIME% - Завершено ASX_cleaner >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"


:DelDirectory
REM Безопасное удаление директории и её содержимого
if exist "%~1\" (
    echo Удаление директории: %~1
    rd /s /q "%~1" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] - Не удалось удалить директорию: %~1
    ) else (
        echo [INFO ] - Директория удалена: %~1
        set /a DelFolderCount+=1
    )
) else (
    echo [INFO ] - Директория не найдена, пропускаем: %~1
)
goto :eof
