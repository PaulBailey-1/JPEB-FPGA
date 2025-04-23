`timescale 1ps/1ps

module fetch_a(input clk, input stall, input flush,
    input branch, input [15:0]branch_tgt,
    output [15:0]fetch_addr, output reg [15:0]pc_out, output reg bubble_out
  );

  reg [15:0]pc = 16'h0000;

  assign fetch_addr = branch ? branch_tgt : (stall ? pc - 16'h1 : pc);

  initial begin
    bubble_out = 1;
    pc = 16'h0000;
  end

  always @(posedge clk) begin
    if (!stall) begin
      pc <= branch ? branch_tgt + 1 : pc + 1;
      bubble_out <= 0;
      pc_out <= pc;
    end
  end
endmodule

module fetch_b(input clk, input stall, input flush, input bubble_in,
    input [15:0]pc_in,
    output reg bubble_out, output reg [15:0]pc_out
  );

    initial begin
      bubble_out = 1;
    end

    always @(posedge clk) begin 
      if (!stall) begin
        bubble_out <= flush ? 1 : bubble_in;
        pc_out <= pc_in;
      end
    end
endmodule