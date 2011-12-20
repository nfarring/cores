mkdir spi_master
cd spi_master
fuse spi_master_tb -prj ..\spi_master.prj
x.exe -gui -view ..\spi_master.wcfg -tclbatch ..\run.tcl
