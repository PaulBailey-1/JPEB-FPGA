

module writeback(input clk, input bubble_in, 
    input [2:0]tgt_in, input [2:0]opcode_in, input [15:0]alu_result, input [15:0]mem_result,
    output [15:0]result_out,
    output we, output reg [2:0]wb_tgt_out, output reg [15:0]wb_result_out
  );

  initial begin
    wb_tgt_out <= 3'b000;
  end

  always @(posedge clk) begin
    wb_tgt_out <= tgt_in;
    wb_result_out <= result_out;
  end

  assign we = (tgt_in != 0) && (opcode_in != 3'b100 && opcode_in != 3'b110) && !bubble_in;
  assign result_out = (opcode_in == 3'b101) ? mem_result : alu_result;

endmodule