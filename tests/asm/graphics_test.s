  movi r3, 0xE000
  movi r4, 0x0001 
  movi r5, 0x0100 
  movi r6, 0x0101 
  sw r6, r3, 0
  sw r6, r3, 1
  movi r3, 0xE028 # 0xE000 + 40 (0x28)
  sw r4, r3, 0
  sw r5, r3, 1
  movi r3, 0xE050 # 0xE000 + 80 (0x50)
  sw r4, r3, 0
  sw r5, r3, 1
  movi r3, 0xE078 # 0xE000 + 120 (0x78)
  sw r6, r3, 0
  sw r6, r3, 1
  movi r7, 50000
STALL_BEGIN:
  addi r7, r7, -1
  bnz STALL_BEGIN