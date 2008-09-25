rem Synopsis: This script is used to generate new stubs if WSDL/xsd files under conf are modified 
rem 
rem Example:
rem   wsdl2java DemandService

rem echo off
set WSCLIENT_HOME=%~dp0..

rem setup enviornment
call %WSCLIENT_HOME%\bin\setEnv.bat


rem set WSDL file name
set WSDL_FILE=%WSCLIENT_HOME%\conf\wsdl\%1.wsdl
set SERVICE_NAME=%1

rem set target directory
set TARGET_DIR=%WSCLIENT_HOME%\client\stubs

rem set default package name
set DEFAULT_PACKAGE_DM=com.mercury.itg.ws.dm.client
set DEFAULT_PACKAGE_PM=com.mercury.itg.ws.pm.client
set DEFAULT_PACKAGE_RM=com.mercury.itg.ws.rm.client
set DEFAULT_PACKAGE_TM=com.mercury.itg.ws.tm.client
set DEFAULT_PACKAGE_FM=com.mercury.itg.ws.fm.client

rem ==========================
rem set namespace mapping
rem
rem Note: you don't need to change this mapping when generate
rem       stubs for different services
rem 

rem set service name


rem map for common
set NS_PACKAGE_MAP=http://mercury.com/ppm/common/1.0=com.mercury.itg.ws.common.client

rem map for dm
set NS_PACKAGE_MAP=%NS_PACKAGE_MAP%,http://mercury.com/ppm/dm/service/1.0=com.mercury.itg.ws.dm.client,http://mercury.com/ppm/dm/1.0=com.mercury.itg.ws.dm.client

rem map for pm 
set NS_PACKAGE_MAP=%NS_PACKAGE_MAP%,http://mercury.com/ppm/pm/1.0=com.mercury.itg.ws.pm.client,http://mercury.com/ppm/pm/service/1.0=com.mercury.itg.ws.pm.client,http://www.mercury.com/ppm/pm/service/1.0=com.mercury.itg.ws.pm.client

rem map for tm
set NS_PACKAGE_MAP=%NS_PACKAGE_MAP%,http://mercury.com/ppm/tm/1.0=com.mercury.itg.ws.tm.client,http://mercury.com/ppm/tm/service/1.0=com.mercury.itg.ws.tm.client

rem map for rm
set NS_PACKAGE_MAP=%NS_PACKAGE_MAP%,http://www.mercury.com/ppm/rm/1.0=com.mercury.itg.ws.rm.client,http://mercury.com/ppm/rm/service/1.0=com.mercury.itg.ws.rm.client,http://mercury.com/ppm/rm/1.0=com.mercury.itg.ws.rm.client

rem map for fm
set NS_PACKAGE_MAP=%NS_PACKAGE_MAP%,http://www.mercury.com/ppm/fm/1.0=com.mercury.itg.ws.fm.client,http://mercury.com/ppm/fm/service/1.0=com.mercury.itg.ws.fm.client,http://mercury.com/ppm/fm/1.0=com.mercury.itg.ws.fm.client

rem end of mapping
rem ========================

rem generate the stub source
echo generatig stubs ...
java -classpath %CPATH% org.apache.axis2.wsdl.WSDL2Java -d xmlbeans -uri %WSDL_FILE% -sd -g -o %TARGET_DIR% -p %DEFAULT_PACKAGE_DM% -ssi  -ns2p %NS_PACKAGE_MAP% -sn %SERVICE_NAME%

rem compile stubs
echo compiling ...
dir %TARGET_DIR%\*.java /s /b > %WSCLIENT_HOME%\bin\class.list
javac -classpath %CPATH% -d %WSCLIENT_HOME%\client\classes -sourcepath %TARGET_DIR%\src @%WSCLIENT_HOME%\bin\class.list
del /f %WSCLIENT_HOME%\bin\class.list


