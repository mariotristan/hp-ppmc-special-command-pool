rem Synopsis: This script is used to compile all classes under client/src 
rem 
rem Example:
rem         complie_client 
rem 


rem echo off
set WSCLIENT_HOME=%~dp0..

rem setup enviornment
call %WSCLIENT_HOME%\bin\setEnv.bat

rem setup source path
set SOURCE_PATH=%WSCLIENT_HOME%\client\src

rem setup dest path
set DEST_PATH=%WSCLIENT_HOME%\client\classes

IF EXIST %WSCLIENT_HOME%\client\classes\examples\dm\DemandServiceClient.class GOTO Start_compile

mkdir %DEST_PATH%

:Start_compile
echo compiling ...
dir %SOURCE_PATH%\*.java /s /b > %WSCLIENT_HOME%\bin\class.list
javac -classpath %CPATH% -d %DEST_PATH% -sourcepath %SOURCE_PATH% @%WSCLIENT_HOME%\bin\class.list
del /f %WSCLIENT_HOME%\bin\class.list

pause

rem java -Dclient.repository.dir=%WSCLIENT_HOME% -classpath %CPATH% examples.dm.DemandServiceClient http://localhost:8080/itg/ppmservices/DemandService
rem java -Dclient.repository.dir=%WSCLIENT_HOME% -classpath %CPATH% examples.pm.ProjectServiceClient http://localhost:8080/itg/ppmservices/ProjectService ProjectName
rem java -Dclient.repository.dir=%WSCLIENT_HOME% -classpath %CPATH% examples.fm60.BudgetServiceClient http://localhost:8080/itg/services/Finance admin admin create TestBudgetName




