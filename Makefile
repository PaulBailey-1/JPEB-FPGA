# V_SRCS=${wildcard src/*.v} ${wildcard src/**/*.v}
V_SRCS=${wildcard src/*.v} ${wildcard src/pipeline_cpu/*.v}
ASM_SRCS := $(wildcard tests/asm/*.s)
HEXS     := $(ASM_SRCS:.s=.hex)
SIM_OUTS := $(HEXS:.hex=.sim.out)

all : cpu

cpu : Makefile ${V_SRCS}
	@mkdir -p build
	iverilog -DSIMULATION -o ./build/cpu ${V_SRCS}

clean:
	-rm build/cpu
	