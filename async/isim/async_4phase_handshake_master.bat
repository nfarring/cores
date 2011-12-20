mkdir async_4phase_handshake_master
cd async_4phase_handshake_master
fuse async_4phase_handshake_master_tb -prj ..\async_4phase_handshake_master.prj
x.exe -gui -view ..\async_4phase_handshake_master.wcfg -tclbatch ..\run.tcl
