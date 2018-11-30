@echo off
setlocal
SET PATH=C:\Program Files\Java\jdk1.6.0_22\bin
java -cp . -jar C:\report-runner\lib\report-runner.jar %1 %2 %3
endlocal
