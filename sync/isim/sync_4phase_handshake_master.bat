mkdir sync_4phase_handshake_master
cd sync_4phase_handshake_master
fuse sync_4phase_handshake_master_tb -prj ..\sync_4phase_handshake_master.prj
x.exe -gui -view ..\sync_4phase_handshake_master.wcfg -tclbatch ..\run.tcl
