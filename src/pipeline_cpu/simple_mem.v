
module simple_mem(input clk, input stall,
    input [15:0]raddr0, output reg [15:0]rdata0,
    input [15:0]raddr1, output reg [15:0]rdata1,
    input wen, input [15:0]waddr, input [15:0]wdata);
  // simpler memory for simulation/debugging cpu
  reg [15:0]ram[0:16'h7fff];

`ifdef SIMULATION
    reg [255:0] filepath;
    initial begin
        if (!$value$plusargs("DATAPATH=%s", filepath)) begin
            $display("No datapath provided.");
        end
    end
    initial begin
        $readmemh({filepath, "/program.hex"},ram);
    end
`else
  initial begin
      $readmemh("../../data/program.hex",ram);
  end
`endif

  always @(posedge clk) begin
    if (wen) begin
        ram[waddr] <= wdata;
    end
    if (!stall) begin
      rdata0 <= ram[raddr0];
      rdata1 <= ram[raddr1];
    end
  end

endmodule