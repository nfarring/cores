mkdir sync_signal
cd sync_signal
fuse sync_signal_tb -prj ..\sync_signal.prj
x.exe -gui -view ..\sync_signal.wcfg -tclbatch ..\run.tcl
