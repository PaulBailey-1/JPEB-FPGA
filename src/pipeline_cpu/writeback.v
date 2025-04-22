

module writeback(input clk, input bubble_in, 
    input [15:0]instr_in, input [15:0]alu_result, input [15:0]mem_result,
    
    output [15:0]result_out,
    output we, output halt
  );


  wire [3:0]opcode_h;
  wire [3:0]opcode_l;

  assign opcode_h = instr_in[15:12];
  assign opcode_l = instr_in[7:4];

  assign halt =
    (opcode_h == 4'b0000) ? 0 : 
    (opcode_h == 4'b1000) ? 0 : 
    (opcode_h == 4'b1001) ? 0 : 
    (opcode_h == 4'b1110) ? (
      (opcode_l == 4'b0000) ? 0 :
      (opcode_l == 4'b0001) ? 0 :
      (opcode_l == 4'b0010) ? 0 :
      (opcode_l == 4'b0011) ? 0 :
      !bubble_in
      ) : 
    (opcode_h == 4'b1111) ? (
      (opcode_l == 4'b0000) ? 0 :
      (opcode_l == 4'b0001) ? 0 :
      (opcode_l == 4'b0010) ? 0 :
      (opcode_l == 4'b0011) ? 0 :
      !bubble_in
      ) :
  !bubble_in;

  wire c;
  assign c = !bubble_in && !halt &&
    (instr_in[15:12] == 4'b0000 || 
     instr_in[15:12] == 4'b1000 ||
     instr_in[15:12] == 4'b1001 ||
     instr_in[15:12] == 4'b1111 && instr_in[7:4] == 4'b0000);
  assign we = c && instr_in[3:0] != 4'b0000;

  assign result_out = (opcode_h == 4'hf && opcode_l == 4'h0) ? mem_result : alu_result;

  always @(posedge clk) begin
    if (c && instr_in[3:0] == 4'b0000) begin
      $write("%c", result_out[7:0]);
    end
  end

endmodule