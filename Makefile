TARGETS=async_4phase_handshake_master\
async_4phase_handshake_slave\
async_muller_c_element\
spi_master\
sync_4phase_handshake_master\
sync_4phase_handshake_slave\
sync_signal\
timer

.PHONY:
all: $(TARGETS)

.PHONY:
clean:
	-rm -rf $(TARGETS)

# Specify targets with extra dependencies.
async_4phase_handshake_slave: async_muller_c_element.v

# Delegate all work to the Python build script.
# Pass the target and dependencies as arguments.
%:
	python build.py $@ $^









#	echo run all >$@\run.tcl
#	cd $@ && fuse $(basename $@)_tb -prj isim.prj && x.exe -gui -view ..\$@.wcfg -tclbatch run.tcl


# This pattern rule creates a subdirectory with a .isim extension that includes
# all of the files necessary for running a Xilinx ISIM simulation. The unit-
# under-test source file is in the main directory, the testbench source file is
# in the tb/ subdirectory, and the ISIM waveform configuration file is in the
# isim/ subdirectory.
#%.isim: ../%.v ../tb/%_tb.v
#	mkdir $@
#	echo run all >$@\run.tcl
#	cd $@ && fuse $(basename $@)_tb -prj ..\$@.prj && x.exe -gui -view ..\$@.wcfg -tclbatch run.tcl
#%.isim: %.sdb %_tb.sdb
#	mkdir $@
#	echo run all >$@\run.tcl
#	cd $@ && x.exe -gui -view ..\$@.wcfg -tclbatch run.tcl


