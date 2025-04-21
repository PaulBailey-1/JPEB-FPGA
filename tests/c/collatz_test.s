	movi r3 main
	jalr r0  r3 

# Data Section:

# Code Section:
collatz:
	# Function Prologue
	sw r7  r1  -1
	sw r2  r1  -2
	addi r1  r1  -2
	addi r2  r1  0
	# Function Body
	addi r1  r1  -9
	sw r3  r2  -1
	movi r3 1
	sw r3  r2  -2
	lw r3  r2  -1
	lw r4  r2  -2
	and r3  r3  r4 
	sw r3  r2  -3
	lw r3  r2  -3
	movi r4 0
	cmp r3  r4 
	bz 1
	jmp 3
	movi r3 collatz.else.6
	jalr r0  r3 
	lw r3  r2  -1
	lw r4  r2  -1
	add r3  r3  r4 
	sw r3  r2  -4
	lw r3  r2  -4
	lw r4  r2  -1
	add r3  r3  r4 
	sw r3  r2  -5
	movi r3 1
	sw r3  r2  -6
	lw r3  r2  -5
	lw r4  r2  -6
	add r3  r3  r4 
	sw r3  r2  -7
	lw r3  r2  -7
	# Function Epilogue
	mov r1  r2 
	lw r7  r2  1
	lw r2  r2  0
	addi r1  r1  2
	jalr r0  r7 
	movi r3 collatz.end.9
	jalr r0  r3 
collatz.else.6:
	movi r3 1
	sw r3  r2  -8
	lw r3  r2  -1
	lw r4  r2  -8
	call right_shift
	sw r3  r2  -9
	lw r3  r2  -9
	# Function Epilogue
	mov r1  r2 
	lw r7  r2  1
	lw r2  r2  0
	addi r1  r1  2
	jalr r0  r7 
collatz.end.9:
	movi r3 0
	# Function Epilogue
	mov r1  r2 
	lw r7  r2  1
	lw r2  r2  0
	addi r1  r1  2
	jalr r0  r7 
main:
	movi r1 40959
	movi r2 40959
	addi r1  r1  -8
	movi r3 121
	sw r3  r2  -1
	lw r3  r2  -1
	sw r3  r2  -2
	lw r3  r2  -2
	sw r3  r2  -3
main.while.0.continue:
	movi r3 1
	sw r3  r2  -4
	movi r3 1
	sw r3  r2  -5
	lw r3  r2  -2
	lw r4  r2  -5
	cmp r3  r4 
	bnz 1
	jmp 3
	movi r3 main.end.7
	jalr r0  r3 
	movi r3 0
	sw r3  r2  -4
main.end.7:
	lw r3  r2  -4
	movi r4 0
	cmp r3  r4 
	bz 1
	jmp 3
	movi r3 main.while.0.break
	jalr r0  r3 
	lw r3  r2  -2
	call collatz
	sw r3  r2  -6
	lw r3  r2  -6
	sw r3  r2  -2
	movi r3 1
	sw r3  r2  -7
	lw r3  r2  -2
	lw r4  r2  -3
	cmp r3  r4 
	ba 1
	jmp 3
	movi r3 main.end.3
	jalr r0  r3 
	movi r3 0
	sw r3  r2  -7
main.end.3:
	lw r3  r2  -7
	movi r4 0
	cmp r3  r4 
	bz 1
	jmp 3
	movi r3 main.end.4
	jalr r0  r3 
	lw r3  r2  -2
	sw r3  r2  -3
main.end.4:
	movi r3 main.while.0.continue
	jalr r0  r3 
main.while.0.break:
	lw r3  r2  -3
	sw r3  r2  -8
	lw r3  r2  -8
	# Function Epilogue
	sys EXIT
	movi r3 0
	# Function Epilogue
	sys EXIT
