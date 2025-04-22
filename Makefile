V_FILES=${wildcard src/**/*.v}
ASM_SRCS := $(wildcard tests/asm/*.s)
V_SRCS := $(wildcard src/simple_cpu/*.v)
HEXS     := $(ASM_SRCS:.s=.hex)
SIM_OUTS := $(HEXS:.hex=.sim.out)

all : cpu

cpu : Makefile ${V_FILES}
	@mkdir -p build
	iverilog -DSIMULATION -o ./build/cpu ${V_FILES}
	