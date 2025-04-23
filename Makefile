# V_SRC=${wildcard src/*.v} ${wildcard src/**/*.v}
V_SRC=${wildcard src/*.v} ${wildcard src/pipeline_cpu/*.v}
ASM_SRCS := $(wildcard tests/asm/*.s)
V_SRCS := $(wildcard src/pipeline_cpu/*.v)
HEXS     := $(ASM_SRCS:.s=.hex)
SIM_OUTS := $(HEXS:.hex=.sim.out)

all : cpu

cpu : Makefile ${V_SRC}
	@mkdir -p build
	iverilog -DSIMULATION -o ./build/cpu ${V_SRC}

cpu_1 : Makefile ${V_SRC}
	@mkdir -p build
	verilator --cc --exe --build --trace --top-module jpeb sim_main.cpp ${V_SRC}

clean:
	-rm build/cpu
	