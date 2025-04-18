`timescale 1ps/1ps

module main(
`ifndef SIMULATION
    input clk, input ps2_clk, input ps2_data
`endif
    );

    reg halt = 0;

`ifdef SIMULATION
    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0,main);
    end

    // clock
    wire clk;
    clock c0(clk);
    counter ctr(halt, clk);

    wire [7:0] led;
    wire sig_led;
    wire status_led;
`endif


    // PC
    reg [15:0]pc = 16'h0000;

    // memory
    wire [15:0]mem_inst;
    wire mem_read_en;
    wire [15:0]mem_addr;
    wire [15:0]mem_data;
    wire mem_write_en;
    wire [15:0]mem_write_addr;
    wire [15:0]mem_write_data;

    mem mem(clk, 
        pc[15:0], mem_inst,
        mem_read_en, mem_addr, mem_data,
        mem_write_en, mem_write_addr, mem_write_data,
        ps2_clk, ps2_data
    );

    reg [15:0]temp = 0;
    assign mem_read_en = temp[0];
    assign mem_addr = temp;
    assign mem_write_en = temp[1];
    assign mem_write_addr = temp;
    assign mem_write_data = temp;

    reg [24:0] led_counter = 0;
    assign status_led = led_counter[24];

    always @(posedge clk) begin
        led_counter <= led_counter + 1;
    end

endmodule