::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAjk
::fBw5plQjdCyDJGyX8VAjFD9VQg2LMFeeCbYJ5e31+/m7hUQJfPc9RK7o4vm+A60w5kDle5M/6nNXmcwJMB1ZaBuoYQF6oG1N1g==
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF65
::cxAkpRVqdFKZSjk=
::cBs/ulQjdF65
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
::Zh4grVQjdCyDJGyX8VAjFD9VQg2LMFeeCbYJ5e31+/m7hUQJfPc9RK7o4vm+A60w5kDle5M/6lxTlM4fMCt7QRGnaw46rHx+l1e9eve//iztT0mH41l+Hn1x5w==
::YB416Ek+ZW8=
::
::
::978f952a14a936cc963da21a135fa983
@echo off

:: Copyright (C) 2025 ALFiX, Inc.
:: Any tampering with the program code is forbidden (Запрещены любые вмешательства)

:: Запуск от имени администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    start "" /wait /I /min powershell -NoProfile -Command "Start-Process -FilePath '%~s0' -Verb RunAs"
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
set "Version=0.2.0"
set "VersionNumberCurrent=AP23S1"

set "VersionNumberList=Erorr"
set "UPDVER=Erorr"
set "FullVersionName=Erorr"
set StatusProject=1

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


REM Цветной текст
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a" & set "COL=%%b")

REM Логируем запуск ASX PC Cleaner
echo. >> "!ASX-Directory!\Files\Logs\%date%.txt"
echo 📌 Запуск ASX PC Cleaner >> "!ASX-Directory!\Files\Logs\%date%.txt"


REM ----- ОБНОВЛЕНИЯ -----
:UpdateCheck
echo [INFO ] %TIME% - Проверка обновлений ASX PC Cleaner >> "%ASX-Directory%\Files\Logs\%date%.txt"

:: Разделение версии на Major, Minor и Patch
for /f "tokens=1-3 delims=." %%a in ("%Version%") do (
    set "Major=%%a"
    set "Minor=%%b"
    set "Patch=%%c"
)

:: Если Patch равен нулю, установить версию без Patch
if "%Patch%"=="0" set "Version=%Major%.%Minor%"

:: Проверка подключения к интернету
ping -n 1 google.ru >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [WARN ] %TIME% - Соединение с интернетом отсутствует >> "%ASX-Directory%\Files\Logs\%date%.txt"
    set "WiFi=Off"    
    goto ASX_cleaner    
) else (
    set "WiFi=On"        
)

:: Получение текущей версии PC_Cleaner из реестра
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\PC_Cleaner" /v "PC_Cleaner_Version" 2^>nul ^| find /i "PC_Cleaner_Version"') do set "PC_Cleaner_Version_OLD=%%b"

if not exist "%ASX-Directory%\Files\Utilites\PC_Cleaner" md "%ASX-Directory%\Files\Utilites\PC_Cleaner"
:: Загрузка и регистрация PC_CleanerUpdater
if exist "%TEMP%\PC_CleanerUpdater.bat" del /s /q /f "%TEMP%\PC_CleanerUpdater.bat" >nul 2>&1
curl -s -o "%TEMP%\PC_CleanerUpdater.bat" "https://raw.githubusercontent.com/ALFiX01/ASX-Hub/main/Files/ASX/%FileVerCheckName%" 
if errorlevel 1 (
    echo [ERROR] %TIME% - Ошибка связи с сервером проверки обновлений >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto ASX_cleaner
)

TITLE Проверка обновлений

:: Загрузка нового файла PC_CleanerUpdater.bat
if exist "%TEMP%\PC_CleanerUpdater.bat" del /s /q /f "%TEMP%\PC_CleanerUpdater.bat" >nul 2>&1
curl -s -o "%TEMP%\PC_CleanerUpdater.bat" "https://raw.githubusercontent.com/ALFiX01/ASX-PC-Cleaner/refs/heads/main/PC_Cleaner_Version" 
if errorlevel 1 (
    echo [ERROR] %TIME% - Ошибка связи с сервером проверки обновлений >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto ASX_cleaner
)

:: Проверка успешной загрузки файла
if not exist "%TEMP%\PC_CleanerUpdater.bat" (
    echo [ERROR] %TIME% - Файл PC_CleanerUpdater.bat не был загружен >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto ASX_cleaner
)

