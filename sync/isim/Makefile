TARGETS=sync_4phase_handshake_master sync_4phase_handshake_slave sync_signal

all: $(TARGETS)

sync_4phase_handshake_master:
	mkdir $@
	cd $@ && fuse $@_tb -prj ..\$@.prj && x.exe -gui -view ..\$@.wcfg -tclbatch ..\run.tcl

sync_4phase_handshake_slave:
	mkdir $@
	cd $@ && fuse $@_tb -prj ..\$@.prj && x.exe -gui -view ..\$@.wcfg -tclbatch ..\run.tcl

sync_signal:
	mkdir $@
	cd $@ && fuse $@_tb -prj ..\$@.prj && x.exe -gui -view ..\$@.wcfg -tclbatch ..\run.tcl

.PHONY: clean
clean:
	-rm -rf $(TARGETS)
