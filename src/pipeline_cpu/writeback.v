

module writeback(input clk, input bubble_in, 
    input [2:0]tgt_in, input [2:0]opcode_in, input [15:0]alu_result, input [15:0]mem_result,
    output [15:0]result_out,
    output we
  );


  assign we = (tgt_in != 0) && (opcode_in != 3'b100 && opcode_in != 3'b110) && !bubble_in;
  assign result_out = (opcode_in == 3'b101) ? mem_result : alu_result;

endmodule