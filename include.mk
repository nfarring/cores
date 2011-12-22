# This pattern rule creates a subdirectory with a .isim extension that includes
# all of the files necessary for running a Xilinx ISIM simulation. The unit-
# under-test source file is in the main directory, the testbench source file is
# in the tb/ subdirectory, and the ISIM waveform configuration file is in the
# isim/ subdirectory.
%.isim: %.v tb/%_tb.v
	mkdir $@
	echo verilog work ../$(basename $@).v >$@\isim.prj
	echo verilog work ../tb/$(basename $@)_tb.v >>$@\isim.prj
	echo run all >$@\run.tcl
	cd $@ && fuse $(basename $@)_tb -prj isim.prj && x.exe -gui -view ..\isim\$@.wcfg -tclbatch run.tcl
