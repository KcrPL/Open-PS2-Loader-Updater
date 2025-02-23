:startup_begin
@echo off
setlocal enableextensions
setlocal DisableDelayedExpansion
cd /d "%~dp0"
if exist temp.bat del /q temp.bat
:: ===========================================================================
:: Open PS2 Loader Updater 
set version=1.0.1
:: AUTHORS: KcrPL
:: ***************************************************************************
:: Copyright (c) 2022-2024 KcrPL
:: ===========================================================================
set last_build=2025/02/23
set at=23:56 CET

set mode=124,36
mode %mode%
title Open PS2 Loader Updater v%version%  Created by @KcrPL

set header=Open PS2 Loader Updater - (C) KcrPL v%version% (Updated on %last_build% at %at%)

set /a update_Activate=1
set /a offlinestorage=0
set FilesHostedOn=https://kcrpl.github.io/Patchers_Auto_Update/Open_PS2_Loader_Updater/v1/
set opl_latest_beta=https://github.com/ps2homebrew/Open-PS2-Loader/releases/download/latest/OPNPS2LD.7z
set opl_latest_stable=https://github.com/ps2homebrew/Open-PS2-Loader/releases/latest/download/OPNPS2LD.7z
set opl_stable_api=https://api.github.com/repos/ps2homebrew/Open-PS2-Loader/releases/latest

set MainFolder=%appdata%\OpenPS2LoaderUpdater
set TempStorage=%appdata%\OpenPS2LoaderUpdater\internet\temp
set line=-----------------------------------------------------------------------------------------------------------------------
if not exist "%MainFolder%" md "%MainFolder%"
if not exist "%TempStorage%" md "%TempStorage%"

if not exist "%MainFolder%\ps2_target_ip.txt" >"%MainFolder%\ps2_target_ip.txt" echo NUL
if not exist "%MainFolder%\ps2_target_path.txt" >"%MainFolder%\ps2_target_path.txt" echo mc/0/OPL/

:: Set release branch of OPL. 1 - Daily Builds, 2 - Stable
if not exist "%MainFolder%\opl_update_branch.txt" >"%MainFolder%\opl_update_branch.txt" echo 1
set /p opl_release_branch=<"%MainFolder%\opl_update_branch.txt"

:: Read the last updated date
if not exist "%MainFolder%\last_updated.txt" >"%MainFolder%\last_updated.txt" echo NUL
set /p last_updated=<"%MainFolder%\last_updated.txt"
if "%last_updated%"=="NUL" set last_updated=Never

:: Get the current date
for /f "tokens=1-3 delims= " %%a in ('date /t') do set current_date=%%a

:: Parse the current date (assuming format DD.MM.YYYY)
for /f "tokens=1-3 delims=." %%a in ("%current_date%") do (
    set current_day=%%a
    set current_month=%%b
    set current_year=%%c
)
:: Parse the last updated date (assuming format DD.MM.YYYY)
for /f "tokens=1-3 delims=." %%a in ("%last_updated%") do (
    set last_day=%%a
    set last_month=%%b
    set last_year=%%c
)

set /a days_diff=( ( ( %current_year% - %last_year% ) * 365 ) + ( ( %current_month% - %last_month% ) * 30 ) + ( %current_day% - %last_day% ) )
goto check_version_stable

:begin_main
mode %mode%
set /a customerror=0
cls
echo %header%
echo %line%
echo.
echo Welcome to the Open PS2 Loader Updater.
echo.
if defined stable_opl_version (
	echo :---------------------------------------------------------------:
	echo  The latest stable OPL version: %stable_opl_version% (Released on %stable_opl_date%^)
	echo :---------------------------------------------------------------:
	echo.
)
echo What would you like to do?
echo.
if %opl_release_branch% == 1 (
	echo R. Switch release branch. Current: Daily Builds
	echo.
	echo    /!\ Daily Builds contain the latest features and fixes but may be unstable.
	echo        If you encounter any issues, switch to the stable branch and update.
	echo        The stable branch is updated less frequently but is more stable.
	echo        You may lose your settings when switching branches.
	)
)
if %opl_release_branch% == 2 echo R. Switch release branch. Current: Stable
echo.
if %days_diff% == 0 (
	echo Last updated on: %last_updated% (Today!^)
	) else (
	echo Last updated on: %last_updated% (%days_diff% days ago^)
	)
