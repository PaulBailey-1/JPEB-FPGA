`timescale 1ps/1ps

module mem(input clk,
    input [15:0]raddr0, output reg [15:0]rdata0,
    input ren, input [15:0]raddr1, output reg [15:0]rdata1,
    input wen, input [15:0]waddr, input [15:0]wdata,
    output ps2_ren, input [15:0]ps2_data_in,
    input [9:0]pixel_x_in, input [9:0]pixel_y_in, output [11:0]pixel,
    output reg [7:0]uart_tx_data, output uart_tx_wen
);

    localparam TILEMAP_START = 16'hc000;
    localparam FRAMEBUFFER_START = 16'he000;
    localparam IO_START = 16'hf000;
    localparam PS2_REG = 16'hffff;
    localparam VSCROLL_REG = 16'hfffe;
    localparam HSCROLL_REG = 16'hfffd;
    localparam SCALE_REG = 16'hfffc;
    localparam UART_TX_REG = 16'hf000;

    (* ram_style = "block" *) reg [15:0]ram[0:16'hbfff]; // 768Kb (0x0000-0xBFFF)
    (* ram_style = "block" *) reg [15:0]tile_map[0:16'h1fff]; // 128Kb (0xC000-0xDFFF)
    (* ram_style = "block" *) reg [15:0]frame_buffer[0:16'h0fff]; // 64Kb (0xE000-0xEFFF)

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

    reg [15:0]raddr0_buf;
    reg [15:0]raddr1_buf;
    reg [15:0]waddr_buf;

    reg ren_buf;
    reg wen_buf;

    reg [15:0]ram_data0_out;
    reg [15:0]ram_data1_out;
    reg [15:0]tilemap_data0_out = 0;
    reg [15:0]tilemap_data1_out;
    reg [15:0]framebuffer_data0_out = 0;
    reg [15:0]framebuffer_data1_out;

    reg [15:0]scale_reg = 0;
    reg [15:0]vscroll_reg = 0;
    reg [15:0]hscroll_reg = 0;

    wire [15:0]data0_out =  raddr0_buf < TILEMAP_START ? ram_data0_out :
                            raddr0_buf < FRAMEBUFFER_START ? tilemap_data0_out :
                            raddr0_buf < IO_START ? framebuffer_data0_out :
                            raddr0_buf == SCALE_REG ? scale_reg :
                            raddr0_buf == HSCROLL_REG ? hscroll_reg :
                            raddr0_buf == VSCROLL_REG ? vscroll_reg :
                            raddr0_buf == PS2_REG ? ps2_data_in :
                            16'h0;
    wire [15:0]data1_out =  raddr1_buf < TILEMAP_START ? ram_data1_out :
                            raddr1_buf < FRAMEBUFFER_START ? tilemap_data1_out :
                            raddr1_buf < IO_START ? framebuffer_data1_out :
                            raddr1_buf == SCALE_REG ? scale_reg :
                            raddr1_buf == HSCROLL_REG ? hscroll_reg :
                            raddr1_buf == VSCROLL_REG ? vscroll_reg :
                            raddr1_buf == PS2_REG ? ps2_data_in :
                            16'h0;

    assign ps2_ren = raddr1_buf == PS2_REG & ren_buf;
    assign uart_tx_wen = waddr_buf == UART_TX_REG & wen_buf;

    reg [15:0]display_framebuffer_out;
    reg display_odd_tile;
    reg [9:0]display_pixel_x;
    reg [9:0]display_pixel_y;
    reg [15:0]display_tilemap_out;

    wire [9:0]pixel_x = (pixel_x_in >> scale_reg) - hscroll_reg[9:0];
    wire [9:0]pixel_y = (pixel_y_in >> scale_reg) - vscroll_reg[9:0];
    
    // Display pixel retrevial
    wire [15:0] display_frame_addr = ({9'b0, pixel_x[9:3]} + {2'b0, pixel_y[9:3], 7'b0}); // (x / 8 + y / 8 * 128)
    wire [15:0] display_tile_addr_pair = display_framebuffer_out;
    wire [7:0] display_tile = ~display_odd_tile ? display_tile_addr_pair[7:0] : display_tile_addr_pair[15:8];
    wire [15:0] pixel_idx = {2'b0, display_tile, 6'b0} + {10'b0, display_pixel_y[2:0], 3'b0} + {13'b0, display_pixel_x[2:0]}; // tile_idx * 64 + py % 8 * 8 + px % 8
    assign pixel = display_tilemap_out[11:0];

    always @(posedge clk) begin

        raddr0_buf <= raddr0;
        raddr1_buf <= raddr1;
        waddr_buf <= waddr;

        ren_buf <= ren;
        wen_buf <= wen;

        ram_data0_out <= ram[raddr0];
        ram_data1_out <= ram[raddr1];
        tilemap_data1_out <= tile_map[raddr1 - TILEMAP_START];
        framebuffer_data1_out <= frame_buffer[raddr1 - FRAMEBUFFER_START];

        rdata0 <= data0_out;
        rdata1 <= data1_out;

        display_framebuffer_out <= frame_buffer[display_frame_addr[15:1]];
        display_odd_tile <= display_frame_addr[0];
        display_pixel_x <= pixel_x;
        display_pixel_y <= pixel_y;
        display_tilemap_out <= tile_map[pixel_idx];

        if (wen) begin
            if (waddr < TILEMAP_START) begin
                ram[waddr] <= wdata;
            end else if (waddr < FRAMEBUFFER_START) begin
                tile_map[waddr - TILEMAP_START] <= wdata;
            end else if (waddr < IO_START) begin
                frame_buffer[waddr - FRAMEBUFFER_START] <= wdata;
            end
            if (waddr == SCALE_REG) begin
                scale_reg <= wdata;
            end
            if (waddr == HSCROLL_REG) begin
                hscroll_reg <= wdata;
            end
            if (waddr == VSCROLL_REG) begin
                vscroll_reg <= wdata;
            end
            if (waddr == UART_TX_REG) begin
                uart_tx_data <= wdata[7:0];
            end
        end
    end

endmodule
