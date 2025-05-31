@echo off
setlocal enabledelayedexpansion

REM Set Git path
set GIT=git
where git >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Git not found. Ensure Git is installed and in PATH. > gitlog.txt
    exit /b 1
)

REM Navigate to the repo
cd /d "C:\Python Path\Roaming\wi-fi-adapter-search"
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to navigate to repository directory. > gitlog.txt
    exit /b 1
)
IF NOT EXIST .git (
    echo ERROR: Directory is not a Git repository. > gitlog.txt
    exit /b 1
)

REM Mark repo as safe
echo Setting safe directory... >> gitlog.txt
"%GIT%" config --global --add safe.directory "C:/Python Path/Roaming/wi-fi-adapter-search" >> gitlog.txt 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to set safe directory. Exit code: %ERRORLEVEL% >> gitlog.txt
    exit /b %ERRORLEVEL%
)

REM Set Git identity
echo Setting Git user identity... >> gitlog.txt
"%GIT%" config user.name "Eric Camulli" >> gitlog.txt 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to set user.name. Exit code: %ERRORLEVEL% >> gitlog.txt
    exit /b %ERRORLEVEL%
)
"%GIT%" config user.email "eric.camulli@7signal.com" >> gitlog.txt 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to set user.email. Exit code: %ERRORLEVEL% >> gitlog.txt
    exit /b %ERRORLEVEL%
)

REM Log environment info
echo Running as: %USERNAME% at %date% %time% > gitlog.txt
echo Current directory: %CD% >> gitlog.txt
echo Git remote: >> gitlog.txt
"%GIT%" remote -v >> gitlog.txt 2>&1
echo Current branch: >> gitlog.txt
"%GIT%" branch --show-current >> gitlog.txt 2>&1
echo Git status before staging: >> gitlog.txt
"%GIT%" status >> gitlog.txt 2>&1

REM Check if data.json exists
IF NOT EXIST data.json (
    echo ERROR: data.json does not exist. >> gitlog.txt
    exit /b 1
)

REM Stage the data file
echo Staging data.json... >> gitlog.txt
"%GIT%" add data.json >> gitlog.txt 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to stage data.json. Exit code: %ERRORLEVEL% >> gitlog.txt
    exit /b %ERRORLEVEL%
)

REM Show staged changes
echo === STAGED DIFF === >> gitlog.txt
"%GIT%" diff --cached --name-status >> gitlog.txt 2>&1
"%GIT%" diff --cached >> gitlog.txt 2>&1
echo ==================== >> gitlog.txt

REM Check for staged changes
echo Checking for staged changes... >> gitlog.txt
"%GIT%" diff --cached --quiet
set diffError=%ERRORLEVEL%
echo Diff check exit code: %diffError% >> gitlog.txt
IF %diffError% EQU 0 (
    echo No changes detected in data.json. Nothing to commit. >> gitlog.txt
    echo Script completed at %date% %time% >> gitlog.txt
    exit /b 0
)

REM Attempt commit
echo Changes detected, preparing commit... >> gitlog.txt
set "commitMsg=Auto-update on %date:/=-% %time%"
echo Commit message: %commitMsg% >> gitlog.txt
echo Executing git commit... >> gitlog.txt
"%GIT%" commit -m "%commitMsg%" >> gitlog.txt 2>&1
set commitError=%ERRORLEVEL%
echo Commit exit code: %commitError% >> gitlog.txt
IF %commitError% NEQ 0 (
    echo ERROR: Commit failed with exit code %commitError%. Run 'git commit -m "test"' manually to debug. >> gitlog.txt
    echo Script failed at %date% %time% >> gitlog.txt
    exit /b %commitError%
)

REM Attempt push
echo Commit succeeded, attempting push... >> gitlog.txt
"%GIT%" push origin main >> gitlog.txt 2>&1
set pushError=%ERRORLEVEL%
echo Push exit code: %pushError% >> gitlog.txt
IF %pushError% NEQ 0 (
    echo ERROR: Push failed with exit code %pushError%. Check PAT in Windows Credential Manager or run 'git push origin main' manually to debug. >> gitlog.txt
    echo Script failed at %date% %time% >> gitlog.txt
    exit /b %pushError%
)

REM Success
echo Commit and push complete. >> gitlog.txt
echo Script completed at %date% %time% >> gitlog.txt
exit /b 0