

module fetch(input clk, input stall, input flush,
    input branch, input [15:0]branch_tgt,
    output reg [15:0]pc, output reg [15:0]pc_out, output reg bubble_out
  );

  initial begin
    bubble_out <= 1;
    pc <= 16'h0000;
  end

  always @(posedge clk) begin
    if (!stall) begin
      pc <= branch ? branch_tgt : pc + 1;
      bubble_out <= !flush;
      pc_out <= pc;
    end
  end
endmodule
