cls 
@echo off 

echo MISE A JOUR DU SERVEUR D'APPLICATION Novaxel.
echo Attention tous les utilisateurs vont etre deconnectes !
echo Confirmez-vous ? O/N

:QUESTION 
set /p "rep=>" 
if %rep%==O goto OUI 
if %rep%==N goto NON
if %rep%==o goto OUI 
if %rep%==n goto NON
if %rep%==y goto OUI 
if %rep%==Y goto OUI 
echo Repondez O ou N 
goto QUESTION 

:OUI 
net stop "NovaAppSrvSvc"
if %errorlevel% NEQ 0 if %errorlevel% NEQ 2 echo erreur lors de l'arret du service
if %errorlevel% NEQ 0 if %errorlevel% NEQ 2 pause
if %errorlevel% NEQ 0 if %errorlevel% NEQ 2  goto END 



rem RECHERCHE DU CHEMIN DU NAS DANS LA REGISTRY
rem -------------------------------------------
setlocal ENABLEEXTENSIONS
set KEY_NAME="HKEY_LOCAL_MACHINE\SOFTWARE\Novaxel\NovaAppServer"
set VALUE_NAME=REPINSTALL

FOR /F "usebackq tokens=1-2*" %%A IN (`REG QUERY %KEY_NAME% /v %VALUE_NAME% 2^>nul ^| find "%VALUE_NAME%"`) DO (
    set ValueName=%%A
    set ValueType=%%B
    set ValueValue=%%C
)

cd "%Valuevalue%"

echo. 
echo MISE A JOUR  EN COURS ...

.\tools32\script.exe .\sql\maj_domain.xnov 
if not errorlevel 1 goto suite
echo erreur dans maj_domain.xnov
pause
goto end

:suite
.\tools32\script.exe .\sql\maj_event.xnov
if not errorlevel 1 goto restart
echo erreur dans maj_event.xnov
pause 
goto end

:restart
net start "NovaAppSrvSvc"
if %errorlevel% NEQ 0 echo erreur dans le demarrage du service, echec de la mise a jour
if %errorlevel% NEQ 0 pause
if %errorlevel% NEQ 0 goto END 
echo maj ok
pause 
goto END 

:NON 
echo.
echo MISE A JOUR ANNULEE.echo.
pause
goto END 

:END