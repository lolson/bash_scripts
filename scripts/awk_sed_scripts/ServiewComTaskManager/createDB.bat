@echo off 

REM usage: createDB [-batch] [-verbose]

set arg1=""
set arg2=""

if "%1" NEQ "" set arg1=%1
if "%2" NEQ "" set arg2=%2

call ant.bat createDB -Duser=%arg1% -Dpwd=%arg2%
