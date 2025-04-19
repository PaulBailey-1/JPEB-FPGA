  movi r3, 0xE000
  swi r6, r3, 0x0101
  addi r3, r3, 1
  swi r6, r3, 0x0101
  movi r3, 0xE040 # 0xE000 + 128 (0x28)
  swi r6, r3, 0x0001
  addi r3, r3, 1
  swi r6, r3, 0x0100
  movi r3, 0xE080 # 0xE000 + 256 (0x50)
  swi r6, r3, 0x0001
  addi r3, r3, 1
  swi r6, r3, 0x0100
  movi r3, 0xE0C0 # 0xE000 + 384 (0x78)
  swi r6, r3, 0x0101
  addi r3, r3, 1
  swi r6, r3, 0x0101

  movi r6, 0xFFE0 # the 16 sprite registers
  # move the first sprite to position 10, 10
  movi r1, 10
  sw r1, r6, 0
  sw r1, r6, 1

  movi r7, 0xFFFD # shift and read registers
  movi r2, 119 # the letter 'w'
  movi r3, 97 # the letter 'a'
  movi r4, 115 # the letter 's'
  movi r5, 100 # the letter 'd'
STALL_BEGIN:
  lw r1, r7, 2 # get a key press
  cmp r1, r2 # 'w'
  bne NOTW
  lw r1, r7, 0 # get current vertical scroll
  addi r1, r1, 3 # scroll up
  sw r1, r7, 0
  jmp STALL_BEGIN
NOTW:
  cmp r1, r3 # 'a'
  bne NOTA
  lw r1, r7, 1 # get current horizontal scroll
  addi r1, r1, -3 # scroll left
  sw r1, r7, 1
  jmp STALL_BEGIN
NOTA:
  cmp r1, r4 # 's'
  bne NOTS
  lw r1, r7, 0 # get current vertical scroll
  addi r1, r1, -3 # scroll down
  sw r1, r7, 0
  jmp STALL_BEGIN
NOTS:
  cmp r1, r5 # 'd'
  bne NOTD
  lw r1, r7, 1 # get current horizontal scroll
  addi r1, r1, 3 # scroll right
  sw r1, r7, 1
  jmp STALL_BEGIN
NOTD:
  jmp STALL_BEGIN