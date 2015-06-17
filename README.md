YSI Test Suite
==============

From Y_Less's (Alex Cole) archives.

Setup guide
===========

1. Download latest [sa-mp server](www.sa-mp.com/download.php)
2. Put pawn compiler files (`pawncc.exe`, `pawncc.dll`, and `libpawncc.dll`) and `includes` folder in `pawno` folder.
3. Rename `pawncc.exe` to `oldpawncc.exe`, `pawncc.dll` to `oldpawncc.dll` and `libpawncc.dll` to `oldlibpawncc.dll`.
4. Place `samp-server.exe` in main test suite folder
5. Download latest [Zeex's pawncc](https://github.com/Zeex/pawn/releases) (or use appveyor artifacts for bleeding edge)
6. Place those files into pawno folder.
7. Download [YSI 4](https://github.com/Misiur/YSI/tree/YSI.tl), [YSI-Includes](https://github.com/Misiur/YSI-Includes), [fixes.inc](https://github.com/ikkentim/sa-mp-fixes), [Whirlpool](http://forum.sa-mp.com/showthread.php?t=570945), and [sscanf2](http://forum.sa-mp.com/showthread.php?t=570927).
8. Except for `fixes.inc` place them as you usually would (*do not forget about scriptfiles from YSI, as test critical files are there*)
9. Put `fixes.inc` in `pawno/fixes`

About various files
===================

YSI_TEST.pwn
============

It includes almost all the libraries in various configurations, and enables all tests.  It does include SendRconCommand("exit"); in it, so won't run player tests.

cs.bat
======

"Compiler Switch".  It automatically selects either the default or updated compiler if they are both available.  To use it, install pawno, prefix the existing compiler file names with "old", then download Zeex's compiler over the top (which will be prefixed with "new" when swapping).

SPAWN_TEST.bat
==============

It compiles one version of "YSI_TEST.amx" and starts a server with that version running.

test.bat
========

That is the central control script. It runs dozens of tests (in multiple processes - 6 at once because that matched the number of cores my PC has).  The tests work by recompiling "YSI_TEST.pwn" with different compiler flags (-d, -O etc) and some defines (YSI_NO_MASTER, etc) on both compilers (default and Zeex's). I know that's a lot of files, but if you set them up right, running the tests is as simple as typing "test" and waiting.

Known issues
============
- Currently script spawns 6 processes at once. I don't know what will happen on less cores, but probably standard bottleneck.
- If any of compiler processes crashes, the script will not run any further (it checks if log file was created, otherwise it waits indefinitely)