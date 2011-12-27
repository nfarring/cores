COREGEN_SRC=

ISIM_SRC=async_4phase_handshake_master.isim\
async_4phase_handshake_slave.isim\
async_muller_c_element.isim\
spi_master.isim\
sync_4phase_handshake_master.isim\
sync_4phase_handshake_slave.isim\
sync_signal.isim\
timer.isim

.PHONY:
all: coregen isim

.PHONY:
coregen: $(COREGEN_SRC)

.PHONY:
isim: $(ISIM_SRC)

.PHONY:
clean:
	-rm -rf *.coregen *.isim

%.coregen: %.xco
	mkdir $@
	cd $@ && coregen -b ..\$(basename $@).xco

%.isim:
	mkdir $@
	python hdlbuild.py $@
