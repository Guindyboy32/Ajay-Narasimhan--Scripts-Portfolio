@echo off
setlocal enabledelayedexpansion

echo ============================================
echo   COPY AD GROUPS FROM TEMPLATE TO NEW USER
echo ============================================
echo.

:: Prompt for template user
set /p template=Enter template user's sAMAccountName: 

:: Prompt for new hire user
set /p targetSam=Enter NEW HIRE's sAMAccountName: 

echo.
echo Looking up DN for new hire: %targetSam%
for /f "usebackq delims=" %%d in (`dsquery user -samid %targetSam%`) do set targetDN=%%d

echo New hire DN found:
echo %targetDN%
echo.

echo Pulling groups from template user: %template%
echo.

for /f "usebackq delims=" %%g in (`dsquery user -samid %template% ^| dsget user -memberof`) do (
    set "grp=%%g"
    set "grp=!grp:"=!"
    echo ---------------------------------------------
    echo Group DN: !grp!
    echo Running: dsmod group "!grp!" -addmbr %targetDN%
    dsmod group "!grp!" -addmbr %targetDN%
    echo Return code: !errorlevel!
)

echo.
echo Finished processing all groups.
pause
endlocal
