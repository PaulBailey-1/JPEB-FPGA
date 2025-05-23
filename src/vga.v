`timescale 1ps/1ps

// Informed by https://github.com/BlagojeBlagojevic/vga_verilog
// and https://github.com/ColtonBeery/Basys3_VGA_Testbench/tree/master

module vga(
    input clk, input clk_100MHz, input reset, 
    output h_sync_out, output v_sync_out,
    output [9:0]pixel_addr_x, output [9:0]pixel_addr_y,
    output display_out
);

    localparam H_ACTIVE = 640;
    localparam H_FRONTPORCH = 16;
    localparam H_SYNC = 96;
    localparam H_BACKPORCH = 48;

    localparam V_ACTIVE = 480;
    localparam V_FRONTPORCH = 10;
    localparam V_SYNC = 2;
    localparam V_BACKPORCH = 32;

    reg h_sync, v_sync;
    wire h_sync_buf, v_sync_buf;
    reg [9:0]h_counter = 0;
    reg [9:0]h_counter_buff = 0;
    reg [9:0]v_counter = 0;
    reg [9:0]v_counter_buff = 0;

    // Divides 50Mhz clk to 25MHz
    reg [1:0]clk_div = 0;
    wire pixel_clk = clk_div == 0 ? 1 : 0;
    always @(posedge clk_100MHz or posedge reset) begin
        if (reset)
            clk_div <= 0;
        else
            clk_div <= clk_div + 1;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            h_counter <= 0;
            v_counter <= 0;
            h_sync <= 0;
            v_sync <= 0;
        end else begin
            h_counter <= h_counter_buff;
            v_counter <= v_counter_buff;
            h_sync <= h_sync_buf;
            v_sync <= v_sync_buf;
        end
    end

    always @(posedge pixel_clk or posedge reset) begin
        if (reset) begin
            h_counter_buff <= 0;
            v_counter_buff <= 0;
        end else begin
            if (h_counter == H_ACTIVE + H_FRONTPORCH + H_SYNC + H_BACKPORCH) begin
                h_counter_buff <= 0;
                if (v_counter == V_ACTIVE + V_FRONTPORCH + V_SYNC + V_BACKPORCH) begin
                    v_counter_buff <= 0;
                end else
                    v_counter_buff <= v_counter + 1;
            end else
                h_counter_buff <= h_counter + 1;
        end
    end

    assign h_sync_buf = !((h_counter >= H_ACTIVE + H_FRONTPORCH) && (h_counter < H_ACTIVE + H_FRONTPORCH + H_SYNC));
    assign v_sync_buf = !((v_counter >= V_ACTIVE + V_FRONTPORCH) && (v_counter < V_ACTIVE + V_FRONTPORCH + V_SYNC));

    assign h_sync_out = h_sync;
    assign v_sync_out = v_sync;
    assign display_out = h_counter < H_ACTIVE && v_counter < V_ACTIVE;
    assign pixel_addr_x = h_counter;
    assign pixel_addr_y = v_counter;

endmodule