:: Проверка размера файла (если файл пустой, то пропускаем)
for %%A in ("%TEMP%\PC_CleanerUpdater.bat") do if %%~zA equ 0 (
    echo [ERROR] %TIME% - Загруженный файл PC_CleanerUpdater.bat пуст >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto ASX_cleaner
)

:: Выполнение загруженного файла PC_CleanerUpdater.bat
call "%TEMP%\PC_CleanerUpdater.bat" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] %TIME% - Ошибка при выполнении PC_CleanerUpdater.bat >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto ASX_cleaner
)

:: Проверка, определены ли переменные после выполнения PC_CleanerUpdater.bat
if not defined UPDVER (
    echo [ERROR] %TIME% - Переменная UPDVER не определена после выполнения PC_CleanerUpdater.bat >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto ASX_cleaner
)

if not defined VersionNumberList (
    echo [ERROR] %TIME% - Переменная VersionNumberList не определена после выполнения PC_CleanerUpdater.bat >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto ASX_cleaner
)

:: Проверка, изменилась ли версия
echo "%VersionNumberList%" | findstr /i "%VersionNumberCurrent%" >nul
if errorlevel 1 (
    echo [INFO ] %TIME% - Доступно обновление v%UPDVER% >> "%ASX-Directory%\Files\Logs\%date%.txt"    
    goto Update_screen
) else (
    set "VersionFound=1"
    title Загрузка...
    echo [INFO ] %TIME% - Отсутствуют доступные обновления >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto ASX_cleaner
)


