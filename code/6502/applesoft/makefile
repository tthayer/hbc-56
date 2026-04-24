# Troy's HBC-56 - Applesoft BASIC makefile
#
# Copyright (c) 2026
# Licensed under MIT
#

ROOT_PATH=../

default: applesoft

DISABLE_KERNEL_MODULES = LCD

include $(ROOT_PATH)makefile

%: %.o
	$(HBC56EMU) --rom $<

clean:
	$(RM) -f *.o *.lmap *.rpt *.conf
