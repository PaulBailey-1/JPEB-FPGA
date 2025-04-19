module regfile(input clk,
    input [2:0]raddr0, output [15:0]rdata0,
    input [2:0]raddr1, output [15:0]rdata1,
    input wen, input [2:0]waddr, input [15:0]wdata, output [15:0]ret_val);

  reg [15:0]regfile[0:3'b111];

  assign rdata0 = (raddr0 == 0) ? 16'b0 : regfile[raddr0];
  assign rdata1 = (raddr1 == 0) ? 16'b0 : regfile[raddr1];
  assign ret_val = regfile[3'h3];

  always @(posedge clk) begin
    if (wen) begin
        regfile[waddr] <= wdata;
    end
  end

endmodule