
module memory(input clk, 
    input bubble_in, input halt_in_wb,
    input [15:0]instr_in, input [15:0]result_in,
    
    output reg [15:0]instr_out, output reg [15:0]result_out,
    output we, output reg bubble_out, output halt_in_mem
  );

  assign we = instr_in[15:12] == 4'hf && instr_in[7:4] == 4'h1 && !bubble_in && !halt_in_wb;

  initial begin
    bubble_out <= 1;
  end

  assign opcode_h = instr_in[15:12];
  assign opcode_l = instr_in[7:4];

  assign halt_in_mem =
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

  always @(posedge clk) begin
    instr_out <= instr_in;
    result_out <= result_in;
    bubble_out <= halt_in_wb ? 1 : bubble_in;
  end

endmodule