echo.
echo 1. Update Open PS2 Loader.
echo 2. Settings.
echo.
echo 3. Help [read manual].
echo 4. Open GitHub project page.
echo.
set /p s=Choose: 
if "%s%"=="1" goto startup_script
if "%s%"=="2" goto reconfigure
if "%s%"=="3" goto help
if "%s%"=="r" goto switch_release_branch
if "%s%"=="R" goto switch_release_branch
if "%s%"=="4" start https://github.com/KcrPL/Open-PS2-Loader-Updater
goto begin_main

:switch_release_branch
if %opl_release_branch%==1 (
	>"%MainFolder%\opl_update_branch.txt" echo 2
	set /a opl_release_branch=2
	goto begin_main
	)
if %opl_release_branch%==2 (
	>"%MainFolder%\opl_update_branch.txt" echo 1
	set /a opl_release_branch=1
	goto begin_main
	)

:check_version_stable
cls
echo %header%
echo %line%
echo.
echo Please wait while we're checking the latest stable version of Open PS2 Loader...
echo.

curl -s -H "Accept: application/vnd.github+json" "%opl_stable_api%" > "%TempStorage%\stable_release.json"
for /f "tokens=2 delims=:," %%i in ('findstr /i "tag_name" "%TempStorage%\stable_release.json"') do set stable_opl_version=%%i
	if not defined stable_opl_version goto begin_main
for /f "tokens=2 delims=:," %%i in ('findstr /i "published_at" "%TempStorage%\stable_release.json"') do set stable_opl_date=%%i

set stable_opl_version=%stable_opl_version:~2,-1%
set stable_opl_date=%stable_opl_date:~2,-3%
goto begin_main


:help
cls
echo %header%
echo %line%
echo.
echo The point of this app is to quickly update OPL on your PS2.
echo.
echo Open PS2 Loader's latest version is always available here: 
echo https://github.com/ps2homebrew/Open-PS2-Loader/releases/download/latest/OPNPS2LD.7z
echo.
echo Your computer and PS2 needs to be on the same network so they can communicate with each other.
echo Ideally your PS2 is connected to your router and you're connected to your router using WiFi or Ethernet.
echo.
echo We're gonna use uLaunchELF's built in FTP Server as our FTP Server of choice. You will have to configure it's network.
echo From uLaunchELF select "Configure" -^> Network Settings and configure network.
echo.
echo To start the FTP Server, launch uLaunchELF -^> FileBrowser -^> MISC -^> PS2Net.
echo You will see your PS2's IP Address on top of the screen.
echo.
echo Press any key to continue.
pause>nul
goto begin_main
:reconfigure
set /p ps2_target_ip=<"%MainFolder%\ps2_target_ip.txt"
set /p ps2_target_path=<"%MainFolder%\ps2_target_path.txt"

cls
echo %header%
echo %line% 
echo.
echo Settings.

if "%ps2_target_ip%"=="NUL" (
echo.
echo :-----------------------------------------:
echo : Please configure your PS2's IP Address. :
echo :-----------------------------------------:
)

echo.
echo R. Return to main menu.
echo.
echo 1. PS2 IP Address: %ps2_target_ip%
echo 2. Open PS2 Loader Path: %ps2_target_path%
echo.
set /p s=Choose: 
if "%s%"=="1" goto reconfigure_ps2_ip_address
if "%s%"=="2" goto reconfigure_ps2_path
if "%s%"=="r" goto begin_main
if "%s%"=="R" goto begin_main
goto reconfigure
:reconfigure_ps2_ip_address
cls
echo %header%
echo %line% 
echo.
set /p ps2_target_ip=Enter your PS2 IP Address: 
>"%MainFolder%\ps2_target_ip.txt" echo %ps2_target_ip%
goto reconfigure

