@echo off
setlocal

set ANT_HOME=%CD%\ant

@IF "%JAVA_HOME%"=="" GOTO SetJavaHome
@GOTO RunAnt

:SetJavaHome
SET JAVA_HOME=C:\Java\jdk1.6.0_21
if "%JAVA_HOME%" == "" goto NoJavaHome

:RunAnt
set path="%JAVA_HOME%\bin";"%ANT_HOME%\bin";%path%

call "%ANT_HOME%\bin\ant" %*
goto end

:NoJavaHome
echo Must set the JAVA_HOME to either a JDK or JRE home directory
exit /b 1
:end

