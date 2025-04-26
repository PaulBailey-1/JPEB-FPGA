`timescale 1ps/1ps

module jpeb(
`ifndef SIMULATION
    input board_clk,
    input ps2_clk, input ps2_data,
    output vga_h_sync, vga_v_sync,
    output [3:0]vga_red,
    output [3:0]vga_green,
    output [3:0]vga_blue,
    output uart_tx,
    input uart_rx,
    output [15:0]leds
`endif
    );

    reg reset = 0;
    wire clk;

`ifdef SIMULATION
    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, jpeb);
    end

    clock c0(board_clk);

    reg clk_div_0 = 0;
    assign clk = clk_div_0;
    always @(posedge board_clk) begin
        clk_div_0 <= ~clk_div_0;
    end

    wire [15:0] leds;

`else

    wire clk_100Mhz;
    wire clk_50MHz;
    clk_wiz_0 instance_name(
        // Clock out ports
        .clk_100hz(clk_100MHz),     // output clk_100hz
        .clk_50hz(clk_50MHz),     // output clk_50hz
        // Clock in ports
        .clk_in1(board_clk)      // input clk_in1
    );
    assign clk = clk_50MHz;

    // 1 Hz divider
    // reg [25:0]clk_div = 0;
    // assign clk = clk_div[25];
    // always @(posedge clk_50MHz ) begin
    //     clk_div <= clk_div + 1;
    // end

`endif

    // PS/2
    wire ps2_ren;
    wire [15:0]ps2_data_out;
    wire ps2_ready_flag;
    ps2 ps2(.ps2_clk(ps2_clk), .ps2_data(ps2_data), .clk(clk), .ren(ps2_ren), .data(ps2_data_out), .ready(ps2_ready_flag));

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
        .clk(clk), .clk_100MHz(board_clk), .reset(reset),
        .h_sync_out(vga_h_sync), .v_sync_out(vga_v_sync),
        .pixel_addr_x(pixel_addr_x), .pixel_addr_y(pixel_addr_y),
        .display_out(displaying)
    );

    // UART
    wire uart_tx_en;
    wire uart_rx_en;
    wire [7:0]uart_tx_data;
    wire [7:0]uart_rx_data;

    uart uart(
        .clk(clk), .baud_clk(board_clk), 
        .tx_en(uart_tx_en), .tx_data(uart_tx_data), .tx(uart_tx),
        .rx(uart_rx), .rx_en(uart_rx_en), .rx_data(uart_rx_data)
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
        .pixel_x_in(pixel_addr_x), .pixel_y_in(pixel_addr_y), .pixel(display_pixel),
        .uart_tx_data(uart_tx_data), .uart_tx_wen(uart_tx_en)
        //.uart_rx_data(uart_rx_data), .uart_rx_ren(uart_rx_en)
    );

    wire [15:0]ret_val;
    wire [15:0]cpu_pc;
    wire [3:0]flags;
    // assign leds[7:0] = ret_val[7:0];
    // assign leds[7:0] = cpu_pc[7:0];
    // assign leds[11:8] = flags;
    assign leds = ps2_data_out;

    pipelined_cpu cpu(
        clk, mem_read_en,
        mem_read0_addr, mem_read0_data,
        mem_read1_addr, mem_read1_data,
        mem_write_en, mem_write_addr, mem_write_data,
        ret_val, flags, cpu_pc
    );

    // Blinks
    reg [24:0] led_counter = 0;
    assign send_trig = led_counter[24];
    always @(posedge clk) begin
        led_counter <= led_counter + 1;
    end

endmodule