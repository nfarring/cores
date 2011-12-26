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
