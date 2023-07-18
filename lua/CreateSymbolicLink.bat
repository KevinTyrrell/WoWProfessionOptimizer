@echo off

REM 2023/07/17 - Kevin Tyrrell
REM NOTE: You must run this script with administrator privileges.
REM This script is for development of WoWProfessionOptimizer.
REM Run the script with the WoWProfessionOptimizer/ addon in the same folder.
REM A symbolic link pointing to WoWProfessionOptimizer/ will be created in the addons folder.

REM Set the source and target directories
set "sourceDir=%~dp0/WoWProfessionOptimizer"
set "targetDir=C:\Program Files (x86)\World of Warcraft\_classic_\Interface\AddOns\WoWProfessionOptimizer"

REM Create a symbolic link
mklink /D "%targetDir%" "%sourceDir%"
pause