@ECHO OFF
TITLE localDomains
SET "HostFile=%WinDir%\System32\drivers\etc\hosts"

:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (ECHO ELEV & shift /1 & goto gotPrivileges)

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

:MENU
SET Q=
CLS
ECHO.
ECHO  Select an option please
ECHO.
ECHO  ----------------------
ECHO  ^| [1] OPEN HOST FILE ^|
ECHO  ^| [2] CHECK FORWARDS ^|
ECHO  ^| [3] REGISTER PORT  ^|
ECHO  ^| [4] REMOVE PORT    ^|
ECHO  ^| [5] EXIT           ^|
ECHO  ----------------------
ECHO.
SET /P Q= #   
IF "%Q%"=="" GOTO EXIT
IF /I "%Q%" EQU "1" GOTO HOST
IF /I "%Q%" EQU "2" GOTO PORTS
IF /I "%Q%" EQU "3" GOTO NEW
IF /I "%Q%" EQU "4" GOTO DEL
IF /I "%Q%" EQU "5" EXIT
CLS
ECHO.
ECHO ------------------------------
ECHO ^| Enter a number from 1 to 5 ^|
ECHO ------------------------------
ECHO.
PAUSE
GOTO MENU
:HOST
CLS
ECHO.
ECHO   ********************************************************************
ECHO   *** You can start after 127.0.0.1 and so on in order to register ***
ECHO   *** a new domain.         For example: 127.0.0.2    docker.local ***
ECHO   ********************************************************************
ECHO.
ECHO.
ECHO.
ATTRIB -R %HostFile%
NOTEPAD "%HostFile%"
GOTO MENU
:PORTS
CLS
ECHO.
ECHO   *******************************************
ECHO   *** Table with working forwarded ports. ***
ECHO   *******************************************
ECHO.
ECHO.
ECHO.
netsh interface portproxy show v4tov4
ECHO.
ECHO.
ECHO.
PAUSE
GOTO MENU
:NEW
SET unusedIP=
SET port=
CLS
ECHO.
ECHO   *********************************************
ECHO   *** Your data must match your hosts file. ***
ECHO   *********************************************
ECHO.
ECHO.
ECHO.
START %HostFile% notepad
SET /P unusedIP=Unused IP address: 
IF "%unusedIP%"=="" GOTO MENU
SET /P port=Local port number: 
IF "%port%"=="" GOTO MENU
netsh interface portproxy add v4tov4 listenport=80 listenaddress=%unusedIP% connectport=%port% connectaddress=127.0.0.1
ECHO.
ECHO.
ECHO.
PAUSE
GOTO MENU
:DEL
SET usedIP=
CLS
ECHO.
ECHO   *******************************
ECHO   *** Remove a forward entry. ***
ECHO   *******************************
ECHO.
netsh interface portproxy show v4tov4
ECHO.
ECHO.
ECHO.
SET /P usedIP=IP address: 
IF "%usedIP%"=="" GOTO MENU
netsh interface portproxy delete v4tov4 listenport=80 listenaddress=%usedIP%
CLS
ECHO.
ECHO   *************************
ECHO   *** Your forwards now ***
ECHO   *************************
ECHO.
netsh interface portproxy show v4tov4
ECHO.
ECHO.
ECHO.
PAUSE
GOTO MENU