:ASX_cleaner
if not exist "%ASX-Directory%\Files\Logs\ASX_cleaner" md "%ASX-Directory%\Files\Logs\ASX_cleaner" >nul 2>&1
cls
TITLE ASX PC Cleaner %version% Alpha
echo.
echo.
echo                               %COL%[90m____  ______            ________
echo                              / __ \/ ____/           / ____/ /__  ____ _____  ___  _____
echo                             / /_/ / /      ______   / /   / / _ \/ __ `/ __ \/ _ \/ ___/
echo                            / ____/ /___   /_____/  / /___/ /  __/ /_/ / / / /  __/ / 
echo                           /_/    \____/            \____/_/\___/\__,_/_/ /_/\___/_/ %COL%[36mAlpha%COL%[90m
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
echo   %COL%[96mЗапускаю процесс очистки... %COL%[37m
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
    "browser.exe"
    "firefox.exe"
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
if exist "%EDGE_USER_DATA%\" (
    call :DelDirectory "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache"
    call :DelDirectory "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Code Cache"
    call :DelDirectory "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\GPUCache"
    call :DelDirectory "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Service Worker\CacheStorage"
    call :DelDirectory "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Service Worker\ScriptCache"
    echo [INFO ] - Папки кэша Edge очищены.
) else ( echo [WARN ] - Папка данных Edge не найдена. )

:: Google Chrome
if exist "%CHROME_USER_DATA%\" (
    call :DelDirectory "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache"
    call :DelDirectory "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Code Cache"
    call :DelDirectory "%LOCALAPPDATA%\Google\Chrome\User Data\Default\GPUCache"
    call :DelDirectory "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Service Worker\CacheStorage"
    call :DelDirectory "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Service Worker\ScriptCache"
    echo [INFO ] - Папки кэша Chrome очищены.
) else ( echo [WARN ] - Папка данных Chrome не найдена. )


:: Yandex Browser
if exist "%CHROME_USER_DATA%\" (
    call :DelDirectory "%LocalAppData%\Yandex\YandexBrowser\User Data\Default\Cache"
    call :DelDirectory "%LocalAppData%\Yandex\YandexBrowser\User Data\Default\Code Cache"
    call :DelDirectory "%LocalAppData%\Yandex\YandexBrowser\User Data\Default\GPUCache"
    call :DelDirectory "%LocalAppData%\Yandex\YandexBrowser\User Data\Default\Media Cache"
    echo [INFO ] - Папки кэша Yandex очищены.
) else ( echo [WARN ] - Папка данных Yandex не найдена. )

rem Очистка корзины и удаление файлов 
chcp 850 >nul 2>&1
for /f "tokens=*" %%a in ('powershell -Command "Get-ChildItem -Path 'C:\$Recycle.Bin' -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName"') do (
    set /a DelFileCount+=1
)
powershell -Command "Clear-RecycleBin -Confirm:$false -ErrorAction SilentlyContinue"
chcp 65001 >nul 2>&1

rem удаление мусора
for %%a in (
"%WinDir%\Temp\*.*"
"%systemdrive%*.tmp"
"%systemdrive%*.temp"
"%systemdrive%*.temp*"
"%systemdrive%*.chk"
"%systemdrive%*._mp"
"%systemdrive%*.gid"
"%SYSTEMDRIVE%\Windows\SoftwareDistribution\Download\*.*"
"%SYSTEMDRIVE%\Windows\SoftwareDistribution\DataStore\*.*"
"%WinDir%\Installer\$PatchCache$\*.*"
"%SYSTEMDRIVE%\AMD\*.*"
"%SYSTEMDRIVE%\NVIDIA\*.*"
"%SYSTEMDRIVE%\INTEL\*.*"
"%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db"
"%LocalAppData%\Microsoft\Windows\Explorer\*.db"
"%systemdrive%\*.log"
"%systemdrive%\*.old"
"%windir%\*.bak"
"%windir%\Logs\CBS\CbsPersist*.log"
"%windir%\Logs\DISM\dism.log"
"%windir%\Logs\MoSetup\*.log"
"%windir%\Panther\*.log"
"%windir%\logs\*.log"
"%systemdrive%\*.trace"
"%WinDir%\Prefetch\*.*"
"%Temp%\*.*"
"%AppData%\Temp\*.*"
"%UserProfile%\Downloads\*.crdownload"
"%AppData%\Microsoft\Windows\Recent\*"
"%HomePath%\AppData\LocalLow\Temp\*.*"
"%LocalAppData%\Microsoft\Windows\INetCache\."
"%AppData%\Local\Microsoft\Windows\INetCookies\."
"%AppData%\Discord\Cache\."
"%AppData%\Discord\Code Cache\."
"%localappdata%\Microsoft\Windows\WebCache\*.log"
"%ProgramData%\Microsoft\Windows Defender\Network Inspection System\Support\*.*"
"%ProgramData%\Microsoft\Windows Defender\Scans\History\CacheManager\*.log"
"%ProgramData%\Microsoft\Windows Defender\Scans\History\ReportLatency\Latency\*.log"
"%ProgramData%\Microsoft\Windows Defender\Scans\History\Service\*.log"
"%ProgramData%\Microsoft\Windows Defender\Scans\MetaStore\*.log"
"%ProgramData%\Microsoft\Windows Defender\Scans\History\*.*"
"%ProgramData%\Microsoft\Windows Defender\Support\*.*"
"%ProgramData%\Microsoft\Windows Defender\Scans\History\Results\Quick\*.log"
"%ProgramData%\Microsoft\Windows Defender\Scans\History\Results\Resource\*.log"
"%windir%\Minidump\*.dmp"
"%windir%\LiveKernelReports\*.dmp"
"%windir%\LiveKernelReports\WATCHDOG\*.dmp"
"%windir%\LiveKernelReports\WHEA\*.dmp"
"%localappdata%\CrashDumps\*.dmp"
) do (
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
set "LogFile=%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"

for %%a in (
    "%WinDir%\Temp" 
    "%WinDir%\Prefetch" 
    "%Temp%" 
    "%AppData%\Temp" 
    "%systemdrive%\windows.old" 
    "%ASX-Directory%\Files\Downloads" 
    "%SystemDrive%\OneDriveTemp" 
    "%ProgramData%\Microsoft\Diagnosis" 
    "%ProgramData%\Microsoft\Network" 
    "%ProgramData%\Microsoft\Search" 
    "%LocalAppData%\Microsoft\Windows\AppCache" 
    "%LocalAppData%\Microsoft\Windows\History" 
    "%LocalAppData%\Microsoft\Windows\WebCache" 
    "%ProgramFiles(x86)%\Steam\logs"
) do (
    if exist "%%a" (
        echo [INFO ] - Удаление папки: %%a
        del /s /q "%%a\*.*" >nul 2>&1
        if !errorlevel! equ 0 (
            echo [INFO ] - Папка %%a успешно удалена
            echo [INFO ] %TIME% - Папка %%a успешно удалена >> %LogFile%
            set /a DelFolderCount+=1
        ) else (
            echo [ERROR] - Не удалось удалить папку: %%a
            echo [ERROR] %TIME% - Не удалось удалить папку %%a >> %LogFile%
            set /a ErrorCount+=1
        )
    ) else (
        echo [WARN ] - Папка %%a не существует
        echo [WARN ] %TIME% - Папка %%a не существует >> %LogFile%
    )
)


:: --------------------Clear Steam dumps---------------------
echo [INFO ] - Очистка дампов Steam...
:: Clear directory contents  : "%PROGRAMFILES(X86)%\Steam\Dumps"
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$pathGlobPattern = "^""$($directoryGlob = '%PROGRAMFILES(X86)%\Steam\Dumps'; if ($directoryGlob.EndsWith('\*')) { $directoryGlob } elseif ($directoryGlob.EndsWith('\')) { "^""$($directoryGlob)*"^"" } else { "^""$($directoryGlob)\*"^"" } )"^""; $expandedPath = [System.Environment]::ExpandEnvironmentVariables($pathGlobPattern); Write-Host "^""Searching for items matching pattern: `"^""$($expandedPath)`"^""."^""; $deletedCount = 0; $failedCount = 0; $foundAbsolutePaths = @(); Write-Host 'Iterating files and directories recursively.'; try { $foundAbsolutePaths += @(; Get-ChildItem -Path $expandedPath -Force -Recurse -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; try { $foundAbsolutePaths += @(; Get-Item -Path $expandedPath -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; $foundAbsolutePaths = $foundAbsolutePaths | Select-Object -Unique | Sort-Object -Property { $_.Length } -Descending; if (!$foundAbsolutePaths) { Write-Host 'Skipping, no items available.'; exit 0; }; Write-Host "^""Initiating processing of $($foundAbsolutePaths.Count) items from `"^""$expandedPath`"^""."^""; foreach ($path in $foundAbsolutePaths) { if (-not (Test-Path $path)) { <# Re-check existence as prior deletions might remove subsequent items (e.g., subdirectories). #>; Write-Host "^""Successfully deleted: $($path) (already deleted)."^""; $deletedCount++; continue; }; try { Remove-Item -Path $path -Force -Recurse -ErrorAction Stop; $deletedCount++; Write-Host "^""Successfully deleted: $($path)"^""; } catch { $failedCount++; Write-Warning "^""Unable to delete $($path): $_"^""; }; }; Write-Host "^""Successfully deleted $($deletedCount) items."^""; if ($failedCount -gt 0) { Write-Warning "^""Failed to delete $($failedCount) items."^""; }"
chcp 65001 >nul 2>&1

:: --------------------Clear Steam traces--------------------
echo [INFO ] - Очистка следов Steam...
:: Clear directory contents  : "%PROGRAMFILES(X86)%\Steam\Traces"
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$pathGlobPattern = "^""$($directoryGlob = '%PROGRAMFILES(X86)%\Steam\Traces'; if ($directoryGlob.EndsWith('\*')) { $directoryGlob } elseif ($directoryGlob.EndsWith('\')) { "^""$($directoryGlob)*"^"" } else { "^""$($directoryGlob)\*"^"" } )"^""; $expandedPath = [System.Environment]::ExpandEnvironmentVariables($pathGlobPattern); Write-Host "^""Searching for items matching pattern: `"^""$($expandedPath)`"^""."^""; $deletedCount = 0; $failedCount = 0; $foundAbsolutePaths = @(); Write-Host 'Iterating files and directories recursively.'; try { $foundAbsolutePaths += @(; Get-ChildItem -Path $expandedPath -Force -Recurse -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; try { $foundAbsolutePaths += @(; Get-Item -Path $expandedPath -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; $foundAbsolutePaths = $foundAbsolutePaths | Select-Object -Unique | Sort-Object -Property { $_.Length } -Descending; if (!$foundAbsolutePaths) { Write-Host 'Skipping, no items available.'; exit 0; }; Write-Host "^""Initiating processing of $($foundAbsolutePaths.Count) items from `"^""$expandedPath`"^""."^""; foreach ($path in $foundAbsolutePaths) { if (-not (Test-Path $path)) { <# Re-check existence as prior deletions might remove subsequent items (e.g., subdirectories). #>; Write-Host "^""Successfully deleted: $($path) (already deleted)."^""; $deletedCount++; continue; }; try { Remove-Item -Path $path -Force -Recurse -ErrorAction Stop; $deletedCount++; Write-Host "^""Successfully deleted: $($path)"^""; } catch { $failedCount++; Write-Warning "^""Unable to delete $($path): $_"^""; }; }; Write-Host "^""Successfully deleted $($deletedCount) items."^""; if ($failedCount -gt 0) { Write-Warning "^""Failed to delete $($failedCount) items."^""; }"
chcp 65001 >nul 2>&1

:: --------------------Clear Steam cache---------------------
echo [INFO ] - Очистка кеша Steam...
:: Clear directory contents  : "%ProgramFiles(x86)%\Steam\appcache"
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$pathGlobPattern = "^""$($directoryGlob = '%ProgramFiles(x86)%\Steam\appcache'; if ($directoryGlob.EndsWith('\*')) { $directoryGlob } elseif ($directoryGlob.EndsWith('\')) { "^""$($directoryGlob)*"^"" } else { "^""$($directoryGlob)\*"^"" } )"^""; $expandedPath = [System.Environment]::ExpandEnvironmentVariables($pathGlobPattern); Write-Host "^""Searching for items matching pattern: `"^""$($expandedPath)`"^""."^""; $deletedCount = 0; $failedCount = 0; $foundAbsolutePaths = @(); Write-Host 'Iterating files and directories recursively.'; try { $foundAbsolutePaths += @(; Get-ChildItem -Path $expandedPath -Force -Recurse -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; try { $foundAbsolutePaths += @(; Get-Item -Path $expandedPath -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; $foundAbsolutePaths = $foundAbsolutePaths | Select-Object -Unique | Sort-Object -Property { $_.Length } -Descending; if (!$foundAbsolutePaths) { Write-Host 'Skipping, no items available.'; exit 0; }; Write-Host "^""Initiating processing of $($foundAbsolutePaths.Count) items from `"^""$expandedPath`"^""."^""; foreach ($path in $foundAbsolutePaths) { if (-not (Test-Path $path)) { <# Re-check existence as prior deletions might remove subsequent items (e.g., subdirectories). #>; Write-Host "^""Successfully deleted: $($path) (already deleted)."^""; $deletedCount++; continue; }; try { Remove-Item -Path $path -Force -Recurse -ErrorAction Stop; $deletedCount++; Write-Host "^""Successfully deleted: $($path)"^""; } catch { $failedCount++; Write-Warning "^""Unable to delete $($path): $_"^""; }; }; Write-Host "^""Successfully deleted $($deletedCount) items."^""; if ($failedCount -gt 0) { Write-Warning "^""Failed to delete $($failedCount) items."^""; }"
chcp 65001 >nul 2>&1
:: ----------------------------------------------------------


:: Список служб для остановки
for %%S in ("wuauserv" "cryptSvc" "bits" "msiserver") do (
    sc stop %%S >nul 2>&1
    if !errorlevel! equ 0 (
        echo [INFO ] %TIME% - Служба %%S успешно остановлена >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
    ) else (
        echo [ERROR] %TIME% - Ошибка при остановке службы %%S >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
        set /a ErrorCount+=1
    )
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
REM Список служб для запуска
set "ServicesList=wuauserv cryptSvc bits msiserver"

for %%S in (%ServicesList%) do (
    net start %%S >nul 2>&1
    if !errorlevel! equ 0 (
        echo [INFO ] - Служба %%S успешно запущена
        echo [INFO ] %TIME% - Служба %%S успешно запущена >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
    ) else (
        echo [ERROR] - Ошибка при запуске службы %%S
        echo [ERROR] %TIME% - Ошибка при запуске службы %%S >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
        set /a ErrorCount+=1
    )
)

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
TITLE ASX PC Cleaner %version% Alpha

echo.
echo.
echo                               %COL%[90m____  ______            ________
echo                              / __ \/ ____/           / ____/ /__  ____ _____  ___  _____
echo                             / /_/ / /      ______   / /   / / _ \/ __ `/ __ \/ _ \/ ___/
echo                            / ____/ /___   /_____/  / /___/ /  __/ /_/ / / / /  __/ / 
echo                           /_/    \____/            \____/_/\___/\__,_/_/ /_/\___/_/ %COL%[36mAlpha%COL%[90m
echo.
echo                           %COL%[37mОтчет о проделанной очистке%COL%[37m
echo                           ---------------------------
echo.
echo                           %COL%[92mПроцесс очистки завершен
echo                           %COL%[93mУдалено %DelFileCount% файлов и %DelFolderCount% папок%COL%[37m
echo                           %COL%[92mОчищено места: ~%diff% МБ
REM echo                           %COL%[31mПроизошло ошибок: %ErrorCount%%COL%[37m
echo.
echo.
echo         %COL%[90mВы вернётесь назад автоматически через 10 секунд.
echo  %TIME% - Отчет о проделанной очистки >> "%ASX-Directory%\Files\Logs\%date%.txt"
echo  %TIME% - Удалено %DelFileCount% файлов и %DelFolderCount% папок >> "%ASX-Directory%\Files\Logs\%date%.txt"
echo  %TIME% - Всего ошибок при удалении файлов/папок: %ErrorCount% >> "%ASX-Directory%\Files\Logs\%date%.txt"
echo  %TIME% - Завершено ASX_cleaner >> "%ASX-Directory%\Files\Logs\%date%.txt"
timeout 11 /nobreak >nul
REM Дублирование логов в логи ASX_cleaner
echo  %TIME% - Отчет о проделанной очистки >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
echo  %TIME% - Удалено %DelFileCount% файлов и %DelFolderCount% папок >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
echo  %TIME% - Всего ошибок при удалении файлов/папок: %ErrorCount% >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
echo  %TIME% - Завершено ASX_cleaner >> "%ASX-Directory%\Files\Logs\ASX_cleaner\%date%.txt"
goto ASX_cleaner

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


:Update_screen
cls
echo.
echo.
echo                               %COL%[90m____  ______            ________
echo                              / __ \/ ____/           / ____/ /__  ____ _____  ___  _____
echo                             / /_/ / /      ______   / /   / / _ \/ __ `/ __ \/ _ \/ ___/
echo                            / ____/ /___   /_____/  / /___/ /  __/ /_/ / / / /  __/ / 
echo                           /_/    \____/            \____/_/\___/\__,_/_/ /_/\___/_/ %COL%[36mAlpha%COL%[90m
echo.
echo.
echo.
echo.
echo.
TITLE Доступно обновление v%UPDVER%
echo [INFO ] %TIME% - Доступно обновление v%UPDVER% >> "%ASX-Directory%\Files\Logs\%date%.txt"	
echo                                             Доступно обновление%COL%[36m v%UPDVER%
echo.
echo                                                  Хотите обновить?

echo.
echo.
echo.
echo.
echo                                      %COL%[92mY - Обновить      %COL%[37m^|%COL%[91m      N - Не обновлять
echo %COL%[90m
echo.
echo.
%SYSTEMROOT%\System32\choice.exe /c:YяNт /n /m "%DEL%                                                    >: "
set choice=!errorlevel!
if !choice! == 1 ( echo Загрузка обновления...
        curl -g -L -# -o "%TEMP%\PC-Cleaner_Updater.exe" "https://github.com/ALFiX01/ASX-PC-Cleaner/raw/main/Files/Updater/PC-Cleaner_Updater.exe"
        echo [INFO ] %TIME% - Обновление %UPDVER% скачано >> "%ASX-Directory%\Files\Logs\%date%.txt"
        start "" "%TEMP%\PC-Cleaner_Updater.exe"
        exit
)
if !choice! == 2 ( echo Загрузка обновления...
        curl -g -L -# -o "%TEMP%\PC-Cleaner_Updater.exe" "https://github.com/ALFiX01/ASX-PC-Cleaner/raw/main/Files/Updater/PC-Cleaner_Updater.exe"
        echo [INFO ] %TIME% - Обновление %UPDVER% скачано >> "%ASX-Directory%\Files\Logs\%date%.txt"
        start "" "%TEMP%\PC-Cleaner_Updater.exe"
        exit
)
if !choice! == 3 (
	title Загрузка	
	set NoUpd=1
	call:ASX_cleaner
	) else (
	echo [INFO ] %TIME% - Пользователь отказался от загрузки Обновления %UPDVER% >> "%ASX-Directory%\Files\Logs\%date%.txt"
)
if !choice! == 4 (
	title Загрузка	
	set NoUpd=1
	call:ASX_cleaner
	) else (
	echo [INFO ] %TIME% - Пользователь отказался от загрузки Обновления %UPDVER% >> "%ASX-Directory%\Files\Logs\%date%.txt"
)
call:Update_screen