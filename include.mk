# This pattern rule creates a subdirectory with a .isim extension that includes
# all of the files necessary for running a Xilinx ISIM simulation. The unit-
# under-test source file is in the main directory, the testbench source file is
# in the tb/ subdirectory, and the ISIM waveform configuration file is in the
# isim/ subdirectory.
%.isim: ../%.v ../tb/%_tb.v
	mkdir $@
	echo run all >$@\run.tcl
	cd $@ && fuse $(basename $@)_tb -prj ..\$@.prj && x.exe -gui -view ..\$@.wcfg -tclbatch run.tcl
