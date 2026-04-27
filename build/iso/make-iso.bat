@echo off
echo OmniLinux ISO Creator for Windows
echo.
where 7z >nul 2>&1 || echo ERROR: Install 7-Zip first
set ISO_FILE=omnilinux-1.0-alpha-full-x86_64.iso
echo Creating %ISO_FILE%...
echo Note: This creates a basic archive, not a bootable ISO
echo For bootable ISO, use Linux with genisoimage/xorriso
pause
