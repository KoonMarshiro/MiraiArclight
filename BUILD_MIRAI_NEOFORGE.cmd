@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\build-neoforge.ps1"
set RC=%ERRORLEVEL%
echo.
if not "%RC%"=="0" (
  echo [MiraiArclight] BUILD FAILED - exit %RC%
) else (
  echo [MiraiArclight] BUILD COMPLETE
)
pause
exit /b %RC%
