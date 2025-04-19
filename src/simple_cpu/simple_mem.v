
module simple_mem(input clk,
    input [15:0]raddr0, output [15:0]rdata0,
    input [15:0]raddr1, output [15:0]rdata1,
    input wen, input [15:0]waddr, input [15:0]wdata);
  // simpler memory for simulation/debugging cpu
  reg [15:0]ram[0:16'h7fff];

  /* Simulation -- read initial content from file */
  initial begin
      $readmemh("add_test.hex",ram);
  end

  assign rdata0 = ram[raddr0];
  assign rdata1 = ram[raddr1];

  always @(posedge clk) begin
    if (wen) begin
        ram[waddr] <= wdata;
    end
  end

endmodule