:reconfigure_ps2_path
cls
echo %header%
echo %line% 
echo.
echo Keep in mind the format that the path needs to be.
echo.
echo The default is: mc/0/OPL/
echo Current path: %ps2_target_path%
echo.
echo Where:
echo.
echo mc/0 = Memory Card 0 (first slot on the left)
echo mc/1 = Memory Card 1 (second slot)
echo mass/0 = First USB Port
echo mass/1 = Second USB Port
echo.
echo Make sure to put "/" at the end of the path. Otherwise uploading will fail.
echo.
set /p ps2_target_path=Enter your desired Open PS2 Loader Path [Press ENTER to keep the current path]: 
>"%MainFolder%\ps2_target_path.txt" echo %ps2_target_path%
goto reconfigure
:begin_main_download_curl
cls
echo %header%
echo %line%
echo.
echo :--------------------------------:
echo Downloading curl... Please wait.
echo This can take some time...
echo :--------------------------------:
echo.   
echo File 1 [3.5MB] out of 1
echo 0%% [          ]

call powershell -command (new-object System.Net.WebClient).DownloadFile('%FilesHostedOn%/curl.exe', 'curl.exe')
set /a temperrorlev=%errorlevel%
if not %temperrorlev%==0 goto begin_main_download_curl_error

goto startup_script
:begin_main_download_curl_error
cls
echo %header%   
echo %line%                                                             
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo %line%
echo    /---\   ERROR.
echo   /     \  There was an error while downloading curl.
echo  /   ^!   \ 
echo  --------- We will now open a website that will download curl.exe.
echo            Please move curl.exe to the folder where Open PS2 Loader Updater is and restart the program.
echo.
echo       Press any key to open download page in browser and to return to menu.
echo %line%
pause>NUL
start %FilesHostedOn%/curl.exe
goto begin_main



:startup_script
curl
if not %errorlevel%==2 goto begin_main_download_curl

goto check_for_update
:check_for_update
cls
echo %header%  
echo %line%                                                              
echo.                                                                 
echo :-------------------------:
echo : Checking for updates... :          
echo :-------------------------:     

set /a updateavailable=0 

:: Update script.
set updateversion=0.0.0
:: Delete version.txt and whatsnew.txt
if %offlinestorage%==0 if exist "%TempStorage%\version.txt" del "%TempStorage%\version.txt" /q
if %offlinestorage%==0 if exist "%TempStorage%\whatsnew.txt" del "%TempStorage%\whatsnew.txt" /q

if not exist %TempStorage% md %TempStorage%
:: Commands to download files from server.
if %Update_Activate%==1 if %offlinestorage%==0 call curl -f -L -s -S --user-agent "Open PS2 Loader Updater v%version%" --insecure "%FilesHostedOn%/UPDATE/whatsnew.txt" --output "%TempStorage%\whatsnew.txt"
if %Update_Activate%==1 if %offlinestorage%==0 call curl -f -L -s -S --user-agent "Open PS2 Loader Updater v%version%" --insecure "%FilesHostedOn%/UPDATE/version.txt" --output "%TempStorage%\version.txt"

	set /a temperrorlev=%errorlevel%
set /a updateserver=1
	::Bind error codes to errors here

	
:: Copy the content of version.txt to variable.
if exist "%TempStorage%\version.txt" set /p updateversion=<"%TempStorage%\version.txt"
if not exist "%TempStorage%\version.txt" set /a updateavailable=0
if %Update_Activate%==1 if exist "%TempStorage%\version.txt" set /a updateavailable=1
:: If version.txt doesn't match the version variable stored in this batch file, it means that update is available.
if %Update_Activate%==1 if %updateversion%==%version% set /a updateavailable=0 
if %Update_Activate%==1 if %updateavailable%==1 set /a updateserver=2
if %Update_Activate%==1 if %updateavailable%==1 goto update_notice
goto ftp_check_prerequisites

:error_update_not_available
cls
set /a updateserver=0
goto ftp_check_prerequisites
:update_notice
if %updateversion%==0.0.0 goto error_update_not_available
set /a update=1
cls
echo %header%
echo %line%
echo.                                                                       
echo.
echo.
echo.
echo.
echo.
echo.
echo.

