:: Start MATLAB with the COMSOL LiveLink (MS Windows)
::
::    Warning: On Windows, COMSOL is typically not added to the system paths.
::             Therefore, absolute path is used for starting COMSOL.
::             For this reason, the path should be adapted for each machine.
::
:: (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

@echo off

echo:
echo ####################################################
echo # START MATLAB WITH COMSOL
echo ####################################################
echo:

"C:\Program Files\COMSOL\COMSOL54\Multiphysics\bin\win64\comsolmphserver.exe" matlab -autosave off
