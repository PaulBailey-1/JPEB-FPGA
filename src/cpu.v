`timescale 1ps/1ps

module cpu(
    input clk
    );

    reg halt = 0;

`ifdef SIMULATION
    counter ctr(halt, clk);
`endif

    // PC
    reg [15:0]pc = 16'h0000;

endmodule