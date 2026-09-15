@echo off
rem ---------------------------------------------------------------------------
rem  Puts one page's HTML on the Windows clipboard, ready to paste into a
rem  website builder.
rem
rem  Double-click it, press a number, press Enter.
rem  Or from a terminal:   COPY-A-PAGE.bat show
rem                        COPY-A-PAGE.bat show plain
rem
rem  TWO VERSIONS OF EVERY PAGE:
rem    BAKED (default)  baked\*.html   - photos built into the HTML itself.
rem                     Nothing else to upload. Use this for Stride.
rem    PLAIN            *.html         - photos stay in the images\ folder,
rem                     which has to be uploaded alongside. Smaller, faster
rem                     pages - use it on real web hosting.
rem ---------------------------------------------------------------------------
cd /d "%~dp0"
title WWCA - copy a page to the clipboard

set "SUB=baked\"
set "MODENAME=BAKED - photos built in, nothing else to upload"

rem --- page name passed in on the command line ------------------------------
if not "%~1"=="" goto fromarg

:menu
cls
echo.
echo    WWCA WEBSITE - COPY A PAGE TO THE CLIPBOARD
echo    ===========================================
echo.
echo      1   Home                5   Youth Programs
echo      2   2027 Show           6   Gallery
echo      3   Vendors             7   About
echo      4   Membership          8   Contact
echo.
echo      9   Blank template
echo.
echo    ---------------------------------------------------------
echo      Mode:  %MODENAME%
echo      B      Switch between BAKED and PLAIN
echo      0      Quit
echo    ---------------------------------------------------------
echo.

set "page="
set "choice="
set /p "choice=   Type a number and press Enter:  "

if /i "%choice%"=="B" goto toggle
if "%choice%"=="0" goto done
if "%choice%"=="1" set "page=index"
if "%choice%"=="2" set "page=show"
if "%choice%"=="3" set "page=vendors"
if "%choice%"=="4" set "page=membership"
if "%choice%"=="5" set "page=youth"
if "%choice%"=="6" set "page=gallery"
if "%choice%"=="7" set "page=about"
if "%choice%"=="8" set "page=contact"
if "%choice%"=="9" set "page=_template"
if not defined page goto badchoice

call :copy "%page%"
goto menu

:toggle
if defined SUB goto goplain
set "SUB=baked\"
set "MODENAME=BAKED - photos built in, nothing else to upload"
goto menu
:goplain
set "SUB="
set "MODENAME=PLAIN - needs the images folder uploaded too"
goto menu

:badchoice
echo.
echo    Sorry - "%choice%" is not on the list.
echo.
pause
goto menu

rem --- called with a page name on the command line ---------------------------
:fromarg
set "page=%~1"
set "page=%page:.html=%"
if /i "%~2"=="plain" set "SUB="
call :copy "%page%" "%~2"
goto done

rem --- the bit that actually copies ------------------------------------------
:copy
set "file=%SUB%%~1.html"
if not exist "%file%" goto missing
clip < "%file%"
cls
echo.
echo    ==========================================================
echo.
echo       %file%
echo       is now on your clipboard.
echo.
echo       Switch to your website builder and press Ctrl+V.
echo.
echo    ==========================================================
echo.
if defined SUB echo    This is the BAKED version - the photos travel inside
if defined SUB echo    the HTML, so there is no images folder to upload.
if not defined SUB echo    This is the PLAIN version - remember to upload the
if not defined SUB echo    images folder alongside it, or the photos will break.
echo.
if /i "%~2"=="quiet" exit /b 0
if /i "%~2"=="plain" exit /b 0
pause
exit /b 0

:missing
echo.
echo    Could not find %file% in this folder.
echo.
if /i "%~2"=="quiet" exit /b 1
pause
exit /b 1

:done
exit /b 0
