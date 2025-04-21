ASM_SRCS := $(wildcard tests/asm/*.s)
V_SRCS := $(wildcard src/simple_cpu/*.v)
HEXS     := $(ASM_SRCS:.s=.hex)
SIM_OUTS := $(HEXS:.hex=.sim.out)

test: $(SIM_OUTS)
	rm tests/asm/*.bin

# Compile assembly to binary
tests/asm/%.out: tests/asm/%.s
	python3 Assembler.py $< arithmetic.s
	{ echo "@0"; cat $@; } > $@.tmp && mv $@.tmp mem.hex
	rm -f $@.tmp

# Run simulation
tests/asm/%.sim.out: tests/asm/%.out
	iverilog -o cpu $(V_SRCS)
	./cpu $< > $@

make clean:
	rm -f tests/asm/*.sim.out tests/asm/*.bin