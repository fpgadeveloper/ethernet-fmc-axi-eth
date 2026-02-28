@ECHO OFF
SET vitis=C:\AMDDesignTools\2025.2\Vitis\bin\vitis.bat
if exist %vitis% (
  %vitis% -source py\build-vitis.py py\args.json ..\docs\source\data.json
) else (
  ECHO.
  ECHO ###############################
  ECHO ### Failed to locate Vitis  ###
  ECHO ###############################
  ECHO.
  ECHO This batch file "%~n0.bat" did not find Vitis installed in:
  ECHO.
  ECHO     %vitis%
  ECHO.
  ECHO Fix the problem by doing one of the following:
  ECHO.
  ECHO  1. If you do not have this version of Vitis installed,
  ECHO     please install it or download the project sources from
  ECHO     a commit of the Git repository that was intended for
  ECHO     your version of Vitis.
  ECHO.
  ECHO  2. If Vitis is installed in a different location on your
  ECHO     PC, please modify the first line of this batch file
  ECHO     to specify the correct location.
  ECHO.
  pause
)
