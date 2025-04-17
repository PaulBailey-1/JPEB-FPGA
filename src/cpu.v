`timescale 1ps/1ps

module main();

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0,main);
    end

    // clock
    wire clk;
    clock c0(clk);

    reg halt = 0;

    counter ctr(halt,clk);

    // PC, also f0
    reg [15:0]pc = 16'h0000;

    // memory
    wire [15:0]mem_inst;
    wire [15:1]mem_addr;
    wire [15:0]mem_data;
    wire mem_write_en;
    wire [15:1]mem_write_addr;
    wire [15:0]mem_write_data;

    mem mem(clk, 
        pc[15:1], mem_inst,
        mem_addr, mem_data,
        mem_write_en, mem_write_addr, mem_write_data
    );
    

endmodule