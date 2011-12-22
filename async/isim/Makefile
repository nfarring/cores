include ../../include/include.mk

TARGETS=async_4phase_handshake_master.isim async_4phase_handshake_slave.isim async_muller_c_element.isim

all: $(TARGETS)

async_4phase_handshake_slave.isim: ../async_4phase_handshake_slave.v ../tb/async_4phase_handshake_slave_tb.v
	mkdir $@
	echo verilog work ../../$(basename $@).v -i ../../../include >$@\isim.prj
	echo verilog work ../../async_muller_c_element.v -i ../../../include >>$@\isim.prj
	echo verilog work ../../tb/$(basename $@)_tb.v -i ../../../include >>$@\isim.prj
	echo run all >$@\run.tcl
	cd $@ && fuse $(basename $@)_tb -prj isim.prj && x.exe -gui -view ..\$@.wcfg -tclbatch run.tcl

.PHONY: clean
clean:
	-rm -rf $(TARGETS)
