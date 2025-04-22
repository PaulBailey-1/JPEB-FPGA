
module instr_writes_reg(input [15:0]instr, input bubble, output w);
  assign w = 
    ((instr[3:0] != 0) && !bubble &&
    ((op == 3'b000) || (op == 3'b001) || (op == 3'b011) ||
                  (op == 3'b101) || (op == 3'b111)));
endmodule