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

    (* ram_style = "block" *) reg [15:0]ram[0:16'h2000]; // 768Kb (0x0000-0xBFFF)
    (* ram_style = "block" *) reg [15:0]tile_map[0:16'h2000]; // 128Kb (0xC000-0xDFFF)
    (* ram_style = "block" *) reg [15:0]frame_buffer[0:16'h1000]; // 64Kb (0xE000-0xEFFF)

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

    reg [15:0]ram_data0_out;
    reg [15:0]ram_data1_out;
    reg [15:0]tilemap_data0_out;
    reg [15:0]tilemap_data1_out;
    reg [15:0]framebuffer_data0_out;
    reg [15:0]framebuffer_data1_out;

    wire [15:0]data0_out =  raddr0 < TILEMAP_START ? ram_data0_out :
                            raddr0 < FRAMEBUFFER_START ? framebuffer_data0_out :
                            ps2_data_in;
    wire [15:0]data1_out =  raddr1 < TILEMAP_START ? ram_data1_out :
                            raddr1 < FRAMEBUFFER_START ? framebuffer_data1_out :
                            ps2_data_in;

    assign ps2_ren = raddr1 == PS2_REG & ren;

    reg [15:0]display_framebuffer_out;
    reg display_odd_tile;
    reg [9:0]display_pixel_x;
    reg [9:0]display_pixel_y;
    reg [15:0]display_tilemap_out;
    
    // Display pixel retrevial
    // wire [15:0] display_frame_addr = (({{6{1'b0}}, pixel_x} >> 3) + ({{6{1'b0}}, pixel_y} << 4)) >> 1; // (x / 8 + y /8 * 128) / 2
    // wire [15:0] display_tile_addr_pair = display_framebuffer_out;
    // wire [7:0] display_tile = ~display_odd_tile ? display_tile_addr_pair[7:0] : display_tile_addr_pair[15:8];
    // wire [15:0] pixel_idx = (display_tile << 6) + ((display_pixel_y & 10'h007) << 3) + (display_pixel_x & 10'h007); // tile_idx * 64 + py % 8 * 8 + px % 8
    // assign pixel = display_tilemap_out[11:0];

    always @(posedge clk) begin

        ram_data0_out <= ram[raddr0];
        ram_data1_out <= ram[raddr1];
        tilemap_data0_out <= tile_map[raddr0 - TILEMAP_START];
        tilemap_data1_out <= tile_map[raddr1 - TILEMAP_START];
        framebuffer_data0_out <= frame_buffer[raddr0 - FRAMEBUFFER_START];
        framebuffer_data1_out <= frame_buffer[raddr1 - FRAMEBUFFER_START];

        rdata0 <= data0_out;
        rdata1 <= data1_out;

        // display_framebuffer_out <= frame_buffer[display_frame_addr];
        // display_odd_tile <= display_frame_addr[0];
        // display_pixel_x <= pixel_x;
        // display_pixel_y <= pixel_y;
        // display_tilemap_out <= tile_map[pixel_idx];

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
