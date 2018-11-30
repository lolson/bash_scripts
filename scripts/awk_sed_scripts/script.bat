
@echo off
REM     Simple Console Menu Script
goto menu
:menu
echo.
echo What would you like to do?
echo.
echo Choice
echo.
echo 1 Report 1
echo 2 Report 2
echo 3 Quit
echo.

:choice
set /P C=[1,2,3]?
if "%C%"=="1" goto report1
if "%C%"=="2" goto report2
if "%C%"=="3" goto quit
goto choice

:report1
echo Running report 1 
goto menu

:report2
echo Running report 2 
goto menu

:quit
exit
:end
