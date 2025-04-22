# V_SRC=${wildcard src/*.v} ${wildcard src/**/*.v}
V_SRC=${wildcard src/*.v} ${wildcard src/cpu/*.v}
ASM_SRCS := $(wildcard tests/asm/*.s)
V_SRCS := $(wildcard src/simple_cpu/*.v)
HEXS     := $(ASM_SRCS:.s=.hex)
SIM_OUTS := $(HEXS:.hex=.sim.out)

all : cpu

cpu : Makefile ${V_SRC}
	@mkdir -p build
	iverilog -DSIMULATION -o ./build/cpu ${V_SRC}

clean:
	-rm build/cpu
	