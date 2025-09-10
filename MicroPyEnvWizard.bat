@ECHO OFF
SETLOCAL enabledelayedexpansion


ECHO.
ECHO.
ECHO MicroPyEnvWizard 1.0.0
ECHO.
ECHO.


WHERE python >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    WHERE py >nul 2>&1
    IF %ERRORLEVEL% EQU 0 (
        set "PYCMD=py -3"
    ) ELSE (
        ECHO [ALERT] Python not found in PATH. Please install Python and/or add it to PATH.
        PAUSE
        GOTO :END
    )
) ELSE (
    set "PYCMD=python"
)


set /p REPO_URL="Enter the GitHub repository URL: "
ECHO.


IF "%REPO_URL%"=="" (
    ECHO [ALERT] No repository URL entered. Exiting...
    PAUSE
    GOTO :END
)


git clone %REPO_URL%
IF %ERRORLEVEL% NEQ 0 (
    ECHO [ALERT] Failed to clone repository. Please check the URL.
    PAUSE
    GOTO :END
)


ECHO.
ECHO [INFO] Extract the repository folder name from the URL...
for %%a in (%REPO_URL%) do (
    set REPO_NAME=%%~nxa
)
set REPO_NAME=%REPO_NAME:.git=%


ECHO.
ECHO [INFO] Changing directory to the cloned repository...
CD %REPO_NAME%
ECHO [INFO] Current directory: %CD%


IF NOT EXIST "requirements.txt" (
    ECHO.
    ECHO [ALERT] No requirements.txt? The program finishes here...
    GOTO :END
)


ECHO.
ECHO [INFO] Creating Python virtual environment (.env)...
%PYCMD% -m venv .env
IF %ERRORLEVEL% NEQ 0 (
    ECHO [ALERT] Failed to create virtual environment with "%PYCMD% -m venv .env".
    ECHO [ALERT] Check permissions, disk space and Python installation.
    PAUSE
    GOTO :END
)


IF NOT EXIST ".env\Scripts\python.exe" (
    ECHO [ALERT] Virtual environment created but ".env\Scripts\python.exe" not found.
    ECHO [ALERT] The venv layout may be different or creation failed.
    PAUSE
    GOTO :END
)


ECHO.
ECHO [INFO] Activating the virtual environment...
call .env\Scripts\activate.bat
IF DEFINED VIRTUAL_ENV (
    ECHO [INFO] Virtual environment activated: %VIRTUAL_ENV%
) ELSE (
    ECHO [ALERT] Activation did not set VIRTUAL_ENV. Activation may have failed.
)


ECHO.
ECHO [INFO] Installing dependencies from requirements.txt...
ECHO [INFO] Using venv python to install packages...
".env\Scripts\python.exe" -m pip install -r requirements.txt
IF %ERRORLEVEL% NEQ 0 (
    ECHO [ALERT] pip install failed. Check network, package compatibility, and build tools.
    PAUSE
    GOTO :END
)


ECHO [INFO] Dependencies installed successfully (if any).
ECHO.


WHERE code >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    ECHO [INFO] Opening project in Visual Studio Code...
    code .
) ELSE (
    ECHO [ALERT] VS Code not found. Skipping editor opening.
)
ECHO.


:END
ECHO.
ECHO [INFO] Finishing Program.
TIMEOUT /t 2 /nobreak >nul
CMD /k
