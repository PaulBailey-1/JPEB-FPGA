## Memory Map (tentative)

0x0000 - 0x9FFF:  
Code, heap, stack  
Code will start at 0x0000, stack at 0x9FFF  
heap is everything in between

0xA000 - 0xBFFF:  
Sprite data. Each sprite is 32x32 pixels, and we reserve space for 8

0xC000 - 0xDFFF:  
Tilemap. Each tile is 8x8 pixels, and we reserve space for 128

0xE000 - 0xEFFF:
Framebuffer. Each entry contains two tiles. The plan is to use 640x480 resolution, so we need 4800 tiles = 2400 entries.

0xF000 - 0xFFFF:  
Other I/O. ps/2 keyboard, vga hscroll and vscroll register are all that is planned for now.  
ps/2 at 0xF000

0xFFFC
scale register (all screen items are displayed at 2\*\*n)

0xFFFD
horizontal scroll register (in pixels)

0xFFFE
vertical scroll register (in pixels)

0xFFFF
input stream (0 if nothing, otherwise ASCII)
