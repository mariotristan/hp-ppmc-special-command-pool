@echo off

rem get current directory
set WSCLIENT_HOME=%~dp0..

rem build CPATH
set CPATH=%WSCLIENT_HOME%\conf
set CPATH=%CPATH%;%WSCLIENT_HOME%\client\stubs\resources
set CPATH=%CPATH%;%WSCLIENT_HOME%\client\classes

rem add axis2 libraries
FOR  /f "delims=" %%A IN ('dir %WSCLIENT_HOME%\lib\axis2 /b /a-d') DO call :SetClassPathAxis2 %%A 
FOR  /f "delims=" %%A IN ('dir %WSCLIENT_HOME%\lib\axis1.1 /b /a-d') DO call :SetClassPathAxis1.1 %%A 
FOR  /f "delims=" %%A IN ('dir %WSCLIENT_HOME%\lib\rampart /b /a-d') DO call :SetClassPathRampart %%A 
FOR  /f "delims=" %%A IN ('dir %WSCLIENT_HOME%\lib\ppm /b /a-d') DO call :SetClassPathPPM %%A 


:SetClassPathAxis2
set CPATH=%CPATH%;%WSCLIENT_HOME%\lib\axis2\%1
goto :end

:SetClassPathAxis1.1
set CPATH=%CPATH%;%WSCLIENT_HOME%\lib\axis1.1\%1
goto :end

:SetClassPathRampart
set CPATH=%CPATH%;%WSCLIENT_HOME%\lib\rampart\%1
goto :end

:SetClassPathPPM
set CPATH=%CPATH%;%WSCLIENT_HOME%\lib\ppm\%1
goto :end

:end
