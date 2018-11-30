
@echo off
REM     Simple Console Menu Script
goto menu
:menu
echo.
echo What report would you like to run?
echo.
echo Choice
echo.
echo 1 Device Message Summary Report
echo 2 Device Messaging Report
echo 3 Total Install Report
echo 4 Failed Messages Report
echo 5 Quit
echo.

:choice
set /P C=[1,2,3,4]?
if "%C%"=="1" goto report1
if "%C%"=="2" goto report2
if "%C%"=="3" goto report3
if "%C%"=="4" goto report4
if "%C%"=="5" goto quit
goto choice

:report1
ReportRunner.bat XLS DEVICE_MESSAGE_REPORT
goto menu

:report2
ReportRunner.bat XLS MESSAGING_REPORT
goto menu

:report3
ReportRunner.bat XLS TOTAL_INSTALL_REPORT
goto menu

:report4
ReportRunner.bat XLS FAILED_MESSAGE_REPORT
goto menu

:quit
exit
:end
