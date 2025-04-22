`timescale 1ps/1ps

module mem(input clk,
    input [15:0]raddr0, output reg [15:0]rdata0,
    input ren, input [15:0]raddr1, output reg [15:0]rdata1,
    input wen, input [15:0]waddr, input [15:0]wdata,
    output ps2_ren, input [15:0]ps2_data_in,
    input [9:0]pixel_x, input [9:0]pixel_y, output [11:0]pixel
);

    localparam TILEMAP_START = 16'hc000;
    localparam FRAMEBUFFER_START = 16'he000;
    localparam IO_START = 16'hf000;
    localparam PS2_REG = 16'hf000;

    reg [15:0]ram[0:16'h2000]; // 768Kb (0x0000-0xBFFF)
    reg [15:0]tile_map[0:16'h2000]; // 128Kb (0xC000-0xDFFF)
    reg [15:0]frame_buffer[0:16'h1000]; // 64Kb (0xE000-0xEFFF)

`ifdef SIMULATION
    reg [255:0] filepath;
    initial begin
        if (!$value$plusargs("DATAPATH=%s", filepath)) begin
            filepath = "./data/"; // Default
        end
    end
    initial begin
        // Parameter
        $readmemh({filepath, "/program.hex"},ram);
        $readmemh({filepath, "tilemap.hex"}, tile_map);
    end
`else
  initial begin
        // Sythesis
        $readmemh("../data/program.hex",ram);
        $readmemh("../data/tilemap.hex", tile_map);
  end
`endif

    assign ps2_ren = raddr1 == PS2_REG & ren;
    
    // Display pixel retrevial
    wire [15:0] display_frame_addr = ({{6{1'b0}}, pixel_x} >> 3) + ({{6{1'b0}}, pixel_y} << 4); // x / 8 + y /8 * 128
    wire [15:0] display_tile_addr_pair = frame_buffer[(display_frame_addr >> 1)];
    wire [7:0] display_tile = ~display_frame_addr[0] ? display_tile_addr_pair[7:0] : display_tile_addr_pair[15:8];
    wire [15:0] pixel_idx = (display_tile << 6) + ((pixel_y & 10'h007) << 3) + (pixel_x & 10'h007); // tile_idx * 64 + py % 8 * 8 + px % 8
    assign pixel = tile_map[pixel_idx][11:0];

    always @(posedge clk) begin

        frame_buffer[0] <= 16'h0001;
        frame_buffer[1] <= 16'h0302;
        frame_buffer[2] <= 16'h0302;
        frame_buffer[3] <= 16'h0302;

        if (ren) begin
            if (raddr0 < TILEMAP_START) begin
                rdata0 <= ram[raddr0];
            end else if (raddr0 < FRAMEBUFFER_START) begin
                rdata0 <= tile_map[raddr0 - TILEMAP_START];
            end else if (raddr0 < IO_START) begin
                rdata0 <= frame_buffer[raddr0 - FRAMEBUFFER_START];
            end else if (raddr0 == PS2_REG) begin
                rdata0 <= ps2_data_in;
            end

            if (raddr1 < TILEMAP_START) begin
                rdata1 <= ram[raddr1];
            end else if (raddr1 < FRAMEBUFFER_START) begin
                rdata1 <= tile_map[raddr1 - TILEMAP_START];
            end else if (raddr1 < IO_START) begin
                rdata1 <= frame_buffer[raddr1 - FRAMEBUFFER_START];
            end else if (raddr1 == PS2_REG) begin
                rdata1 <= ps2_data_in;
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
