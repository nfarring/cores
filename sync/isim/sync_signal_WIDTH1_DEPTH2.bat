mkdir sync_signal_WIDTH1_DEPTH2
cd sync_signal_WIDTH1_DEPTH2
fuse sync_signal_WIDTH1_DEPTH2_tb -prj ..\sync_signal_WIDTH1_DEPTH2.prj
x.exe -gui -view ..\sync_signal_WIDTH1_DEPTH2.wcfg -tclbatch ..\run.tcl