echo %line%              
echo    /---\    Software update available.              
echo   /     \   We suggest updating the Open PS2 Loader Updater to the latest version.
echo  /   !   \ 
echo  --------- 
echo             Current version: %version%
echo             New version: %updateversion%
echo                       1. Update                      2. Dismiss               3. What's new in this update?
echo %line%
set /p s=
if %s%==1 goto update_files
if %s%==2 goto ftp_check_prerequisites
if %s%==3 goto whatsnew
goto update_notice
:update_files
cls
echo %header%
echo %line%
echo.                                                                       
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo %line%              
echo    /---\   Updating.
echo   /     \  Please wait...
echo  /   !   \ 
echo  --------- Open PS2 Loader Updater will restart shortly... 
echo.             
echo.
echo %line%    

:: Deleting the temp files if they exist.
curl -f -L -s -S --insecure "https://kcrpl.github.io/Patchers_Auto_Update/Open_PS2_Loader_Updater/v1/UPDATE/update_assistant.bat" --output "update_assistant.bat"
	set temperrorlev=%errorlevel%
	if not %temperrorlev%==0 goto error_updating
	start update_assistant.bat -OpenPS2LoaderUpdater
exit
:error_updating
cls
echo %header%
echo %line%
echo.                                                                       
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.    
echo %line%
echo    /---\   ERROR.
echo   /     \  There was an error while downloading the update assistant.
echo  /   ^!   \ 
echo  --------- Press any key to return to main menu.
echo.  
echo.
echo %line%

pause>NUL
goto begin_main

:whatsnew
cls
echo %header%
echo %line%
if not exist "%TempStorage%\whatsnew.txt" goto whatsnew_notexist            
echo.
echo What's new in update %updateversion%?
echo.
type "%TempStorage%\whatsnew.txt"
pause>NUL
goto update_notice
:whatsnew_notexist
cls
echo %header%
echo %line%              
echo.
echo Error. What's new file is not available.
echo.
echo Press any button to go back.
pause>NUL
goto update_notice

:ftp_check_prerequisites
set /p ps2_target_ip=<"%MainFolder%\ps2_target_ip.txt"
set /p ps2_target_path=<"%MainFolder%\ps2_target_path.txt"

if "%ps2_target_ip%"=="NUL" goto ftp_setup_firsttime
goto ftp_patch

:ftp_setup_firsttime
cls
echo %header%
echo %line% 
echo.
echo Before I can send the files to your PS2, I need to know few things such as your
echo PS2's IP Address and the path where I should save OPL.
echo.
echo Press any key to continue.
pause>nul
goto reconfigure


:ftp_patch
if exist OPNPS2LD.7z del OPNPS2LD.7z
set /a progress=1
set /a progress_check_connection=1
set /a progress_download=0
set /a progress_upload=0

goto ftp_patch_main
:ftp_patch_main
cls
echo %header%
echo %line% 
echo.
echo Please wait while we're updating Open PS2 Loader on your PS2.
echo.
if %progress_check_connection%==0 echo [ ] Connecting to your PS2...
if %progress_check_connection%==1 echo [.] Connecting to your PS2...
if %progress_check_connection%==2 echo [X] Connecting to your PS2... Connected!

if %opl_release_branch% == 1 (
	if %progress_download%==0 echo [ ] Downloading the latest OpenPS2Loader daily build from GitHub.
	if %progress_download%==1 echo [.] Downloading the latest OpenPS2Loader daily build from GitHub.
	if %progress_download%==2 echo [X] Downloading the latest OpenPS2Loader daily build from GitHub.
	)

if %opl_release_branch% == 2 (
	if %progress_download%==0 echo [ ] Downloading the latest OpenPS2Loader stable from GitHub.
	if %progress_download%==1 echo [.] Downloading the latest OpenPS2Loader stable from GitHub.
	if %progress_download%==2 echo [X] Downloading the latest OpenPS2Loader stable from GitHub.
	)

if %progress_upload%==0 echo [ ] Uploading the new build of OpenPS2Loader to your PS2.
if %progress_upload%==1 echo [.] Uploading the new build of OpenPS2Loader to your PS2.
if %progress_upload%==2 echo [X] Uploading the new build of OpenPS2Loader to your PS2.

