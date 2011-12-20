mkdir async_4phase_handshake_slave
cd async_4phase_handshake_slave
fuse async_4phase_handshake_slave_tb -prj ..\async_4phase_handshake_slave.prj
x.exe -gui -view ..\async_4phase_handshake_slave.wcfg -tclbatch ..\run.tcl
