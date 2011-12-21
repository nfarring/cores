mkdir timer
cd timer
fuse timer_tb -prj ..\timer.prj
x.exe -gui -view ..\timer.wcfg -tclbatch ..\run.tcl
