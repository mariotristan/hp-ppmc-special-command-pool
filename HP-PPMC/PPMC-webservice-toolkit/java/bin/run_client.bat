rem Synopsis: This script is used to run sample web service client under client/src 
rem 
rem Example:
rem   run_client examples.dm.DemandServiceClient http://localhost:8080/itg/ppmservices/DemandService

rem echo off
set WSCLIENT_HOME=%~dp0..

rem setup enviornment
call %WSCLIENT_HOME%\bin\setEnv.bat

set WSCLIENT_HOME=%~dp0..

rem setup source path
set SOURCE_PATH=%WSCLIENT_HOME%\client\src

rem setup dest path
set DEST_PATH=%WSCLIENT_HOME%\client\classes

echo running ...
java -classpath %CPATH% -Dclient.repository.dir=%WSCLIENT_HOME% %*

