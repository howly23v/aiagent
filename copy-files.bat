@echo off
rem copy-files.bat
rem Usage:
rem   copy-files.bat "C:\path\to\source" "C:\path\to\dest" [--mirror] [--list] [--overwrite]
rem
rem Options:
rem   --mirror    Mirror source to destination (deletes extra files in destination)
rem   --list      List files that would be copied (no changes)
rem   --overwrite Overwrite files without prompting (robocopy default behavior)

setlocal EnableDelayedExpansion

if "%~1"=="" (
  echo Usage: %~nx0 "C:\path\to\source" "C:\path\to\dest" [--mirror] [--list] [--overwrite]
  exit /b 1
)

set "SRC=%~1"
set "DST=%~2"
if "%DST%"=="" (
  echo Destination required.
  echo Usage: %~nx0 "C:\path\to\source" "C:\path\to\dest" [--mirror] [--list] [--overwrite]
  exit /b 1
)

set "MIRROR=0"
set "LIST=0"
set "OVERWRITE=0"

rem parse optional args
shift
shift
:parse_opts
if "%~1"=="" goto after_opts
  if /I "%~1"=="--mirror" (set MIRROR=1) else (
  if /I "%~1"=="--list" (set LIST=1) else (
  if /I "%~1"=="--overwrite" (set OVERWRITE=1) ))
shift
goto parse_opts

:after_opts

echo Source: "%SRC%"
echo Destination: "%DST%"
if %MIRROR%==1 echo Mode: MIRROR
if %LIST%==1 echo Mode: LIST-ONLY

rem prefer robocopy if available
set "ROBO=%windir%\system32\robocopy.exe"
if exist "%ROBO%" (
  rem construct robocopy flags
  set "RC_FLAGS=/E /COPY:DAT /R:3 /W:5"
  if %MIRROR%==1 set "RC_FLAGS=%RC_FLAGS% /MIR"
  if %LIST%==1 set "RC_FLAGS=%RC_FLAGS% /L"
  if %OVERWRITE%==1 (
    rem robocopy overwrites by default; ensure attributes copied
    set "RC_FLAGS=%RC_FLAGS% /IS /IT"
  )
  echo Running: robocopy "%SRC%" "%DST%" %RC_FLAGS%
  robocopy "%SRC%" "%DST%" %RC_FLAGS%
  set "RC_EXIT=%ERRORLEVEL%"
  rem robocopy returns various codes; treat 0-7 as success-ish
  if %RC_EXIT% LEQ 7 (
    echo Robocopy finished with exit code %RC_EXIT% (check robocopy docs for meaning)
    exit /b 0
  ) else (
    echo Robocopy failed with exit code %RC_EXIT%
    exit /b %RC_EXIT%
  )
) else (
  rem fallback to xcopy
  echo robocopy not found, falling back to xcopy.
  set "XC_FLAGS=/E /I"
  if %OVERWRITE%==1 set "XC_FLAGS=%XC_FLAGS% /Y" else set "XC_FLAGS=%XC_FLAGS% /-Y"
  if %LIST%==1 (
    echo Listing files with xcopy is not supported; use robocopy on Windows 7+ for list-only.
    echo Proceeding with a dry-run by echoing files using for /R.
    for /R "%SRC%" %%F in (*) do echo %%~fF
    exit /b 0
  )
  echo Running: xcopy "%SRC%\\*" "%DST%" %XC_FLAGS%
  xcopy "%SRC%\\*" "%DST%" %XC_FLAGS%
  if errorlevel 1 (
    echo xcopy finished with errorlevel %errorlevel%
    exit /b %errorlevel%
  ) else (
    echo xcopy finished successfully.
    exit /b 0
  )
)

endlocal
