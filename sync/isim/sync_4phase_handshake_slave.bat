mkdir sync_4phase_handshake_slave
cd sync_4phase_handshake_slave
fuse sync_4phase_handshake_slave_tb -prj ..\sync_4phase_handshake_slave.prj
x.exe -gui -view ..\sync_4phase_handshake_slave.wcfg -tclbatch ..\run.tcl
