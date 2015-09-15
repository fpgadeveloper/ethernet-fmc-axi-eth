SET vivado=C:\Xilinx\Vivado\2015.2\bin\vivado.bat

call :build build-ac701
call :build build-kc705-hpc
call :build build-kc705-lpc
call :build build-kc705-lpc-hpc
call :build build-vc707-hpc1
call :build build-vc707-hpc2
call :build build-vc707-hpc2-hpc1
call :build build-vc709
call :build build-zc702-lpc1
call :build build-zc702-lpc2
call :build build-zc702-lpc2-lpc1
call :build build-zc706-lpc

goto:end

:build
start /wait cmd /c "%vivado% -mode batch -log %1.log -source %1.tcl -tclargs bitstream"
exit /b 0

:end
