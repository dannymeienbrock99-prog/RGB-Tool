@echo off
title PRISM RGB Studio
cd /d "%~dp0"
if not exist "runtime\node.exe" (
  echo Die Programmlaufzeit fehlt. Bitte PRISM erneut installieren oder das gesamte portable ZIP entpacken.
  pause
  exit /b 1
)
"runtime\node.exe" "server\launch.mjs"
if errorlevel 1 pause