if %progress%==1 goto ftp_patch_check_conn
if %progress%==2 goto ftp_patch_download_beta
if %progress%==3 goto ftp_patch_upload_new_build

if %progress%==4 goto ftp_patch_finish

:ftp_patch_check_conn
echo.
curl -s -S --ftp-port - --disable-eprt --insecure "ftp:/%ps2_target_ip%">NUL
set /a temperrorlev=%errorlevel%
		if not %temperrorlev%==0 set module=Checking Connection to PS2 (FTP)
		if not %temperrorlev%==0 goto error_patching
set /a progress_check_connection=2
set /a progress_download=1
set /a progress=2

goto ftp_patch_main

:ftp_patch_download_beta
echo.

if not exist "7z.exe" curl "https://kcrpl.github.io/Patchers_Auto_Update/Open_PS2_Loader_Updater/v1/7z.exe" --output "7z.exe"
set /a temperrorlev=%errorlevel%
		if not %temperrorlev%==0 set module=Downloading 7z.exe failed.
		if not %temperrorlev%==0 goto error_patching
echo.

if %opl_release_branch% == 1 curl -L "%opl_latest_beta%" --output "OPNPS2LD.7z"
if %opl_release_branch% == 2 curl -L "%opl_latest_stable%" --output "OPNPS2LD.7z"

set /a temperrorlev=%errorlevel%
		if not %temperrorlev%==0 set module=Downloading the latest OPL build failed
		if not %temperrorlev%==0 goto error_patching
7z x OPNPS2LD.7z -y>NUL
ren "OPNPS2LD\*.ELF" "OPNPS2LD.ELF"
set /a progress_download=2
set /a progress_upload=1

set /a progress=3
goto ftp_patch_main
:ftp_patch_upload_new_build
echo.
curl --ftp-port - --disable-eprt --insecure "ftp:/%ps2_target_ip%/%ps2_target_path%" -T "OPNPS2LD\OPNPS2LD.ELF" --ftp-create-dirs
set /a temperrorlev=%errorlevel%
		if not %temperrorlev%==0 set module=Uploading to PS2 failed.
		if not %temperrorlev%==0 goto error_patching
set /a progress_upload=2
set /a progress=4
goto ftp_patch_main

:ftp_patch_finish
>"%MainFolder%\last_updated.txt" echo %date%
cls
if exist OPNPS2LD rmdir /s /q OPNPS2LD
if exist OPNPS2LD.7z del OPNPS2LD.7z
if exist 7z.exe del 7z.exe
echo %header%
echo %line% 
echo.
echo We are done!
echo.
echo [X] Connecting to your PS2... Connected!
if %opl_release_branch% == 1 echo [X] Downloading the latest OpenPS2Loader daily build from GitHub.
if %opl_release_branch% == 2 echo [X] Downloading the latest OpenPS2Loader stable build from GitHub.
echo [X] Uploading the new build of OpenPS2Loader to your PS2.
echo.
echo The latest version of the Open PS2 Loader has been uploaded to your PS2. 
echo If you're using a shortcut to OPL from the PS2 Main Menu, configure it in settings to run from:
echo.
echo (OPL PS2 PATH): %ps2_target_path%OPNPS2LD.ELF
echo.
if %opl_release_branch% == 1 echo My work here is done! Come back soon! There's a new build of OPL everyday :^)
if %opl_release_branch% == 2 echo My work here is done! Come back soon and consider checking out the latest features and fixes in the daily builds :^)
echo.
echo Press any key to exit.
pause>NUL 
exit
:error_patching
cls
echo %header%
echo %line%
echo.                                                                       
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.          
echo %line%
echo    /---\   ERROR.              
echo   /     \  There was an error while patching.
echo  /   !   \ 
echo  --------- Operation: %module%             
echo            Error code: %temperrorlev%
echo.
if "%module%"=="Checking Connection to PS2 (FTP)" echo Make sure you're using the FTP Server built into uLaunchELF.&echo.
echo       Press any key to return to main menu.
echo %line%
pause>NUL
goto begin_main
