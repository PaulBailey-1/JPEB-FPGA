INIT:
  # color the entire background to green (3)
  movi r3, 0x0303
  movi r5, 0x1000
LBACKGROUND:
  addi r5, r5, -1
  movi r4, 0xE000
  add r4, r4, r5
  sw r3, r4, 0
  cmp r5, r0
  bnz LBACKGROUND

  # the data is stored at DATA
  # at offset 0 is the snake's body's coordinates
  movi r4, DATA
  # the center coordinate is (x,y) = (40, 30)
  movi r3, 0x281e
  sw r3, r4, 0
  addi r3, r3, 1    # lower order bytes is y
  sw r3, r4, 1
  # the length of the snake
  movi r7, 2


# to set the snake to a certian color, call this function with COLOR_STATE set to the desired color
COLOR_SNAKE:
  # the loop
  add r2, r0, r7
LFILL:
  # we assume snake always has some length to body
  addi r2, r2, -1

  movi r4, DATA   # load from snake body
  add r4, r4, r2
  lw r4, r4, 0
  # get the offset of the tile into r6 and address into r4
  add r6, r0, r4
  movi r3, 0xFF
  and r3, r3, r6
  shl r3, r3    # shl 6 times (for 'y')
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shl r3, r3
  shr r6, r6    # shr 9 times (for 'x')
  shr r6, r6
  shr r6, r6
  shr r6, r6
  shr r6, r6
  shr r6, r6
  shr r6, r6
  shr r6, r6
  shr r6, r6
  # r6 will be x
  # if r6 is even, the output will be OR'ed into the lower bits otherwise will OR into the upper bits
  # calculate address
  add r4, r3, r6
  movi r3, 0xE000
  add r4, r3, r4
  # reduce r6 into 0 or 1
  movi r3, 1
  and r6, r6, r3
  # get original value to OR with
  lw r3, r4, 0
  cmp r6, r0
  bnz LENDEVEN
  # even -> lower order bits
  movi r6, 0xFF00
  and r6, r3, r6

  jmp LENDODD
LENDEVEN:
LENDODD:
  
  # the foreground tile
  movi r3, 2
  # draw to screen
  sw r3, r4, 0

  cmp r2, r0 # check not zero
  bnz LFILL


COLOR_STATE:
    .fill 3
DATA:
    .space 4800
APPLE:
    .fill 0x4020