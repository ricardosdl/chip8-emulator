@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
SET me=%~n0
SET parent=%~dp0

SET force_delete_directory=local\man\man3

FOR %%I IN (%force_delete_directory%\*) DO @ECHO %%I
REM FOR %%I IN (%force_delete_directory%\*) DO del "\\?\%I"