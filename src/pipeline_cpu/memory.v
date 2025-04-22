
module memory(input clk, 
    input bubble_in,
    input [2:0]opcode_in, input [2:0]tgt_in, input [15:0]result_in, input halt_in,
    
    output reg [2:0]tgt_out, output reg [2:0] opcode_out, output reg [15:0]result_out,
    output we, output reg bubble_out, output reg halt_out
  );

  assign we = (opcode_in == 3'b100) && !bubble_in && !halt_out;

  initial begin
    bubble_out <= 1;
  end

  always @(posedge clk) begin
    tgt_out <= tgt_in;
    opcode_out <= opcode_in;
    result_out <= result_in;
    bubble_out <= halt_out ? 1 : bubble_in;
    halt_out <= halt_in;
  end

endmodule