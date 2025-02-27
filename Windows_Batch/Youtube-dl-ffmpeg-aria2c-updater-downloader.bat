@echo off
setlocal enabledelayedexpansion

echo '-----------------------------------------------------------------------------------------'
echo 'rmccurdy.com Updated using yt-dlp'
echo 'Proxy support for localhost:8080'
echo '-----------------------------------------------------------------------------------------'

REM 04/26/2021:  * added fallback to legacy if no file is output in 3 seconds .. ( can't really catch errors on start command without wonky scripting or writing to error files) Reference: https://stackoverflow.com/questions/29740883/how-to-redirect-error-stream-to-variable/38928461#38928461

CALL :INIT

CALL :OPENLIST

IF "%UPDATE%" == "YES" (

CALL :DLWGET
CALL :CATCH

CALL :DLARIA
CALL :CATCH

CALL :DLFFMPEG
CALL :CATCH

CALL :DLYTDL
CALL :CATCH

)
 
CALL :DLmsvcr100
CALL :CATCH


CALL :YTUPDATE
CALL :CATCH


CALL :RIP
CALL :CATCH

CALL :THEEND

:CATCH
IF %ERRORLEVEL% NEQ 0 (
echo %date% %time% ERROR: Something went wrong
pause
)
EXIT /B %ERRORLEVEL%

:INIT
cd "%~dp0"

set /a WAITTIME = 20

taskkill /F /IM "yt-dlp.exe" 2> %temp%/null
CHOICE /C YN /N /T 5 /D Y /M "Update ALL binaries Y/N?"
IF ERRORLEVEL 1 SET UPDATE=YES
IF ERRORLEVEL 2 SET UPDATE=NO
SET ERRORLEVEL=0

REM Remove .part files 
if  exist ".\downloads" (
del .\downloads\*.part
del .\downloads\*.aria2
)

if exist ".\yt-dlp.exe.new" (
del "yt-dlp.exe.new" > %temp%\null
)

if exist ".\aria2" (
rd /q/s ".\aria2" > %temp%\null
)

if exist ".\ffmpeg" (
rd /q/s ".\ffmpeg"  > %temp%\null
)
EXIT /B %ERRORLEVEL%

:DLmsvcr100
if not exist "C:\Windows\SysWOW64\msvcr100.dll" (
	if not exist "C:\Windows\System32\msvcr100.dll" (
		echo %date% %time% INFO: Downloading Missing msvcr100.dll from "https://download.microsoft.com/download/C/6/D/C6D0FD4E-9E53-4897-9B91-836EBA2AACD3/vcredist_x86.exe"
		powershell "(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/C/6/D/C6D0FD4E-9E53-4897-9B91-836EBA2AACD3/vcredist_x86.exe', '.\vcredist_x86.exe')" > %temp%/null
		.\vcredist_x86.exe  
		)
	)
EXIT /B %ERRORLEVEL%


:OPENLIST
cls
echo %date% %time% INFO: Opening list.txt save/close notepad with the list of URLs you want downloaded! Use Chrome plugin "Bulk Media Downloader" to get video URLS if needed
CHOICE /T 1 /C y /CS /D y > %temp%/null
notepad list.txt
EXIT /B %ERRORLEVEL%

:DLWGET
echo %date% %time% INFO: Downloading wget via Powershell https://eternallybored.org/misc/wget/1.20.3/64/wget.exe (Warning: May NOT be latest binary !)
powershell "(New-Object Net.WebClient).DownloadFile('https://eternallybored.org/misc/wget/1.20.3/64/wget.exe', '.\wget.exe')" > %temp%/null
EXIT /B %ERRORLEVEL%
 
:DLARIA
echo %date% %time% INFO: Downloading latest aria2
wget -q -U "rmccurdy.com" -q -P aria2  -e robots=off  -nd -r  "https://github.com/aria2/aria2/releases/latest" --max-redirect 1 -l 1 -A "latest,aria*win*64*.zip" -R '*.gz,release*.*' --regex-type pcre --accept-regex "aria2-.*-win-64bit-build1.zip"
move .\aria2\*win*64*.zip .\aria2\aria2.zip > %temp%/null
powershell "Expand-Archive .\aria2\aria2.zip -DestinationPath .\aria2\ "  > %temp%/null
FOR /F "tokens=* delims=" %%A in ('dir/s/b .\aria2\aria2c.exe') do (move  "%%A" .\ ) > %temp%/null
rd /q/s .\aria2
EXIT /B %ERRORLEVEL%

:DLFFMPEG
echo %date% %time% INFO: Downloading latest ffmpeg
wget -q -U "rmccurdy.com" -q -P ffmpeg  -e robots=off  -nd -r  "https://github.com/BtbN/FFmpeg-Builds/releases/latest" --max-redirect 1 -l 1 -R '*shared*,*lgpl*,autobuild-*.*' --regex-type pcre --accept-regex "latest.*"  --regex-type pcre --accept-regex "autobuild.*" --regex-type pcre --accept-regex "ffmpeg-n.*-win64-gpl-[0-9].*.zip"
CHOICE /T 1 /C y /CS /D y > %temp%/null
powershell "Expand-Archive .\ffmpeg\*.zip  -DestinationPath .\ffmpeg\ "
FOR /F "tokens=* delims=" %%A in ('dir/s/b .\ffmpeg\ffmpeg.exe') do (move  "%%A" .\ ) > %temp%/null
rd /q/s .\ffmpeg
EXIT /B %ERRORLEVEL%

:DLYTDL
echo %date% %time% INFO: Downloading latest yt-dlp.exe
# youtube DL not working anymore wget -e robots=off  -nd -q -U "rmccurdy.com" -q "http://yt-dl.org/downloads/latest/youtube-dl.exe" -O youtube-dl.exe
wget  -U "rmccurdy.com"   -e robots=off  -nd -r  "https://github.com/yt-dlp/yt-dlp/releases/latest" --max-redirect 1 -l 1 -A "latest,yt-dlp.exe" --regex-type pcre --accept-regex "yt-dlp.exe"
CHOICE /T 1 /C y /CS /D y > %temp%/null
EXIT /B %ERRORLEVEL%

:YTUPDATE
(
echo %date% %time% INFO: Updateing yt-dlp.exe
yt-dlp.exe -U

	:LOOPSAUSE
	if exist "yt-dlp.exe.new" (
	echo %date% %time% INFO: Sleeping for update process
	CHOICE /T 1 /C y /CS /D y > %temp%/null
	SET ERRORLEVEL=0
	CALL :LOOPSAUSE
	)
)
EXIT /B %ERRORLEVEL%

:RIP
(
	if not exist ".\downloads\" (
	mkdir .\downloads\
	)

	rem SUBS:  youtube-dl --embed-thumbnail --download-archive ytdl-archive.txt --all-subs --embed-subs --merge-output-format mkv --ffmpeg-location .\ -o ".\downloads\%%(uploader)s - %%(title)s - %%(id)s.%%(ext)s" -i -a list.txt  --external-downloader aria2c --external-downloader-args "-x 4 -s 16 -k 1M"   
	REM LOW QUALITY: youtube-dl -f "bestvideo[height<=360]+worstaudio/worst[height<=360]"  --embed-thumbnail --download-archive ytdl-archive.txt --all-subs --embed-subs --merge-output-format mkv --ffmpeg-location .\ -o ".\downloads\%%(uploader)s - %%(title)s - %%(id)s.%%(ext)s" -i -a list.txt  --external-downloader aria2c --external-downloader-args "-x 4 -s 16 -k 1M"   
	REM LINUX ... youtube-dl --download-archive ytdl-archive.txt --merge-output-format mkv --ffmpeg-location /usr/bin/ -o "%(uploader)s - %(title)s - %(id)s.%(ext)s"  -i -a list.txt  --external-downloader aria2c --external-downloader-args "-x 4 -s 16 -k 1M
	REM try with proxy too	

	for /F "tokens=*" %%A IN (list.txt) DO (
		set /a UUID = !RANDOM!

		echo %date% %time% INFO: "%%A" Downloading with aria2c 	
		start "aria2c !UUID!"	 cmd /c yt-dlp.exe -w --no-continue  --merge-output-format mkv --ffmpeg-location .\ -o ".\downloads\%%(uploader)s - %%(title)s - %%(id)s_!UUID!.%%(ext)s" -i   --external-downloader aria2c --external-downloader-args " -x 16 -s 16 -k 1M" "%%A"  ^& pause
		echo %date% %time% INFO: "%%A" Press Y to skip %WAITTIME% second wait
		CHOICE /T %WAITTIME% /C y /CS /D y > %temp%/null

			if not exist ".\downloads\*!UUID!*" (
					echo %date% %time% ERROR: "%%A" No part files found trying legacy mode
					start "LEGACY !UUID!"	 cmd /c yt-dlp.exe -w --no-continue --merge-output-format mkv --ffmpeg-location .\ -o ".\downloads\%%(uploader)s - %%(title)s - %%(id)s_!UUID!.%%(ext)s"    "%%A"    ^& pause
					)
		)
)
EXIT /B %ERRORLEVEL%

:THEEND
echo %date% %time% INFO: All done!
pause
exit
