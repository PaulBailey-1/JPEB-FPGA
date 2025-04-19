  addi r5 r0 25 # put 25 in r5
  swi  r4 r5 15 # store 15 at address 25
  lw   r3 r0 25 # load address 25 into r3
  sys  EXIT     # should return 15