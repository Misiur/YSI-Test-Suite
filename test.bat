@echo off

set MODE=YSI_TEST
set TARGET=
set COMPILER=

:get_args
	if "%~1"=="" goto :args_got
	if /I "%~1"=="-m" set MODE=%~2& shift
	if /I "%~1"=="--mode" set MODE=%~2& shift
	if /I "%~1"=="-f" set TARGET=%~2& shift
	if /I "%~1"=="--flags" set TARGET=%~2& shift
	if /I "%~1"=="-h" goto :show_help
	if /I "%~1"=="--help" goto :show_help
	shift
	goto :get_args

:show_help

echo.
echo Usage: TEST_ADD [flags]
echo.
echo Optional flags:
echo     --mode=mode_name : The name of the mode to compile.  Defaults to YSI_TEST.
echo     -m               : Synonym for "--mode".
echo     --help           : Show this help.
echo     -h               : Synonym for "--help".
echo     --flags=flags    : The flags to use for this build.
echo     -f               : Synonym for "--flags"
echo.
goto :eof

:args_got

mkdir .\logs 2> nul > nul

rem Move the original somewhere safe
move /Y server.cfg server_real.cfg 2> nul > nul
move /Y server_log.txt server_real.txt 2> nul > nul

call :main

rem Get the original settings back
move /Y server_real.cfg server.cfg 2> nul > nul
move /Y server_real.txt server_log.txt 2> nul > nul

goto :eof

:main
	rem Old compiler
	echo.
	echo ********************
	echo ********************
	echo ********************
	echo ***              ***
	echo *** OLD COMPILER ***
	echo ***              ***
	echo ********************
	echo ********************
	echo ********************
	echo.
	call :switch_old
	call :do_builds
	
	rem New compiler
	echo ********************
	echo ********************
	echo ********************
	echo ***              ***
	echo *** NEW COMPILER ***
	echo ***              ***
	echo ********************
	echo ********************
	echo ********************
	echo.
	call :switch_new
	call :do_builds
	
	goto :eof

:do_builds
	if "%TARGET%"=="" (
		call :all_builds
	) else (
		call :spawn "_%COMPILER%" "%TARGET%"
		call :wait "_%COMPILER%"
	)
	goto :eof

:all_builds
	for /L %%g in (0, 1, 2) do (
		for /L %%m in (0, 1, 2) do (
			rem Spawn the processes.
			for /L %%o in (0, 1, 1) do (
				for /L %%d in (0, 1, 2) do (
					call :spawn "_%%g%%m%%o%%d_%COMPILER%" "GTYPE=%%g MTYPE=%%m -O%%o -d%%d"
				)
			)
			rem Wait for all others to complete.
			for /L %%o in (0, 1, 1) do (
				for /L %%d in (0, 1, 2) do (
					call :wait "_%%g%%m%%o%%d_%COMPILER%" "GTYPE=%%g MTYPE=%%m -O%%o -d%%d"
				)
			)
		)
	)
	rem Print the results.
	for /L %%g in (0, 1, 2) do (
		for /L %%m in (0, 1, 2) do (
			for /L %%o in (0, 1, 1) do (
				for /L %%d in (0, 1, 2) do (
					call :print "_%%g%%m%%o%%d_%COMPILER%" "GTYPE=%%g MTYPE=%%m -O%%o -d%%d"
				)
			)
		)
	)
	goto :eof

:spawn
	echo.
	echo *** Running: %MODE%%~1.amx %~2
	start cmd /c SPAWN_TEST.bat %MODE% %1 %2
	goto :eof

:wait
	:wait_loop
		rem Poor man's sleep 1.
		call :sleep_1s
		if not exist logs\%MODE%%~1.txt (
			goto wait_loop
		)
	goto :eof

:print
	echo.
	echo *** Checking: %~1
	findstr /L "Fails: " logs\%MODE%%~1.txt
	goto :eof

:switch_new
	cd pawno/
	call cs.bat "new"
	cd ..
	set COMPILER=new
	goto :eof

:switch_old
	cd pawno/
	call cs.bat "old"
	cd ..
	set COMPILER=old
	goto :eof

:sleep_1s
	ping -n 2 -i 1 www.google.com > nul
	goto :eof

