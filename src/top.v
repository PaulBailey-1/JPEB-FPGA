`timescale 1ps/1ps

module jpeb(
`ifndef SIMULATION
    input clk,
    input ps2_clk, input ps2_data,
    output vga_h_sync, vga_v_sync,
    output [3:0]vga_red,
    output [3:0]vga_green,
    output [3:0]vga_blue,
    output status_led, output [7:0]leds
`endif
    );

    reg reset = 0;

`ifdef SIMULATION
    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, jpeb);
    end

    // clock
    wire clk;
    clock c0(clk);

    wire [7:0] led;
    wire sig_led;
    wire status_led;

`endif

    // PS/2
    wire ps2_ren;
    wire [15:0]ps2_data_out;
    ps2 ps2(.ps2_clk(ps2_clk), .ps2_data(ps2_data), .clk(clk), .ren(ps2_ren), .data(ps2_data_out));

    // VGA
    wire [9:0]pixel_addr_x;
    wire [9:0]pixel_addr_y;
    wire displaying;
    wire [11:0]display_pixel;
    wire [11:0]pixel = displaying ? display_pixel : 12'h000;
    assign vga_red = pixel[3:0];
    assign vga_green = pixel[7:4];
    assign vga_blue = pixel[11:8];

    vga vga(
        .clk(clk), .reset(reset),
        .h_sync_out(vga_h_sync), .v_sync_out(vga_v_sync),
        .pixel_addr_x(pixel_addr_x), .pixel_addr_y(pixel_addr_y),
        .display_out(displaying)
    );

    // Memory
    wire [15:0]mem_read0_addr;
    wire [15:0]mem_read0_data;
    wire mem_read_en;
    wire [15:0]mem_read1_addr;
    wire [15:0]mem_read1_data;
    wire mem_write_en;
    wire [15:0]mem_write_addr;
    wire [15:0]mem_write_data;

    mem mem(.clk(clk), 
        .raddr0(mem_read0_addr), .rdata0(mem_read0_data),
        .ren(mem_read_en), .raddr1(mem_read1_addr), .rdata1(mem_read1_data),
        .wen(mem_write_en), .waddr(mem_write_addr), .wdata(mem_write_data),
        .ps2_ren(ps2_ren),
         .ps2_data_in(ps2_data_out),
        .pixel_x(pixel_addr_x), .pixel_y(pixel_addr_y), .pixel(display_pixel)
    );

    wire [15:0]ret_val;
    assign leds = ret_val[7:0];

    cpu cpu(
        clk, mem_read_en,
        mem_read0_addr, mem_read0_data,
        mem_read1_addr, mem_read1_data,
        mem_write_en, mem_write_addr, mem_write_data,
        ret_val
    );

    // Blinks
    reg [24:0] led_counter = 0;
    assign status_led = led_counter[24];
    always @(posedge clk) begin
        led_counter <= led_counter + 1;
    end

endmodule