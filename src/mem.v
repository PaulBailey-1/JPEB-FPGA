`timescale 1ps/1ps

module mem(input clk,
    input [15:0]raddr0, output [15:0]rdata0,
    input ren, input [15:0]raddr1, output reg [15:0]rdata1,
    input wen, input [15:0]waddr, input [15:0]wdata);

    localparam TILEMAP_START = 16'hc000;
    localparam FRAMEBUFFER_START = 16'he000;
    localparam IO_START = 16'hf000;
    localparam PS2_REG = 16'hf000;

    reg [15:0]ram[0:16'hbfff]; // 768Kb (0x0000-0xBFFF)
    reg [15:0]tile_map[0:16'h2000]; // 128Kb (0xC000-0xDFFF)
    reg [15:0]frame_buffer[0:16'h1000]; // 64Kb (0xE000-0xEFFF)

    wire ps2_clk;
    wire ps2_data;
    wire ps2_ren = raddr1 == PS2_REG & ren;
    wire [15:0]ps2_data_out;
    ps2 ps2(ps2_clk, ps2_data, clk, ps2_ren, ps2_data_out);

    /* Simulation -- read initial content from file */
    initial begin
        $readmemh("program.hex", ram);
        $readmemb("tilemap.bin", tile_map);
    end

    assign rdata0 = raddr0 < TILEMAP_START ? ram[raddr0] :
                    raddr0 < FRAMEBUFFER_START ? tile_map[raddr0 - TILEMAP_START] :
                    raddr0 < IO_START ? tile_map[raddr0 - FRAMEBUFFER_START] : 0;

    always @(posedge clk) begin

        if (ren) begin
            if (raddr1 < TILEMAP_START) begin
                rdata1 <= ram[raddr1];
            end else if (raddr1 < FRAMEBUFFER_START) begin
                rdata1 <= tile_map[raddr1 - TILEMAP_START];
            end else if (raddr1 < IO_START) begin
                rdata1 <= frame_buffer[raddr1 - FRAMEBUFFER_START];
            end else if (raddr1 == PS2_REG) begin
                rdata1 <= ps2_data_out;
            end
        end
        if (wen) begin
            if (waddr < TILEMAP_START) begin
                ram[waddr] <= wdata;
            end else if (waddr < FRAMEBUFFER_START) begin
                tile_map[waddr - TILEMAP_START] <= wdata;
            end else if (waddr < IO_START) begin
                frame_buffer[waddr - FRAMEBUFFER_START] <= wdata;
            end
        end
    end

endmodule
